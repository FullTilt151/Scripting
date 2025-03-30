Get-CMCollectionMember -CollectionId WP106969 | ForEach-Object{
    $process = Get-WmiObject -ComputerName $($_.name) win32_process -Filter "Name = '<process name goes here>'"
    $Process.Terminate()
}
