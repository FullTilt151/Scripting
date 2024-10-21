Connect-VIServer grbvcswps02 -Credential $mycredentials
$xlpath = "C:\Temp\VMDKFileInfo22Oct.xlsx"
$objExcel = New-Object -ComObject Excel.Application
$objExcel.DisplayAlerts = $false
$objExcel.Visible = $false
$WorkBook=$objExcel.Workbooks.Add()
$sheetCounter = 0
$s1 = $WorkBook.Sheets | where {$_.name -eq "Sheet1"}
$s2 = $WorkBook.Sheets | where {$_.name -eq "Sheet2"}
$s1.delete()
$s2.delete()
$intRowCounter = 1
#$dsList = @("GRB_HUM_PROD_C02_0788_042B_005_FC","GRB_HUM_PROD_C02_0788_04C1_015_FC","GRB_HUM_PROD_C02_0788_0557_025_FC", "GRB_HUM_PROD_C02_0788_0584_028_FC","GRB_HUM_PROD_C02_0788_05A2_030_FC","GRB_HUM_PROD_C02_0788_05C0_032_FC","GRB_HUM_PROD_C02_0788_05CF_033_FC","GRB_HUM_PROD_C02_0788_05DE_034_FC", "GRB_HUM_PROD_C02_0788_060B_035_FC")
#$dsList = @("GRB_HUM_PROD_C02_0788_042B_005_FC","GRB_HUM_PROD_C02_0788_060B_035_FC")
#$dsList = @("GRB_HUM_PROD_C02_0788_0557_025_FC")
$dsList = @("GRB_HUM_PROD_C02_IBM_BTX30_003_004_DATA"),@("GRB_HUM_PROD_C02_IBM_BTX30_103_005_DATA"),@("GRB_HUM_PROD_C02_IBM_BTX30_004_006_DATA"),@("GRB_HUM_PROD_C02_IBM_BTX30_104_007_DATA"),@("GRB_HUM_PROD_C02_IBM_BTX30_005_008_DATA"),@("GRB_HUM_PROD_C02_IBM_BTX30_105_009_DATA")
"Starting" 
(Get-Date).ToString() 
foreach ($dsname in $dsList) {
	$sheetCounter ++
	$intRowCounter = 1
	$dsnum = $dsname.Substring(27,3)
	$WorkSheet = $WorkBook.Sheets.item($sheetCounter)
	$WorkSheet.name = $dsnum
	$ds = Get-Datastore $dsname| %{Get-View $_.Id}
	$fileQueryFlags = New-Object VMware.Vim.FileQueryFlags 
	$fileQueryFlags.FileSize = $true
	$fileQueryFlags.FileType = $true
	$fileQueryFlags.Modification = $true
	$searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
	$searchSpec.details = $fileQueryFlags
	$searchSpec.sortFoldersFirst = $true
	$searchSpec.MatchPattern = "*.vmdk"
 	$dsBrowser = Get-View $ds.browser
 #$rootPath = "[ $ds.summary.Name ]"
	$rootPath = "[$dsname]"
	$searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)
	$dsname
	(Get-Date).ToString() 
	foreach ($folder in $searchResult) {
		foreach ($fileResult in $folder.File) {

		$file = "" | select Name, Size, Modified, FullPath, ParentID
		$file.Name = $fileResult.Path
		$file.Size = $fileResult.Filesize
		$file.Modified = $fileResult.Modification
		$file.FullPath = $folder.FolderPath + $file.Name
		$file.ParentId = $fileResult.ParentId
		$WorkSheet.cells.item($intRowCounter, 1) = $file.Name
		$WorkSheet.cells.item($intRowCounter, 2) = $file.FullPath
		$WorkSheet.cells.item($intRowCounter, 3) = $file.Size
		$WorkSheet.cells.item($intRowCounter, 4) = $file.Modified
		$WorkSheet.cells.item($intRowCounter, 5) = $file.ParentId
		$intRowCounter++
		#$file | out-file "C:\temp\vmdkinfo.txt" -Append
		}
	}
	$usdRange = $WorkSheet.UsedRange
	$selRange = $WorkSheet.Range("C1")
	$usdRange.Sort($selRange,1)
	$WorkSheet = $WorkBook.Sheets.Add([System.Reflection.Missing]::Value,$WorkBook.Sheets.item($WorkBook.Sheets.count))
}
$s12 = $WorkBook.Sheets | where {$_.name -eq "Sheet12"}
$s12.delete()
(Get-Date).ToString() 
"Done"
$WorkBook.SaveAs($xlpath)
$WorkBook.Save
$WorkBook.Close()
$objExcel.Quit()
Send-MailMessage -To "John Tappa <jtappa@humana.com>" -From "John Tappa <jtappa@humana.com>" -Subject "Linked Clone VMDK spreadsheet" -Body "Linked Clone VMDK file info" -Attachments "C:\temp\VMDKFileInfo.xlsx" -Smtpserver "pobox.humana.com" 
