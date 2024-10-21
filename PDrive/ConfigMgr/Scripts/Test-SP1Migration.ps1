$file = '\\LOUISILON02S\USERDAT01\jxp4554\Documents\SCCM Documentation\Windows-Servers-Missing-From-SCCM-06-23-17.xlsx'
$problemFile = 'http://teams.humana.com/sites/clientit/SCCM/Shared%20Documents/Primary%20Site%20Consolidation/SP1%20Migration/SP1_Migration_FINAL.xlsx'
$excel = New-Object -com excel.application
$workbook = $excel.workbooks.open($File)
$sheet = $workbook.Sheets.Item(2)
$problemWorkbook = $excel.Workbooks.Open($problemFile)
$problemSheet = $problemWorkbook.Sheets.Item(3)
$outFile = "C:\Temp\MissingServers.csv"
$WMIQueryParametersSP1 = @{
	ComputerName = 'LOUAPPWPS1825';
	NameSpace = 'Root/SMS/Site_SP1';}
$WMIQueryParametersSQ1 = @{
	ComputerName = 'LOUAPPWQS1150';
	NameSpace = 'Root/SMS/Site_SQ1';}

if(Test-Path $outFile){Remove-Item $outFile}

# Create hash table of troubled machines. Key = WKID, Value = Issue
$troubleDevices = @{}
 for($yp=2;$yp -le $problemSheet.UsedRange.Rows.Count; $yp++)
{
    Write-Progress -ID 1 -Activity 'Scanning Trouble Sheet' -Status 'Progress->' -PercentComplete (($yp / $problemSheet.UsedRange.Rows.Count) * 100) -CurrentOperation "$yp / $($problemSheet.UsedRange.Rows.Count)"
    $troubleDevices.Add($problemSheet.Cells.Item($yp,1).Value2,$problemSheet.Cells.Item($yp,5).Value2)
}
$problemWorkbook.Close($false)
Write-Progress -ID 1 -Activity 'Scanning Trouble Sheet' -Completed

#We assume the first row is headers, so we skip.

$totalRows = $sheet.UsedRange.Rows.Count-1
For($y=2;$y -le $sheet.UsedRange.rows.Count;$y++)
{
    Write-Progress -ID 1 -Activity 'Scanning Sheet' -Status 'Progress->' -PercentComplete (($y / $sheet.UsedRange.Rows.Count) * 100) -CurrentOperation "$y /$($sheet.UsedRange.Rows.Count)"
	$server = $Sheet.Cells.Item($y,1).Value2
    if($server -match ' '){Write-Host -ForegroundColor Red "$Server Name Invalid"}
    else
    {
        $query = "Select * from SMS_R_System where NetBiosName = '$server' and Client =  1"
        $deviceSP1 = Get-WmiObject -Query $query @WMIQueryParametersSP1
        $deviceSQ1 = Get-WmiObject -Query $query @WMIQueryParametersSQ1
        if($deviceSP1 -or $deviceSQ1){Write-Host -ForegroundColor Green "$server is a client"}
        else
        {
            #See if it's on the problem sheet
            #Write-Output "Not a client, checking problem sheet"
            $isProblem = $false
            $rowCounter = 1
            foreach($troubleDevice in $troubleDevices.GetEnumerator())
            {
                Write-Progress -ID 2 -ParentId 1 -Activity 'Scanning Trouble Sheet' -Status 'Progress->' -PercentComplete (($rowCounter / $troubleDevices.Count) * 100) -CurrentOperation "$rowCounter / $($troubleDevices.Count)"
                $rowCounter++
                if($troubleDevice.Key -eq $server)
                {
                    $isProblem = $true
                    $notes = $troubleDevice.Value
                    break
                }
            }
            Write-Progress -ID 2 -ParentId 1 -Activity 'Scanning Trouble Sheet' -Completed
            if($isProblem){"$server, $notes" | Out-File -FilePath $outFile -Encoding ascii -Append}
            else{$server | Out-File -FilePath $outFile -Encoding ascii -Append}
        }
    }
}
Write-Progress -ID 1 -Activity 'Scanning Sheet' -Completed
$Workbook.Close($false)
$Excel.Quit()
