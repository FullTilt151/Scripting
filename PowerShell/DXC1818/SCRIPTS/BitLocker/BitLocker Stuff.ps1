#Policy Exclusion to BitLocker NO PIN collection
Start-Process notepad C:\CIS_Temp\WKIDs.txt -Wait
$WKIDS = Get-Content -Path C:\CIS_TEMP\WKIDs.txt
Foreach ($WKID In $WKIDS) {
    IF (Test-Connection -ComputerName $WKID -Count 1 -TimeToLive 120 -Quiet -ErrorAction SilentlyContinue) {
        $LOC = Get-Location
        If ($LOC.Path -ne "WP1:\") {
            $Drives = Get-PSDrive
            If ($Drives.Name -ne "WP1") {
                Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue
                Set-Location "WP1:"
                }
            Set-Location "WP1:"
            $RESRC = Get-CMDevice -Name $WKID
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionId WP109177 -ResourceId $RESRC.ResourceID -Force
            Add-CMDeviceCollectionDirectMembershipRule -CollectionId WP1065BE -ResourceId $RESRC.ResourceID -Force
            Push-Location "C:"
        }
    }
}

#Remove TPM_OsDriveProtector
$WKID = 'WKMJ0FE0N6'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    Unregister-ScheduledTask -TaskName "TPM_OsDriveProtector" -Confirm:$false
    #Get-ScheduledTask | Sort-Object -Property TaskName
}

#Part 1
Get-CimInstance -ComputerName $WKID -Class mbam_Volume -Namespace root\microsoft\mbam
#Get-Service -ComputerName $WKID -Name MBAMAgent | Stop-Service -Force
$WKID = 'WKMJ0FE0TD'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    $Prg = Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object -Property DisplayName, UninstallString | Where-Object -Property DisplayName -EQ "MDOP MBAM"
    $Unin = $Prg.UninstallString
    & cmd /c $Unin /quiet
    Get-CimInstance  Win32Reg_MBAMPolicy  | Remove-CimInstance -Verbose
    manage-bde -off c:
    }

#Part 2
$SVC = Get-Service -ComputerName $WKID -Name MBAMAgent
Invoke-Command -ComputerName $WKID -ScriptBlock {
    IF (!($SVC)) {
        & CMD /C MSIExec.exe /i C:\Windows\CCM\MBAMClient.msi /qn
        }
    manage-bde -protectors -add c: -TPM
    manage-bde -on C:
}

#Check KeyProtector
$WKID = 'WKMJ0E295H'
Foreach ($WKID In $WKIDS) {
    IF (Test-Connection -ComputerName $WKID -Count 1 -TimeToLive 120 -Quiet -ErrorAction SilentlyContinue) {
        Invoke-Command -ComputerName $WKID -ScriptBlock {
            $STAT = Get-BitLockerVolume
            Write-Host "$env:COMPUTERNAME , " -NoNewline -ForegroundColor Gray
            Write-Host $STAT.KeyProtector -ForegroundColor Yellow
        }
    }
    Else {
        Write-Host "$WKID , Is Offline" -ForegroundColor Red
    }
}

#BitLocker Policy
$WKID = 'WKMJ0G4BAX'
Get-CimInstance  Win32Reg_MBAMPolicy -ComputerName $WKID
#Get-Service -Name MBAMAgent -ComputerName $WKID | Restart-Service
Invoke-Command -ComputerName $WKID -ScriptBlock {
    Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE"
    Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement"
}
$RSL = (Get-CimInstance -ComputerName $WKID -Class mbam_Volume -Namespace root\microsoft\mbam).ReasonsForNoncompliance
IF ($RSL -ne $null) {
    Write-Host "Reason for Non-Compliance = $RSL" -ForegroundColor DarkYellow
}

#Force Policy TPMAndPIN
$LOC = Get-Location
If ($LOC.Path -ne "WP1:\") {
    $Drives = Get-PSDrive
    If ($Drives.Name -ne "WP1") {
        Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue # Import the ConfigurationManager.psd1 module 
        Set-Location "WP1:"
    }
    Set-Location "WP1:"
}
#$WKID = 'WKMJ04CMSE'
$WKIDs = Get-CMCollectionMember -CollectionId WP1077BB | Select-Object -ExpandProperty Name
Foreach ($WKID In $WKIDs) {
    IF (Test-Connection -ComputerName $WKID -Count 1 -TimeToLive 120 -Quiet -ErrorAction SilentlyContinue) {
        #((Get-Content -path C:\Temp\WKIDs.txt -Raw) -replace "$WKID", ' ') | Set-Content -Path C:\Temp\WKIDs.txt
        Invoke-Command -ComputerName $WKID -ScriptBlock {
            $PolEnf = Get-CimInstance  Win32Reg_MBAMPolicy -ErrorAction SilentlyContinue
            Write-Host "$env:COMPUTERNAME , " -ForegroundColor Gray -NoNewLine
            Write-Host $PolEnf.MBAMPolicyEnforced
            If ($PolEnf.MBAMPolicyEnforced -ne "1") {
                If (!(Test-Path -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement")) {
                New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement"
                }
                Else {
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name EncryptionMethodWithXtsOs -Value 7
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name EncryptionMethodWithXtsFdv -Value 7
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name EncryptionMethodWithXtsRdv -Value 7
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name EncryptionMethod -Value 4
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name EnableNonTPM -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name UsePartialEncryptionKey -Value 2
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name UsePIN -Value 2
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name DisallowStandardUserPINReset -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name MinimumPIN -Value 8
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name UseAdvancedStartup -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name EnableBDEWithNoTPM -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name UseTPM -Value 2
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name UseTPMPIN -Value 2
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name UseEnhancedPin -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name OSEnablePrebootInputProtectorsOnSlates -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name OSEnablePreBootPinExceptionOnDECapableDevice -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name OSManageNKP -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE" -Name OSAllowSecureBootForIntegrity -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name OSEnforcePolicyPeriod -Value 0
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name UseOSEnforcePolicy -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name UseFddEnforcePolicy -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name FddEnforcePolicyPeriod -Value 0
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name OSDriveProtector -Value 4
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name ShouldEncryptOSDrive -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name ClientWakeupFrequency -Value 15
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name KeyRecoveryOptions -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name KeyRecoveryServiceEndPoint -Value "https://LOUAPPWPS1644.rsc.humad.com:443/SMS_MP_MBAM/CoreService.svc"
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name StatusReportingFrequency -Value 720
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name StatusReportingServiceEndpoint -Value ""
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name UseKeyRecoveryService -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name UseMBAMServices -Value 1
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\FVE\MDOPBitLockerManagement" -Name UseStatusReportingService -Value 0
                    $SVC = Get-Service -Name MBAMAgent -ErrorAction SilentlyContinue
                    #Write-Host "Forcing MBAM on $env:COMPUTERNAME" -ForegroundColor Cyan
                    If ($SVC.Status -ne 'Running') {
                        Write-Host "Installing MDOP MBAM on $env:COMPUTERNAME" -ForegroundColor Magenta
                        & cmd /c MSIExec.exe /i C:\Windows\CCM\MBAMClient.msi /qn
                    }
                    Else {
                        Write-Host  "Restarting MBAM Agent on $env:COMPUTERNAME" -ForegroundColor Yellow
                        Restart-Service -Name MBAMAgent
                    }
                }
            }
        }
    }
    Else {
        Write-Host "$WKID , Is Offline" -ForegroundColor Red
    }
}
Push-Location "C:"