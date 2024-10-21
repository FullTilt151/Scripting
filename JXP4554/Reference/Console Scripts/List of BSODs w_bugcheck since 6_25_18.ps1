$hash = @{
    LogName='System';
    ProviderName = 'Microsoft-Windows-WER-SystemErrorReporting';
}
Get-WinEvent -FilterHashtable $hash -ErrorAction SilentlyContinue | Where-Object{$_.timecreated -gt $(Get-Date 6/25/2018)} | ForEach-Object {
$message = $_.Message
$start = $message.IndexOf('bugcheck was: ') + 14
"$($_.TimeCreated) $($message.Substring($start,10))"
}