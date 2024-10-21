## Define new class name and date
$NewClassName = 'Win32_JavaExceptionSites'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("Site", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["Site"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

$Sites = Get-Content C:\windows\security\exception.sites -ErrorAction SilentlyContinue

$Sites | 
ForEach-Object {
    ## Set data in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -argument @{
        Site = $_
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"