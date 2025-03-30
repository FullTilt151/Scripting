## Define new class name and date
$NewClassName = 'Win32_SystemErrors'
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
$newClass.Properties.Add("Message", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["RecordId"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather current error information
$hash = @{
        LogName='System';
        ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting';
}
Get-WinEvent -FilterHashtable $hash -ErrorAction SilentlyContinue | Select-Object RecordID, TimeCreated, Message | 
ForEach-Object {

    ## Set error information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -Arguments @{
        RecordID = $_.RecordID
        TimeCreated = $_.TimeCreated
        Message = $_.Message
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"