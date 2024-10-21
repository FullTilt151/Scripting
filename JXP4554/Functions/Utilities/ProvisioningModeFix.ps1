$provmode = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode).ProvisioningMode
$systask = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name SystemTaskExcludes).SystemTaskExcludes

if ($provmode -eq "true") {
    write-warning "Correcting ProvisioningMode..."
    Set-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode -Value "false"
    $provmode = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode).ProvisioningMode
    write-host "Provisioning Mode is"$provmode
} else {
    write-host "Provisioning Mode is"$provmode
}

if ($systask -ne "") {
    write-warning "Correcting SystemTaskExcludes..."
    Set-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name SystemTaskExcludes -Value $null
    $systask = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name SystemTaskExcludes).SystemTaskExcludes
    if ($systask -eq "") {
        write-host "SystemTaskExcludes is blank"
    }
} elseif ($systask -eq "") {
    write-host "SystemTaskExcludes is blank"
} else {
    write-host "SystemTaskExcludes is"$systask
}

write-warning "Restarting CCMEXEC service..."
Restart-Service -Name CcmExec -Force