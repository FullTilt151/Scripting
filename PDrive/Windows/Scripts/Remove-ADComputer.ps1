$LogDate = get-date -format yyyyMMdd-hhmmsstt

$ToBeRemoved = Get-ADComputer -filter {(operatingsystem -eq "Windows 2000 Professional") -or (operatingsystem -eq "Windows XP") -or (operatingsystem -eq "Windows NT")} -Properties Name,CanonicalName, Created, Enabled, LastLogonDate, OperatingSystem | 
where {$_.lastlogondate -eq $null} | Select-Object samaccountname,CanonicalName, distinguishedname, Created, Enabled, LastLogonDate, OperatingSystem

$Date = [DateTime]::Today.AddDays(-365)
$ToBeRemoved = Get-ADComputer -filter {(lastlogondate -le $Date)} -Properties Name,CanonicalName, Created, Enabled, LastLogonDate, OperatingSystem | 
Select-Object samaccountname,CanonicalName, distinguishedname, Created, Enabled, LastLogonDate, OperatingSystem

$ToBeRemoved | Export-Csv c:\temp\AD-Cleanup_$LogDate.csv -NoTypeInformation -Encoding UTF8

foreach ($comp in $ToBeRemoved) {
    $DN = $comp.distinguishedname
    #Remove-ADObject -Identity $DN -Recursive -Verbose
    #Disable-ADAccount -Identity $DN -Verbose
}

<#
ping
RDP
DNS
lastlogon
#>