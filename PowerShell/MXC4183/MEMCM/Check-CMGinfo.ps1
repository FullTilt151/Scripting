Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'

Invoke-Command -ComputerName WKMPMP19VULT -ScriptBlock {
    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'
    Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM'
}

Invoke-Command -ComputerName WKMPMP19VULT -ScriptBlock {
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin' -name "autoWorkplaceJoin" -Value '1'
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM' -name "DisableRegistration" -Value '0'
}



# Check and Set reg keys incase GPO missed.
if((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin').autoWorkplaceJoin -ne '1'){
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin' -name "autoWorkplaceJoin" -Value '1'

}elseif((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM').DisableRegistration -ne '0'){
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM' -name "DisableRegistration" -Value '0'}

Invoke-Command -ComputerName WKPF2E9P7T -ScriptBlock { gpupdate /force}