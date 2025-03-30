$WKID = Read-Host "Enter the Computer Name"

Invoke-Command -ComputerName $WKID -ScriptBlock {
    Write-Host "Reason for Non-Compliance:" -ForegroundColor Yellow -BackgroundColor Black
    (Get-CimInstance -Class mbam_Volume -Namespace root\microsoft\mbam).ReasonsForNoncompliance
    Write-Output "https://docs.microsoft.com/en-us/mem/configmgr/protect/tech-ref/bitlocker/non-compliance-codes"
    Write-Host "The desired OSManageNKP setting is 1" -ForegroundColor Yellow -BackgroundColor Black
    Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\FVE -Name OSManageNKP
    Write-Host "The desired MBAMPolicyEnforced setting is 1" -ForegroundColor Yellow -BackgroundColor Black
    Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MBAM -Name MBAMPolicyEnforced
    $TPM = Get-CimInstance -Namespace "root\cimv2\security\microsofttpm" -Class win32_tpm | Select-Object SpecVersion
    Write-Host "TPM = $TPM" -ForegroundColor Yellow -BackgroundColor Black
    manage-bde -protectors -get c:
    Write-Host "Match the result to Certificate Thumbprint: from Manage-BDE output above" -ForegroundColor Yellow -BackgroundColor Black
    Reg query HKLM\SOFTWARE\Policies\Microsoft\SystemCertificates\FVE_NKP\Certificates
}
#$LogName = 'Microsoft-Windows-BitLocker/BitLocker Management'
#$StartTime=Get-Date -Year 2020 -Month 6 -Day 25 -Hour 22 -Minute 00
#$EndTime=Get-Date -Year 2020 -Month 6 -Day 26 -Hour 6 -Minute 00
#Get-WinEvent -ComputerName $WKID -FilterHashtable @{
#LogName="$LogName";
#StartTime=$StartTime;EndTime=$EndTime;
#} | Format-List