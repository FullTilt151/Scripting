# Create Qualys local account
If (query user | Select-String -Pattern "Qualys") {
    Write-Output "Qualys account already created"
} Else {
    $PW = ConvertTo-SecureString 'Qualys#1' -AsPlainText -Force
    New-LocalUser -Name Qualys -Password $PW -AccountNeverExpires:$true -PasswordNeverExpires:$true
    Add-LocalGroupMember -Group Administrators -Member Qualys
}

# Change Computername
$CMPName = Read-Host "Enter the desired name for this computer!"
Rename-Computer -NewName $CMPName -Force

# Turn off all firewall profiles
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Allow network acces to Admin share
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LocalAccountTokenFilterPolicy" -Value 1

# Enable remote registry
Set-Service RemoteRegistry -StartupType Automatic
Start-Sleep -Seconds 5
Start-Service RemoteRegistry
"Remote registry: $(Get-Service RemoteRegistry | Select-Object -ExpandProperty Status)"

# Enable higher WMI auth level
& winmgmt.exe /standalonehost 6
Restart-Service winmgmt -Force

#Copy Save-OSDBaseImageInventory.ps1
copy \\lounaswps08.rsc.humad.com\pdrive\Dept907.CIT\ConfigMgr\Scripts\BaseImageInventory\Save-OSDBaseImageInventory.ps1 C:\Temp

Shutdown /r /c "The computer will restart in one minute for changes to take effect." /t 60