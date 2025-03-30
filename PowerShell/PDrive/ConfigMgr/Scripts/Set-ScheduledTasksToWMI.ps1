## Define new class name and date
$NewClassName = 'Win32_ScheduledTasks'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("Name", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Path", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("State", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Enabled", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("LastRunTime", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("NextRunTime", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("LastTaskResult", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("NumberOfMissedRuns", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["Name"].Qualifiers.Add("Key", $true)
$newClass.Properties["Path"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

$TS = New-Object -ComObject Schedule.Service
$TS.Connect($env:COMPUTERNAME)
$TaskFolder = $TS.GetFolder("\")
$Tasks = $TaskFolder.GetTasks(1)

$Tasks | ForEach-Object {
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -argument @{
        Name = $_.Name;
        Path = $_.Path;
        State = $_.State;
        Enabled = $_.Enabled;
        LastRunTime = $_.LastRunTime;
        NextRunTime = $_.NextRunTime;
        LastTaskResult = $_.LastTaskResult;
        NumberOfMissedRuns = $_.NumberOfMissedRuns;
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"