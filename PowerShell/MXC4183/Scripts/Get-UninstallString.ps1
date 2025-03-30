param (
    [Parameter(Mandatory=$true)]
    [string]$WKID,
    [Parameter(Mandatory=$true)]
    [string]$App
)
$App = "*$App*"

Invoke-Command -ComputerName $WKID -ScriptBlock { 
    Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | 
    Get-ItemProperty | Where-Object {$_.DisplayName -like "$Using:App*" } | 
    Select-Object -Property DisplayName, DisplayVersion, InstallSource, UninstallString
}

