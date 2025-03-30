$VMList_File = "C:\temp\vmlist.csv"
import-csv $VMList_File | ForEach-Object {

    $NewName = $_.NewName
        shutdown-VMGuest -vm $NewName -Confirm:$false
        write-host "Shutting down $NewName" -ForegroundColor Green
        }
