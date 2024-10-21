$WKIDS = Get-Content -Path 'C:\Users\gxk9084\Documents\projects\client Reg\wkids.txt'
foreach ($WKID in $WKIDS){
Write-output $WKID
IF (Test-Connection -Computername $WKID -count 2 -ErrorAction SilentlyContinue) {
 $provmode = Invoke-Command -computername $WKID -command {(Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode).ProvisioningMode}
 #Write-Output "$WKID Provisioning Mode $provmode"
}
Else {$Offline = "$WKID is offline"}

Write-output "$WKID $Offline, $provmode" >> "C:\temp\provmode.txt"
Clear-Variable provmode -ErrorAction SilentlyContinue
Clear-Variable offline -ErrorAction SilentlyContinue
}

















$provmode = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode).ProvisioningMode

if ($provmode -eq "true") {
    Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "SetClientProvisioningMode" $false
    Write-Output "Restarting CCMEXEC service..."
Restart-Service -Name CcmExec -Force
} else {
    Write-Output "Provisioning Mode is off!"
}