Import-module ActiveDirectory  
$user_List = 'users.csv'
$users = import-csv $user_List -Header @("uid","OldADGroup","NewADGroup")
$UIDCount = 0       #Init the UID Counter.
$Error.Clear()     #Clear the Error array.

#Setup the Excel Workbook for results.
$excel=new-object -com excel.application
$workbook = $excel.Workbooks.Add()
$WorkSheet= $workbook.Worksheets.Item('Sheet1')
$Worksheet.Name =(get-date).Year.ToString() + '-'+ (get-date).Day.ToString()+'-'+ (get-date ).Month.ToString()
$excel.visible = $True

#Set the width of the columns appropriate to the output.  
$range = $Worksheet.Columns.Item(1)
$range.ColumnWidth = 16
$range.HorizontalAlignment = 3
$range = $Worksheet.Columns.Item(2)
$range.ColumnWidth = 32
$range.HorizontalAlignment = 3

#Write the column headings. 
$Worksheet.cells.Item(1,1) = "User Name"
$Worksheet.cells.Item(1,2) = "Status"

#Set the name for the Workbook name and save it.
$DateTime = Get-Date -Format yyyy-MM-dd--hh-mm-sstt
$workbook.SaveAs("ADGroupMove" + $DateTime)

foreach ($row in $users) {
    Write-Host $row.uid "- Information being retrieved."
    $UIDCount++                 #Keep a count of the User ID in process.  Used to locate ouput row in Workbook.
    $Worksheet.cells.Item($UIDCount + 1,1) = $row.uid     #Write User ID to the Workbook.
    $user = Get-ADUser $row.uid
    Remove-ADGroupMember -Identity $row.OldADGroup -Members $user -Confirm:$false
    Add-ADGroupMember -Identity $row.NewADGroup -Members $user -Confirm:$false

        if ($error.count -gt 0)   #Test if the addition of AD account to group was successful or not. Report the results. 
            {
            Write-Host $row.uid "Removal/Add of AD User Failed"
            $Worksheet.cells.Item($UIDCount + 1,2).Font.ColorIndex = 3  #3 is Red
            $Worksheet.cells.Item($UIDCount + 1,2) = "Removal/Add of AD User Failed"
            $Error.Clear()     #Clear the Error array.
            }
        else
            {
            $Worksheet.cells.Item($UIDCount + 1,2).Font.ColorIndex = 4  #4 is Green
            $Worksheet.cells.Item($UIDCount + 1,2) = "AD User removed/added successfully"
            }
}