$WKIDS = Get-Content -Path C:\CIS_TEMP\WKIDs.txt
Foreach ($WKID In $WKIDS) {
    IF (Test-Connection -ComputerName $WKID -Count 1 -TimeToLive 120 -Quiet -ErrorAction SilentlyContinue) {
        $SRC = Get-Content -Path "\\$WKID\C$\Windows\CCM\Logs\execmgr*.log" | Select-String -Pattern "Request a MTC task for execution request of package WP10062C"
        If ($SRC -ne $null) {
            Write-Host "$WKID tried" -ForegroundColor Green
        }
        Else {
            Write-Host "$WKID did not try" -ForegroundColor Red >> C:\CIS_TEMP\IPUNOTRY.txt
        }
    }
}