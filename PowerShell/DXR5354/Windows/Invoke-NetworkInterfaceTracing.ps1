#Clear old log files
Get-ChildItem -Path "C:\NLA\*.log" -Recurse -File | Where-Object CreationTime -lt  (Get-Date).AddDays(-15) | Remove-Item -Force
#Get adapters
$InterfaceGuid = Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object -ExpandProperty InterfaceGuid
$datetime = Get-Date -Format "MMddyyy_HHmm"
$EvtTime = (Get-Date).AddMinutes(-1).ToString("MM/dd/yyy HH:mm")
#Find connection in EventLog
$LogMess = Get-WinEvent -LogName "Microsoft-Windows-NetworkProfile/Operational" | Where-Object { $_.Id -eq '4001' } | Select-Object -Property Message, TimeCreated | Select-Object -First 1

    Write-Output "Interface GUID and Eventlog time: $InterfaceGuid, $EvtTime" | Out-File "C:\NLA\NetIPConfig_$datetime.log"
    New-Item -Path C:\ -Name NLA -ItemType Directory -Force
    Get-NetIPConfiguration | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
    $GetAdapterName = Get-NetAdapter -InterfaceDescription "Array*"
    $AdapterName = $GetAdapterName.Name
    $Results = Get-NetConnectionProfile -InterfaceAlias "$AdapterName"
    $NetCat = $Results.NetworkCategory
    $IntAlias = $Results.InterfaceAlias
    Get-NetIPInterface | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber 
    #Get-NetIPInterface -InterfaceAlias $IntAlias | Set-NetIPInterface -InterfaceMetric 10
    Write-Output "Status = $NetCat" | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
    If ($NetCat -inotmatch 'DomainAuthenticated') {
        Write-Output "Status = Not Domain Authenticated" | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
        Copy-Item -Path "C:\Program Files\Array Networks\SSL VPN Client\Logger2.exe"  -Destination "C:\NLA" -Force
        netsh trace start capture=yes  scenario=netconnection,VpnClient  tracefile=C:\NLA\NetTrace.etl overwrite=no maxsize=2048 level=0xff persistent=yes
        Start-Process -FilePath "C:\NLA\Logger2.exe"  -WindowStyle Hidden
        
            Write-Output "Stop Network List Services" | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
            $id = Get-WmiObject -Class Win32_Service -Filter "Name LIKE 'netprofm'" | Select-Object -ExpandProperty ProcessId
            Stop-Process -Id $id -Force -PassThru | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
            Write-Output "Restart Network Location Awareness" | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
            Restart-Service -Name NlaSvc -Force -PassThru | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
		    Start-Sleep -s 10
            $Results = Get-NetConnectionProfile -InterfaceAlias "$AdapterName"
            $NetCat = $Results.NetworkCategory
        
        Write-Output "Status = $NetCat" | Out-File "C:\NLA\NetIPConfig_$datetime.log" -Append -NoClobber
        Netsh trace stop
        #."C:\NLA\ConvertEtl-ToPcap.ps1" -Path "C:\NLA\NetTrace.etl" -Destination "C:\NLA\NetTrace.pcap"
    }