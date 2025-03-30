# ./clear-teams.ps1

# Clear MS Teams cache

$challenge = Read-Host "Are you sure you want to delete the Microsoft Teams Cache (Y/N)?"

if ($challenge -eq "Y"){
    Write-Host "Stopping Teams" -ForegroundColor Yellow
    Get-Process -ProcessName Teams | Stop-Process -Force
    Clear-Host
    Write-Host "Teams Stopped, please wait..." -ForegroundColor Green
    
    Start-Sleep -Seconds 5
    Write-Host "Clearing Teams Disk Cache"
    try{
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\application cache\cache" -force | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\blob_storage" -recurse -force | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\cache" | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\databases" -recurse -force | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\gpucache" -force | Remove-Item -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Indexeddb" -recurse -force | Remove-Item -recurse -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\Local Storage" -recurse -force | Remove-Item -recurse -Confirm:$false
        Get-ChildItem -Path $env:APPDATA\"Microsoft\teams\tmp" -recurse -force | Remove-Item -Confirm:$false
    }catch{
        Write-Output $_
    }
    Write-Host "Cleanup Complete." -ForegroundColor Green
}
# Restart Teams
Start-Process $env:LOCALAPPDATA\Microsoft\teams\current\Teams.exe
# To delete the cache for ALL users, change the paths above replacing $env:APPDATA with 'C:\Users\*\AppData'