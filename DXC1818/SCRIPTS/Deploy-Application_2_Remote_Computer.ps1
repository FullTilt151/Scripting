param(
    [Parameter(Mandatory = $true)]
    [string]$usr
    ,
    [Parameter(Mandatory = $true)]
    [string]$pkg
)
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$cred = Get-Credential humad\$usr
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait


#BT 7.8.8 - 70074
#DG Uninstaller - 64023
#FireEye HX Agent 32.30.13 - 68089
#ThousandEyes Enterprise Agent 1.40.0-Grp3 - 67628
#WinMagic - 67896
#McAfee ePO Agent - 67145
#McAfee MOVE - 67147
#Qualys Cloud Agent 4.2.0.8 - 68814
#Zscaler Client Connector 3.4.0.124 - 69133

#1E Client 5.2.5.523 - 69799
#Cisco AnyConnect Secure Mobility Client 4.10.01075 - 69237
#DG Terminate - 64024
#Fiddler - 60457
#WinPCap - 60096
#WireShark - 69313
#SysTrack Systems Management Agent 10.0.0.46 - 69957
#VMware Workstation 14.1.3 - 63117


Write-Host "Enter: Install or Uninstall"
$Action = Read-Host "Select an action"
Switch ($Action)
{
    Install {
        $wkids = Get-Content -Path $InputPath
ForEach ($wkid in $wkids) {
    IF (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
        $sess = New-PSSession -ComputerName "$wkid.humad.com"
        #Enter-PSSession -Session $sess
        Invoke-Command -Session $sess -Scriptblock {
            Enable-WSManCredSSP Server -ErrorAction SilentlyContinue -Force
        }
        Remove-PSSession $sess

        Enable-WSManCredSSP Client –DelegateComputer "$wkid.humad.com" -ErrorAction SilentlyContinue -Force
        IF ($? -eq $false) {
            Enable-WSManCredSSP Client –DelegateComputer "$wkid.humad.com" -ErrorAction SilentlyContinue -Force
        }
        $sesscred = New-PSSession "$wkid.humad.com" -Authentication CredSSP -Credential $cred
        Invoke-Command -Session $sesscred -Scriptblock {
                Robocopy \\lounaswps08\idrive\D907ATS\$Using:pkg C:\Temp\CRs\$Using:pkg *.* /E /Z
                New-Item "C:\Temp\CRs\$Using:pkg\Install.cmd" -Force
                Add-Content -Path "C:\Temp\CRs\$Using:pkg\Install.cmd" -Value "C:\Temp\CRs\$Using:pkg\install\Deploy-Application.exe -DeployMode Silent" -ErrorAction SilentlyContinue
                }
        }
        Remove-PSSession $sesscred
        Write-Host "$wkid.humad.com" -ForegroundColor 'Green'
        Invoke-Command -ComputerName $wkid -ScriptBlock {cmd /s /c "C:\Temp\CRs\$Using:pkg\Install.cmd"
            #Remove-Item -Path "C:\Temp\CRs\$Using:pkg\Install.cmd" -ErrorAction SilentlyContinue
        }
}
    }
    Uninstall {
        $wkids = Get-Content -Path $InputPath
ForEach ($wkid in $wkids) {
    IF (Test-Connection -ComputerName $wkid -Quiet -ErrorAction SilentlyContinue) {
        $sess = New-PSSession -ComputerName "$wkid.humad.com"
        #Enter-PSSession -Session $sess
        Invoke-Command -Session $sess -Scriptblock {
            Enable-WSManCredSSP Server -ErrorAction SilentlyContinue -Force
        }
        Remove-PSSession $sess

        Enable-WSManCredSSP Client –DelegateComputer "$wkid.humad.com" -ErrorAction SilentlyContinue -Force
        IF ($? -eq $false) {
            Enable-WSManCredSSP Client –DelegateComputer "$wkid.humad.com" -ErrorAction SilentlyContinue -Force
        }
        $sesscred = New-PSSession "$wkid.humad.com" -Authentication CredSSP -Credential $cred
        Invoke-Command -Session $sesscred -Scriptblock {
                Robocopy \\lounaswps08\idrive\D907ATS\$Using:pkg C:\Temp\CRs\$Using:pkg *.* /E /Z
                New-Item "C:\Temp\CRs\$Using:pkg\uninstall.cmd" -Force
                Add-Content -Path "C:\Temp\CRs\$Using:pkg\uninstall.cmd" -Value "C:\Temp\CRs\$Using:pkg\install\Deploy-Application.exe uninstall" -ErrorAction SilentlyContinue
                }
        }
        Remove-PSSession $sesscred
        Write-Host "$wkid.humad.com" -ForegroundColor 'Green'
        Invoke-Command -ComputerName $wkid -ScriptBlock {cmd /s /c "C:\Temp\CRs\$Using:pkg\Uninstall.cmd"
            #Remove-Item -Path "C:\Temp\CRs\$Using:pkg\Install.cmd" -ErrorAction SilentlyContinue
        }
}
    }
    default {
        'No Action'
    }
}

Remove-Item -Path C:\temp\wkids.txt -ErrorAction SilentlyContinue

