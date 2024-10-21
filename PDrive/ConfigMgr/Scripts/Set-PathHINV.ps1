## Define new class name and date
$NewClassName = 'Win32_Path_Custom'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("Position", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Entry", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["Position"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather current driver information
$x = 0
$env:Path -split ';' | ForEach-Object{
    ## Set driver information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        Position = [String]$x++;
        Entry = $_;
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output $true