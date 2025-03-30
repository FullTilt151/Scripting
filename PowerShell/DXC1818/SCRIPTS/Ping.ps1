#Requires -Version 7.0
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.')
$InputPath = "filesystem::C:\CIS_Temp\WKIDs.txt"
Start-Process notepad C:\CIS_Temp\WKIDs.txt -Wait

$wkids = Get-Content -Path $InputPath
$wkids | ForEach-Object {
    If (Test-Connection -ComputerName $_ -Count 1 -TimeoutSeconds 2 -Quiet -ErrorAction SilentlyContinue) {
        Write-Host "$_ , " -NoNewline
        $IP = Test-Connection -ComputerName $_ -Count 1
        Write-Host $IP.Address
    }
    Else {
        Write-Host "$_ , Offline" -ForegroundColor Red -BackgroundColor Black
    }
}   