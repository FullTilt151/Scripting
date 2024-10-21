# Prompt for CR. 
Param (
	[Parameter(Mandatory=$true)]
	[string]$Site,
    [Parameter(Mandatory=$true)]
	[string]$CR

)

# Make sure I'm not on a site drive.
Push-location C:\temp

# Throw the UNC path to the file we want modify into a variable based on Site.
If($site -eq "WQ1"){
    Write-Host -ForegroundColor Green "Workstation test site given. Updating the PSADT in the ..\D907ATS\$CR\Install directory."
    $file = "\\lounaswps08.rsc.humad.com\pdrive\d907ats\$CR\install\deploy-application.ps1"
}

If($site -eq "SQ1"){
    Write-Host -ForegroundColor Blue "Server test site given. Updating the PSADT in the ..\D907ATSSVR\$CR\Install directory."
    $file = "\\lounaswps08.rsc.humad.com\pdrive\d907atssvr\$CR\install\deploy-application.ps1"
}

# Pull the CR info from the CR database.
$SQLServer = "scdddb.humana.com" #or machinename: LOUSQLWPS747
$SQLQ = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.request where RequestID = $CR"
$Product = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.product where ProductId = $($SQLQ.ProductID)" -ea stop
$Vendor = Invoke-Sqlcmd -ServerInstance $SQLServer -Database ATSCERTREQ -Query "select * from sc.vendor where vendorId = $($Product.VendorID)"

# Had to convert the results Invoke-sqlcmd to a string. https://stackoverflow.com/questions/46964645/store-invoke-sqlcmd-query-as-string
$VendorName = $vendor.name.ToString()
$ProductName = $product.name.ToString()
$VersionNumber = $sqlq.Productversion.ToString()

 # Make sure I didn't fat finger the CR#.
if(Test-Path -Path $file){
    # CR is legit so go ahead and update the VARIABLE DECLARATION section (line: 67ish). Line breaks to make it readable.
    $NewFile = (get-Content -path $file) -replace "appVendor = ''", "appVendor = '$VendorName'" `
                                         -replace "appName = ''", "appName = '$ProductName'" `
                                         -replace "appVersion = ''", "appVersion = '$VersionNumber'" `
                                         -replace 'XX/XX/20XX', $(Get-Date -UFormat "%m/%d/%Y") `
                                         -replace "appScriptAuthor = ''", "appScriptAuthor = 'Mike Cook'" `
                                         -replace "CR = ''", "CR = '$CR'"
    Set-Content -path $file -Value $NewFile
    Write-Host -ForegroundColor Green "PSADT script updated for CR: $CR"
    Write-Host -ForegroundColor Green "appVendor = $VendorName"
    Write-Host -ForegroundColor Green "appname = $ProductName"
    Write-host -ForegroundColor Green "appversion =  $VersionNumber"
    Write-host -ForegroundColor Green "appscriptdate =  $(Get-Date -UFormat "%m/%d/%Y")"
    Write-host -ForegroundColor Green "appScriptAuthor = Mike Cook"
    Write-host -ForegroundColor Green "CR = $CR"
    Write-Host -ForegroundColor Green "Get crackin!: $file"

Set-Location -Path "C:\temp"
}else{
    Write-host -ForegroundColor Red "CR:$CR not found! Make sure you input a valid CR number."
}
