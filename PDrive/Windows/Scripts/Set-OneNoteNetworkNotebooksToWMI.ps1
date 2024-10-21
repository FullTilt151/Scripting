$ErrorActionPreference = 'SilentlyContinue'

## Define new class name and date
$NewClassName = 'Win32_OneNoteNetworkNotebooks'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("User", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Notebook", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["User"].Qualifiers.Add("Key", $true)
$newClass.Properties["Notebook"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null


## Gather users Open Notebooks
$Usertable = @()
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
get-childitem hku: | ForEach-Object {
    if ($_.Name -notin ('HKEY_USERS\.DEFAULT','HKEY_USERS\S-1-5-18','HKEY_USERS\S-1-5-19','HKEY_USERS\S-1-5-20') -and $_.Name -notlike "*_Classes") {
        $UserSID = ($_.Name).Replace('HKEY_USERS\','')
        $SID = New-Object System.Security.Principal.SecurityIdentifier($UserSID) -ErrorAction SilentlyContinue
        $User = $SID.Translate( [System.Security.Principal.NTAccount])
        $Username = $User.Value
        $Notebooks = Get-Item -Path (($_.Name).Replace('HKEY_USERS','HKU:') + "\Software\Microsoft\Office\16.0\OneNote\opennotebooks") -ErrorAction SilentlyContinue 
        $Notebooks.GetValueNames() | ForEach-Object  {
            $Notebook = $Notebooks.GetValue($_)
            $Usertable += ,@($Username, $Notebook)    
        }
    }
}

$Usertable | ForEach-Object {
    ## Set OneNote information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        User = ($_)[0];
        Notebook = ($_)[1];
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"