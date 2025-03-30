Write-Output 'Stopping WMI and dependent services'
Stop-Service Winmgmt -Force
Write-Output 'Resetting repository'
winmgmt /resetrepository
Write-Output 'Restarting services'
Get-Service | Where-Object{$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Start-Service