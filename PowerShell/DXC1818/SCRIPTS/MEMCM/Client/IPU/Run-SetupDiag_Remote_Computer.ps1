$WKID = Read-Host "Enter the Workstation ID"

Robocopy.exe \\LOUNASWPS08\pdrive\Dept907.CIT\OSD\packages\SetupDiag \\$WKID\c$\Temp\SetupDiag /E /Z

Invoke-Command -ComputerName $WKID -ScriptBlock { &"C:\Temp\SetupDiag\SetupDiag.exe" /Output:C:\Temp\SetupDiag\SetupDiagResults.log}
