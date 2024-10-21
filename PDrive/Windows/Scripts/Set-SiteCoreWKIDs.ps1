Get-Content C:\temp\wkids.txt |
ForEach-Object {
    $user = $_.split(',')[0]
    $wkid = $_.split(',')[1]
    if (Test-Connection $wkid -Count 1 -ErrorAction SilentlyContinue) {
        Copy-Item \\wkmj059g4b\shared\Add-UserToLocalAdmin.ps1 \\$wkid\c$\temp
        Copy-Item '\\wkmj059g4b\shared\Addlocaladmin.xml' \\$wkid\c$\temp
        $cim = New-CimSession -ComputerName $wkid
        Unregister-ScheduledTask -TaskName 'Add local admin' -TaskPath '\Humana\' -Confirm:$false -CimSession $cim
        Register-ScheduledTask -Xml (Get-Content '\\wkmj059g4b\shared\Addlocaladmin.xml' | out-string) -TaskName "Add local admin" -User 'NT AUTHORITY\SYSTEM' -Force -CimSession $cim -TaskPath '\Humana'
        $Action = New-ScheduledTaskAction -Execute 'c:\windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Argument "-ExecutionPolicy Bypass -File c:\temp\Add-UserToLocalAdmin.ps1 -UserID $user"
        Set-ScheduledTask -TaskName 'Add local admin' -TaskPath '\Humana\' -Action $Action -CimSession $cim
        Start-ScheduledTask -TaskName 'Add local admin' -TaskPath '\Humana\' -CimSession $cim
        Remove-CimSession -CimSession $cim
    } else {
        "$wkid offline"
    }
}