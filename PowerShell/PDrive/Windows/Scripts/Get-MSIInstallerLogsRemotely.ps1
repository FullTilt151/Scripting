param(
$Computer,
$Outputcsv
)

$installs = Get-EventLog -ComputerName $Computer -LogName Application -Source MsiInstaller

## Display in console
$installs | Format-Table -Property MachineName,Source,EntryType,TimeGenerated,Message -AutoSize

if ($Outputcsv) {
    ## Output to .csv
    $installs | Select-Object MachineName,Source,EntryType,TimeGenerated,Message | export-csv c:\temp\msi.csv -NoTypeInformation
}