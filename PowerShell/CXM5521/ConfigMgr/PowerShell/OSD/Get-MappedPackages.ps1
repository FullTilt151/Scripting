
try {
    $TSEnvironment = New-Object -ComObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
}
catch {
    Write-Output 'Failed to establish Microsoft.SMS.TSEnvironment ComObject'
    exit 1
}

#region functions
function Set-NextApplicationVariable {
    <#
    .SYNOPSIS
        Set the next TS variable for application/package installation
    .DESCRIPTION
        This function is used to find, and set the next variable in a list of application/packages
        Typically this would be used when you are generating a list of applications/packages from a
        front end, web service, or other means.
    .PARAMETER BaseVar
        The base variable name, such as 'MappedPackage' which the variables will buld off
    .PARAMETER Value
        The value you want to set the next available TS var to
    .EXAMPLE
        PS C:\> Set-NextApplicationVariable -BaseVar 'MappPackaged' -Value 'WQ100260:Huminst'
        Explanation of what the example does
    #>
    param
    (
        [parameter(Mandatory = $true)]
        [string]$BaseVar,
        [parameter(Mandatory = $true)]
        [string]$Value
    )
    try {
        $tsenv = New-Object -COMObject Microsoft.SMS.TSEnvironment -ErrorAction Stop
    }
    catch {
        Write-Error 'Failed to establish Microsoft.SMS.TSEnvironment ComObject'
        exit 1
    }
    #region set initial variable values
    $appStartNumber = 1
    $stopCheck = $false
    #endregion set initial variable values

    #region loop through TSvariables until we find an empty one by checking on each loop
    do {
        $FormattedNumber = $appStartNumber.ToString('000')
        [string]$TSVar = $BaseVar + $FormattedNumber
        [string]$varValue = $tsenv.Value($TSVar)

        if ([string]::IsNullOrWhiteSpace($varValue)) {
            $stopCheck = $true
        }

        $appStartNumber++
    }
    while (-not $stopCheck)
    #endregion loop through TSvariables until we find an empty one

    # set the value of the TS variable that has been determined to be the next empty one
    Write-Output "[$TSVar = $Value]"
    $tsenv.Value($TSVar) = $Value
}
#endregion functions


#region gather NAA info from TS Variables
$NaaUser = $TSEnvironment.Value("_SMSTSReserved1-000")
$NaaPW = $TSEnvironment.Value("_SMSTSReserved2-000") | ConvertTo-SecureString -AsPlainText -Force
#endregion gather NAA info from TS Variables

#region gather source computer from TS Variable
$SourceComputer = $TSEnvironment.Value("SourceComputer")
if ([string]::IsNullOrWhiteSpace($SourceComputer)) {
    Write-Output "Failed to identify source computer from TS Variable"
    exit 1
}
else {
    Write-Output "[SourceComputer = $SourceComputer]"
}
#endregion gather source computer from TS Variable

#region Connect to AppShop to and execute GetMappedPackages
$Cred = [pscredential]::new($NaaUser, $NaaPW)
$LookupURI = [string]::Format("http://appshop.humana.com/shopping/api/osd/GetMappedPackages?MachineName={0}&Domain=Humad", $SourceComputer)
Write-Output "Performing a GET against [LookupURI = $LookupURI] using Credential with [Username = $NaaUser]"
try {
    $Request = Invoke-WebRequest -Uri $LookupURI -Method GET -Credential $Cred -ErrorAction Stop
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output "GetMappedPackages failed for [SourceComputer = $SourceComputer] with [ErrorMessage = $ErrorMessage]"
}
#endregion Connect to AppShop to and execute GetMappedPackages

#region parse XML to find all 'MappedPackages' and set variables if some are found
if ($null -ne $Request) {
    $ResponseContent = $Request | Select-Object -ExpandProperty Content
    if ($null -ne $ResponseContent) {
        $XMLLoader = [xml]::new()
        $XMLLoader.LoadXml($ResponseContent)
        $MappedPackages = $XMLLoader.ArrayOfMappedPackage.MappedPackage
        $MappedPackageCount = $MappedPackages | Measure-Object | Select-Object -ExpandProperty Count
        Write-Output "Identified $MappedPackageCount mapped packages for $SourceComputer"
        if ($MappedPackageCount -ge 1) {
            #region loop through $MappedPackages and add each one to the MappedPackage variable list
            foreach ($Package in $MappedPackages) {
                Write-Output "Setting TS Variable for $($Package.MappedPackaged)"
                Set-NextApplicationVariable -BaseVar 'MappedPackage' -Value $Package.MappedPackage
            }
            #endregion loop through $MappedPackages and add each one to the MappedPackage variable list 
        }
    }
    else {
        Write-Output "Found that the content of the response was empty"
        exit 1
    }
}
else {
    Write-Output "Found that the request was empty"
    exit 1
}
#endregion parse XML to find all 'MappedPackages' and set variables if some are found