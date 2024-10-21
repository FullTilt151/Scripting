## Define new class name and date
$NewClassName = 'CM_NetworkAdapterRSS'

## Remove class if exists
Remove-WmiObject -Class $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("AdapterName", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Enabled", [System.Management.CimType]::Boolean, $false)
$newClass.Properties.Add("MaxProcessors", [System.Management.CimType]::SInt16, $false)
$newClass.Properties.Add("NumberOfReceiveQueues", [System.Management.CimType]::SInt16, $false)
$newClass.Properties["AdapterName"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather current NetAdapterRss info
Get-NetAdapterRss | ForEach-Object {
    ## Set NetAdapterRss info in new class
    $null = Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -Arguments @{
        AdapterName           = $_.Name
        Enabled               = $_.Enabled
        MaxProcessors         = $_.MaxProcessors
        NumberOfReceiveQueues = $_.NumberOfReceiveQueues
    }
}

Write-Output "Complete"