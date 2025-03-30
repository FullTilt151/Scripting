Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    $hash = @{
        LogName='*'
        StartTime = (get-date '3/31/17 7:30 am')
        EndTime = (get-date '3/31/17 8:15 am')
    }
    Get-WinEvent -FilterHashtable $hash -ComputerName $_ | select MachineName, TimeCreated, ProviderName, LogName, Message | export-csv c:\temp\logs.csv -NoTypeInformation -Append
}