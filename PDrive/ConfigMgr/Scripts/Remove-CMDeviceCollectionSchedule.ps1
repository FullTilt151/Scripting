$i = 0
Get-CMCollection | Select-Object CollectionId, Name, RefreshType, CollectionRules |
ForEach-Object {
    $CollRules = $_ | Select-Object -ExpandProperty CollectionRules
    if ($_.RefreshType -in (2) -and $CollRules.SmsProviderObjectPath -notcontains 'SMS_CollectionRuleQuery' -and $_.Name -notlike '*Limiting Collection' -and $_.Name -notlike '*Security Collection') {
        "$($_.CollectionID),$($_.Name),$($_.RefreshType)" | Out-File c:\temp\CollectionsScheduleRemoved.csv -Append
        Set-CMCollection -CollectionId $_.CollectionID -RefreshType Manual
        $i++
    }
}

Write-Output "Modified $i collections!"