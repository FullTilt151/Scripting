param(
    [Parameter(Mandatory = $true)]
    [string]$usr
)
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$cred = Get-Credential humad\$usr

$PXEs = "DSIPXEWPW15"
#"DSIPXEWPW12","DSIPXEWPW13","DSIPXEWPW15","DSIPXEWPW21","DSIPXEWPW24","DSIPXEWPW40","DSIPXEWPW56"

ForEach ($PXE in $PXEs) {
    Test-Connection -ComputerName $PXE -Quiet -ErrorAction SilentlyContinue
    $sess = New-PSSession -ComputerName "$PXE.humad.com"
    Invoke-Command -Session $sess -Scriptblock {
        Enable-WSManCredSSP Server -ErrorAction SilentlyContinue -Force
    }
    Remove-PSSession $sess

    Enable-WSManCredSSP Client –DelegateComputer "$PXE.humad.com" -ErrorAction SilentlyContinue -Force
    IF ($? -eq $false) {
        Enable-WSManCredSSP Client –DelegateComputer "$PXE.humad.com" -ErrorAction SilentlyContinue -Force
    }
    $sesscred = New-PSSession "$PXE.humad.com" -Authentication CredSSP -Credential $cred
    Invoke-Command -Session $sesscred -Scriptblock {

        #HUMPXE3-5UN2-187J-8W56-AQK8
        #http://LOUAPPWPS1658.rsc.humad.com/PXELite/PXELiteConfiguration.asmx
        #msiexec ALLUSERS=2 /i "PXELiteLocal.msi" PIDKEY=HUMPXE3-5UN2-187J-8W56-AQK8 CONFIGSERVERURL=http://LOUAPPWPS1658.rsc.humad.com/PXELite/PXELiteConfiguration.asmx REBOOT=REALLYSUPPRESS /qn /L*v c:\temp\1E_PXELiteLocal_3.1.300.log
        Robocopy "\\lounaswps08\pdrive\Dept907.CIT\1E\Repos\PXE Everywhere\3.2.0.56" "C:\Temp\PXE_Everywhere\3.2.0.56" *.* /E /Z
        New-Item "C:\Temp\PXE_Everywhere\3.2.0.56\Install.cmd" -Force
        Add-Content -Path "C:\Temp\PXE_Everywhere\3.2.0.56\Install.cmd" -Value 'msiexec /i "C:\Temp\PXE_Everywhere\3.2.0.56\PXELiteLocal.msi" PIDKEY=HUMPXE3-5UN2-187J-8W56-AQK8 CONFIGSERVERURL=http://LOUAPPWPS1658.rsc.humad.com/PXELite/PXELiteConfiguration.asmx REBOOT=REALLYSUPPRESS /qn /l*v "C:\Temp\Software_Install_Logs\PXELiteLocal3.2.0.56.log"' -ErrorAction SilentlyContinue
        Add-Content -Path "C:\Temp\PXE_Everywhere\3.2.0.56\Install.cmd" -Value 'msiexec /p "C:\Temp\PXE_Everywhere\3.2.0.56\msp-q20742-pxelite.server.accumulated.v3.2.0.56\Msps\Q20742-pxelitelocal.v3.2.0.56.msp" /qn /l*v "C:\Temp\Software_Install_Logs\Q20742-pxelitelocal.v3.2.0.56.log"' -ErrorAction SilentlyContinue
        cmd /s /c "C:\Temp\PXE_Everywhere\3.2.0.56\Install.cmd"
        Start-Sleep -Seconds 60
        Write-Host "$Using:PXE.humad.com" -ForegroundColor 'Green'
        Restart-Service -Name PXELiteServer -Force
    }
}
Remove-PSSession $sesscred

ForEach ($PXE in $PXEs) {
$Ver = REG Query \\$PXE\HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\1E\PXELiteServer /v ProductVersion
Write-Host $PXE = $Ver -ForegroundColor 'Cyan'
}

#Uninstall
#Delete this after uninstall - HKEY_CLASSES_ROOT\Installer\Products\E587981F92544C6469A17E0BBB20A7F2