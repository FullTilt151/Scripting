Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\ConfigurationManager.psd1'

 

Get-Content D:\temp\wkids.txt |
ForEach-Object {
    if (Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue) {
        $Reposize = (Get-ItemProperty \\$_\c$\windows\system32\wbem\Repository\OBJECTS.DATA -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length)/1024/1024
       <# Invoke-Command -ComputerName $_ -ScriptBlock {
            $Reposize = (Get-ItemProperty c:\windows\system32\wbem\Repository\OBJECTS.DATA -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length)/1024/1024
            if ($Reposize -gt 600) {
                "$env:COMPUTERNAME - $Reposize MB"
                Stop-Service Winmgmt -Force
                & c:\windows\system32\wbem\WinMgmt.exe /resetrepository
                Start-Process C:\windows\ccm\ccmrepair.exe
            } else {
                if ((Get-Service CcmExec).Status -ne 'Running') {
                    Start-Service CcmExec -ErrorAction SilentlyContinue
                }
                "$env:COMPUTERNAME - $Reposize MB"
            }
        } #>
        if ($Reposize -gt 600) {
            Push-Location WP1:
            Get-CMDevice -Name $_ | Remove-CMDevice -Force
        }
    }
}