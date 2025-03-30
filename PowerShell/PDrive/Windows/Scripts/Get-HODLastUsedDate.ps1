## Define new class name and date
$NewClassName = 'Win32_HOD'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("Path", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("LastModified", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["Path"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather HOD files last used time
$hodfiles = Get-Childitem -Path c:\users -Name hod.humana.com.HOD_CCR2.ccr -Recurse
ForEach ($file in $hodfiles) {
    $fileinfo = Get-Item c:\users\$file
    ## Set driver information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        Path = $fileinfo.FullName;
        LastModified = $fileinfo.LastWriteTime;
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"