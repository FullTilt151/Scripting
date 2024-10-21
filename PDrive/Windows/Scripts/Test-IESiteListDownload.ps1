function Get-IESiteList {
    Get-ChildItem -Path C:\Users\dxr5354a\AppData\Local\Microsoft\Windows\INetCache -Filter "ieem*.xml" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty 'HKCU:\Software\Microsoft\Internet Explorer\Main\EnterpriseMode' -Name CurrentVersion -Force
    Start-Process iexplore.exe -WindowStyle Minimized
    Start-Sleep -Seconds 3
    Stop-Process -Name iexplore -Force
}

while ($true) {
    Get-IESiteList
}