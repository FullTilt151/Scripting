param(
    [parameter(Mandatory = $true)]
    $ComputerName
)

Invoke-Command -ComputerName $ComputerName -ScriptBlock { 
    $provmode = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode).ProvisioningMode

    if ($provmode -eq "true") {
        Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "SetClientProvisioningMode" $false
        Write-Output "Restarting CCMEXEC service..."
        Restart-Service -Name CcmExec -Force
    }
    else {
        Write-Output "Provisioning Mode is off!"
    }
}