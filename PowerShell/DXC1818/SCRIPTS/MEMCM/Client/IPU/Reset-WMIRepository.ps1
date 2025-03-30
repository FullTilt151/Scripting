#Requires -Version 7.0
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

#Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\ConfigurationManager.psd1'

$wkids = Get-Content -Path $InputPath
#ForEach ($_ in $wkids) {
$wkids | ForEach-Object -Parallel {
    if (Test-Connection -ComputerName $_ -Count 2 -ErrorAction SilentlyContinue) {
        #$Reposize = (Get-ItemProperty \\$_\c$\Windows\System32\wbem\Repository\OBJECTS.DATA -ErrorAction Continue | Select-Object -ExpandProperty Length)/1024/1024
        Invoke-Command -ComputerName $_ -ScriptBlock {
            $Reposize = (Get-ItemProperty c:\windows\system32\wbem\Repository\OBJECTS.DATA -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length)/1024/1024
            if ($Reposize -gt 300) {
                Write-Output "$env:COMPUTERNAME - $Reposize MB"
                Write-Output "Stopping WMI"
                $id = Get-CimInstance -Class Win32_Service -Filter "Name LIKE 'Winmgmt'" | Select-Object -ExpandProperty ProcessId
                Stop-Process -Id $id -Force
                Start-Process -FilePath "c:\windows\system32\wbem\WinMgmt.exe" -ArgumentList "/resetrepository" -Wait
                Write-Output "Performing ccmrepair" 
                Start-Process C:\windows\ccm\ccmrepair.exe
                Write-Output "Starting CCMExec" 
                Get-Service -Name CcmExec | Start-Service -PassThru
            }
        }
        #$Reposize
        <#if ($Reposize -gt 500) {
            Push-Location WP1:
            Write-Output "Removing $_ from WP1" 
            Get-CMDevice -Name $_ | Remove-CMDevice -Force
            Pop-Location
            #Add scheduled task
            Invoke-Command -ComputerName $_ -ScriptBlock {
                $TS = New-TimeSpan -Days 0 -Hours 1 -Minutes 00
                $StartTime = (Get-Date) + $TS
                Add-Content -Path C:\Temp\SchTsk_DDR.ps1 -Value 'Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}" | Out-Null 
                Unregister-ScheduledTask -TaskName "DDR" -Confirm:$False'
                $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '–ExecutionPolicy Bypass "C:\Temp\SchTsk_DDR.ps1"'
                $trigger = New-ScheduledTaskTrigger -Once -At $StartTime
                Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "DDR" -Description "Run DDR" -Force -User SYSTEM -RunLevel "Highest"
                }
        }#>
    }
}
