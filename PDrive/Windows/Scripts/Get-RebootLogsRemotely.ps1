param(
$Computer,
$Outputcsv,
$Days
)

if ( test-connection $computer -count 1 -erroraction silentlycontinue ) {
    $installs = Get-EventLog -ComputerName $Computer -LogName System -Source User32 -After ((get-date) - (New-TimeSpan -Days $days))

    ## Display in console
    $installs | Format-Table -Property MachineName,TimeGenerated,Message -AutoSize

    if ($Outputcsv) {
        ## Output to .csv
        $installs | Select-Object MachineName,Source,EntryType,TimeGenerated,Message | export-csv c:\temp\msi.csv -NoTypeInformation
    }
} else {
    write-output "$computer is offline!"
}