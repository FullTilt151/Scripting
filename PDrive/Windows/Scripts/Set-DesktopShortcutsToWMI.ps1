## Define new class name and date
$NewClassName = 'Win32_DesktopShortcuts'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("Path", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Name", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Target", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["Path"].Qualifiers.Add("Key", $true)
$newClass.Properties["Name"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null


## Gather shortcuts in user profiles
Get-ChildItem C:\Users -Filter *.lnk -Recurse | 
ForEach-Object {
    $Fullname = $_.FullName
    $Name = $_.Name
    $Shell = New-Object -COM WScript.Shell
    $TargetPath = $Shell.CreateShortcut($FullName).TargetPath
    
    ## Set shortcuts information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        Path = $Fullname
        Name = $Name
        Target = $TargetPath
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"