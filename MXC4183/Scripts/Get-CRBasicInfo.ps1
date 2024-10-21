<#
.SYNOPSIS
	This script gets basica CR info to inject into the PSADT.
.DESCRIPTION
	This script will inject Vendor, Product, Version into the PSADT 'headers'. Will add this to my main script.
.PARAMETER CR
    This is self explanatory
.EXAMPLE
    Update this later...
#>

Param (
    [Parameter(Mandatory=$true)]
    [string]$CR
)

$SQLServer = "scdddb.humana.com" #or machinename: LOUSQLWPS747
$SQLQ = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.request where RequestID = $CR"

$Product = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.product where ProductId = $($SQLQ.ProductID)" -ea stop
$Vendor = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.vendor where vendorId = $($Product.VendorID)"

$row = "" | Select-Object CR,Vendor,Product,Version
#,PreviousCRs,InstallString,PackageType,Notes,RequiredSecurity,RequiredHDD,DateAvailable,DateRequired
$row.CR = $CR
$row.Vendor = $vendor.Name
$row.Product = $Product.Name 
$row.Version = $sqlq.ProductVersion

Write-host $row.vendor, $row.product, $row.version