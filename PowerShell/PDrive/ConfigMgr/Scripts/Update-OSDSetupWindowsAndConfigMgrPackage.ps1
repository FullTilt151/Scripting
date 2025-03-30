# HUMAD

$OldClients = @(
'WP10045A' # 1806
)

$NewPkgID = 'WP1004C0' # 1810

Get-CMTaskSequence | ForEach-Object {
    if ($(Get-CMTaskSequenceStepSetupWindowsAndConfigMgr -TaskSequenceId $_.PackageId | Select-Object -ExpandProperty ClientPackageID) -in $OldClients) {
        "$($_.Name) $($_.PackageId)"
        Set-CMTaskSequenceStepSetupWindowsAndConfigMgr -PackageId $NewPkgID -TaskSequenceId $_.PackageId -Verbose
    }
}

##########################################################################################################################

# HGB

$OldClients = @(
'WP1004C0'
)

$NewPkgID = 'WP10045A'

Get-CMTaskSequence -Name *HGB* | ForEach-Object {
    if ($(Get-CMTaskSequenceStepSetupWindowsAndConfigMgr -TaskSequenceId $_.PackageId | Select-Object -ExpandProperty ClientPackageID) -in $OldClients) {
        "$($_.Name) $($_.PackageId)"
        Set-CMTaskSequenceStepSetupWindowsAndConfigMgr -PackageId $NewPkgID -TaskSequenceId $_.PackageId -Verbose
    }
}