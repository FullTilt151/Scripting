$WKID = 'WKPF230GEC'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    & cmd /c Logman.exe create counter PerfLog-Short -o "c:\Temp\perflogs\PerfLog-Short.blg" -f bincirc -v mmddhhmm -max 500 -c "\Cache\*" "\LogicalDisk(*)\*" "\Memory\*" "\Network Interface(*)\*" "\Paging File(*)\*" "\PhysicalDisk(*)\*" "\Processor(*)\*" "\Process(*)\*" "\Redirector\*" "\Server\*" "\System\*" "\Server Work Queues\*" "\Thread(*)\*" -si 00:00:05
    & cmd /c Logman.exe start PerfLog-Short
    & cmd /c C:\Windows\System32\wpr.exe -start GeneralProfile -start Power -filemode
    Write-Output 'Waiting for 2 minutes'
    Start-Sleep -Seconds 120
    & cmd /c C:\Windows\System32\wpr.exe -stop c:\Temp\perflogs\%COMPUTERNAME%_highCPU.etl
    Write-Output 'Waiting for 8 minutes'
    Start-Sleep -Seconds 480
    & cmd /c Logman.exe stop PerfLog-Short
    & cmd /c Logman.exe delete PerfLog-Short
    DO {
        $WPR = Get-Process -Name wpr -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
    } UNTIL ($WPR -eq $null)
    Compress-Archive -Path c:\Temp\perflogs\* -DestinationPath c:\Temp\perflogs\$env:COMPUTERNAME.zip
    IF (Test-Path -Path c:\Temp\perflogs\$env:COMPUTERNAME.zip) {
        Remove-Item -Path C:\Temp\perflogs -Exclude *.zip -Recurse -Force
    }
}
New-Item -Path C:\CIS_TEMP\ -Name $WKID -ItemType Directory -ErrorAction SilentlyContinue
Robocopy.exe \\$WKID\C$\Temp\perflogs\ C:\CIS_TEMP\$WKID $WKID.zip /mt /z