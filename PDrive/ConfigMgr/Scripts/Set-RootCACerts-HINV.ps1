## Define new class name and date
$NewClassName = 'Win32_RootCA'
$Date = get-date

## Remove class if exists
Remove-WmiObject -Class $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("Issuer", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Subject", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("Thumbprint", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["Subject"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null

## Gather current driver information
Get-ChildItem Cert:\LocalMachine\CA -Recurse | Select-Object Issuer, Subject, Thumbprint |
ForEach-Object {

    ## Set driver information in new class
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -argument @{
        Issuer = $_.Issuer;
        Subject = $_.Subject;
        Thumbprint = $_.Thumbprint;
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"