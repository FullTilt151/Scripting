## Define new class name and date
$NewClassName = 'Win32_ApplicationErrors'
$Date = Get-Date

## Remove class if exists
Remove-WmiObject -Class $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("RecordId", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("TimeCreated", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Id", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Message", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ProcessPath", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Process", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ModulePath", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Module", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["RecordId"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather current error information
$hash = @{
        LogName='Application';
        ProviderName = 'Application Error'
    }
Get-WinEvent -FilterHashtable $hash -MaxEvents 100 | Select-Object RecordID, TimeCreated, Id, Message |  
ForEach-Object {

    ## Set error information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -Arguments @{
        RecordID = $_.RecordID
        TimeCreated = $_.TimeCreated
        Id = $_.Id
        Message = $_.Message
        ProcessPath = Split-Path ($_.Message.Split("`n") | Select-String 'application path').ToString().Replace('Faulting application path: ','') -Parent
        Process = Split-Path ($_.Message.Split("`n") | Select-String 'application path').ToString().Replace('Faulting application path: ','') -Leaf
        ModulePath = Split-Path ($_.Message.Split("`n") | Select-String 'module path').ToString().Replace('Faulting module path: ','') -Parent
        Module = Split-Path ($_.Message.Split("`n") | Select-String 'module path').ToString().Replace('Faulting module path: ','') -Leaf
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"