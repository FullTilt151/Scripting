## Define new class name and date
$NewClassName = 'Win32_VisualStudioExtensions'
$Date = get-date

## Remove class if exists
Remove-WmiObject $NewClassName -ErrorAction SilentlyContinue

# Create new WMI class
$newClass = New-Object System.Management.ManagementClass ("root\cimv2", [String]::Empty, $null)
$newClass["__CLASS"] = $NewClassName

## Create properties you want inventoried
$newClass.Qualifiers.Add("Static", $true)
$newClass.Properties.Add("CompanyName", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ProductName", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ProductVersion", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("CodeClass", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("CodeBase", [System.Management.CimType]::String, $false)
$newClass.Properties.Add("ScriptLastRan", [System.Management.CimType]::String, $false)
$newClass.Properties["ProductName"].Qualifiers.Add("Key", $true)
$newClass.Properties["ProductVersion"].Qualifiers.Add("Key", $true)
$newClass.Put() | Out-Null


## Gather information you want to inventory
$VSPackages = @()
New-PSDrive -Name HKU -PSProvider Registry -Root HKEY_USERS -ErrorAction SilentlyContinue | out-null
Set-Location HKU:
Get-ChildItem -Path 'HKU:\.DEFAULT\Software\Microsoft\VisualStudio\14.0_Config\Packages' -ErrorAction SilentlyContinue | 
ForEach-Object {
    $VSPackages += Get-ItemProperty -Path $_.Name | Where-Object { $_.ProductName -ne $null } | Select-Object CompanyName, ProductName, ProductVersion, Class, CodeBase
}

$VSPackages |
ForEach-Object {
    ## Set information you want to inventory to WMI
    Set-WmiInstance -Namespace root\cimv2 -class $NewClassName -ErrorAction SilentlyContinue -argument @{
        CompanyName = $_.CompanyName
        ProductName = $_.ProductName
        ProductVersion = $_.ProductVersion
        CodeClass = $_.Class
        CodeBase = $_.CodeBase
        ScriptLastRan = $Date
	} | Out-Null
}

Write-Output "Complete"