
$Format = (Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\perfproc\Performance -Name ProcessNameFormat).ProcessNameFormat

if ($Format -eq 2) {
    ## Create the counter
    & Logman.exe create counter Perflog -f bin -v mmddhhmm -max 500 -c "\LogicalDisk(*)\*" "\Memory\*" "\.NET CLR Memory(*)\*" "\Cache\*" "\Network Interface(*)\*" "\Paging File(*)\*" "\PhysicalDisk(*)\*" "\Processor(*)\*" "\Processor Information(*)\*" "\Process(*)\*" "\Redirector\*" "\Server\*" "\System\*" "\Server Work Queues(*)\*" "\Terminal Services\*" -si 00:00:05

    ## Start the counter
    & Logman.exe start perflog

    ## Stop the counter
    #& Logman.exe stop perflog

    ## Save the tasklist
    & tasklist /svc > C:\tasklist.txt   
} else {
    Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\services\perfproc\Performance -Name ProcessNameFormat -Value 2
    Write-Warning "Restart needed before continuing!"
}