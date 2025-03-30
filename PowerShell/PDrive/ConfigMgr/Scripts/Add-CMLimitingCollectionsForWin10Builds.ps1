$Builds = @(
    ('1511','10.0.10586'),
    ('1607','10.0.14393'),
    ('1703','10.0.15063'),
    ('1709','10.0.16299'),
    ('1803','10.0.17134')
)

$Builds | ForEach-Object {
    $Ver = $_[0]
    $Build = $_[1]
    $CollName = "All Non-HGB Windows 10 $Ver Physical and Virtual Workstations"
    $Sched = New-CMSchedule -RecurCount 1 -RecurInterval Days -Start '01/01/2018 06:00 AM'
    New-CMDeviceCollection -LimitingCollectionId WP101931 -Name $CollName -RefreshSchedule $Sched | Move-CMObject -FolderPath 'WP1:\DeviceCollection\Limiting Collections'
    Add-CMDeviceCollectionQueryMembershipRule -CollectionName $CollName -RuleName 'Builds' -QueryExpression "select *  from  SMS_R_System where SMS_R_System.Build = `"$Build`""
}