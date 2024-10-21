## Define new class name and date
$NewClassName = 'Win32_IEActiveXFiltering'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("User", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("FilteringEnabled", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["User"].Qualifiers.Add("Key", $true)
$newClass.Properties["FilteringEnabled"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null


## Gather users with ActiveX filtering
$Usertable = @()
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
get-childitem hku: | foreach {
    if ($_.Name -notin ('HKEY_USERS\.DEFAULT','HKEY_USERS\S-1-5-18','HKEY_USERS\S-1-5-19','HKEY_USERS\S-1-5-20') -and $_.Name -notlike "*_Classes") {
        $UserSID = ($_.Name).Replace('HKEY_USERS\','')
        $SID = New-Object System.Security.Principal.SecurityIdentifier($UserSID) -ErrorAction SilentlyContinue
        $User = $SID.Translate( [System.Security.Principal.NTAccount])
        $Username = $User.Value
        $IsEnabled = (Get-ItemProperty -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\Software\Microsoft\Internet Explorer\Safety\ActiveXFiltering") -Name IsEnabled -ErrorAction SilentlyContinue).IsEnabled
        if ($IsEnabled -ne $null) {
            $usertable += ,@($Username, $IsEnabled)   
        }
    }
}

$Usertable | 
ForEach-Object {
    ## Set ActiveX filtering information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        User = ($_)[0];
        FilteringEnabled = ($_)[1];
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"