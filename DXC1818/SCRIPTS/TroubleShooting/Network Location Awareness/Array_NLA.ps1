#Clear old log files
Get-ChildItem -Path "C:\Array_Conn\*.log" -Recurse -File | Where-Object CreationTime -lt  (Get-Date).AddDays(-15) | Remove-Item -Force
$NetAdapt = Get-NetAdapter -InterfaceDescription "Array*"
If ($NetAdapt.Status -EQ 'Up') {
    #Get Array adapter
    $InterfaceGuid = Get-NetAdapter -InterfaceDescription "Array*" | Select-Object -ExpandProperty InterfaceGuid
    $datetime = Get-Date -Format "MMddyyy_HHmm"
    $EvtTime = (Get-Date).AddSeconds(-30).ToString("MM/dd/yyy HH:mm")
    #Find Array connection in EventLog
    $LogMess = Get-WinEvent -LogName "Microsoft-Windows-NetworkProfile/Operational" | Where-Object { $_.Id -eq '4001' } | Select-Object -Property Message, TimeCreated | Select-String -Pattern "$InterfaceGuid" | Select-Object -First 1
    $LogTime = $LogMess | Select-String -Pattern "$EvtTime"
    Write-Output "Interface GUID and Eventlog time: $InterfaceGuid, $EvtTime" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log"
    IF ($Logtime -match $LogMess) {
        New-Item -Path C:\ -Name Array_Conn -ItemType Directory -Force
        Get-NetIPConfiguration | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
        $GetAdapterName = Get-NetAdapter -InterfaceDescription "Array*"
        $AdapterName = $GetAdapterName.Name
        $Results = Get-NetConnectionProfile -InterfaceAlias "$AdapterName"
        $NetCat = $Results.NetworkCategory
        $IntAlias = $Results.InterfaceAlias
        Set-NetIPInterface -InterfaceAlias $IntAlias -InterfaceMetric 35
        $NETIPInt = Get-NetIPInterface 
        Write-Output $NETIPInt | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber 
        $ArrayMTR = $NETIPInt | Where-Object InterfaceAlias -EQ "$IntAlias" | Select-Object -ExpandProperty InterfaceMetric
        $Metrics = $NETIPInt | Where-Object ConnectionState -EQ 'Connected' | Where-Object InterfaceAlias -NotMatch "Loopback Pseudo-Interface 1" | Where-Object InterfaceAlias -NotMatch "$IntAlias" | Select-Object -ExpandProperty InterfaceMetric
        Foreach ($Metric in $Metrics) {
            If ($Metric -le $ArrayMTR) {
                Do {
                    $ArrayMTR--
                } Until ($ArrayMTR -lt $Metric)
            }
        }
        Write-Output "Array metric will be set to $ArrayMTR" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
        Set-NetIPInterface -InterfaceAlias $IntAlias -InterfaceMetric $ArrayMTR
        Start-Sleep -s 35
        Get-NetIPInterface | Where-Object InterfaceAlias -EQ $IntAlias | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
        Write-Output "Status = $NetCat" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
        If ($NetCat -inotmatch 'DomainAuthenticated') {
            Write-Output "Status = Not Domain Authenticated" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
            DO {
                Write-Output "Stop Network List Services" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
                $NLSid = Get-WmiObject -Class Win32_Service -Filter "Name LIKE 'netprofm'" | Select-Object -ExpandProperty ProcessId
                Stop-Process -Id $NLSid -Force -PassThru | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
                Start-Sleep -s 5
                Write-Output "Stop Network Location Awareness" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
                $NLAid = Get-WmiObject -Class Win32_Service -Filter "Name LIKE 'NLASvc'" | Select-Object -ExpandProperty ProcessId
                Stop-Process -Id $NLAid -Force -PassThru | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
                Start-Sleep -s 5
                Start-Service -Name NlaSvc -PassThru | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
                Start-Sleep -s 240
                $Results = Get-NetConnectionProfile -InterfaceAlias "$AdapterName"
                $NetCat = $Results.NetworkCategory
            } Until ($NetCat -match 'DomainAuthenticated')
            Write-Output "Status = $NetCat" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
        }
    }
    Else {
        Get-NetIPInterface | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
        Write-Output "Could not match connection time to event time" | Out-File "C:\Array_Conn\NetIPConfig_$datetime.log" -Append -NoClobber
    }
}