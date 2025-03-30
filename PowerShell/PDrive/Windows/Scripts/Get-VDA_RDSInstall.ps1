$servers = get-content C:\temp\Servers.txt

foreach ($server in $servers) {
    if ((Test-Connection $server -Count 1 -ErrorAction SilentlyContinue) -or (Get-WmiObject -ComputerName $server win32_operatingsystem -ErrorAction SilentlyContinue) -ne $null) {
        write-host $server" - VDA [" -NoNewline
        $vda = get-childitem "\\$server\C$\Program Files\Citrix\XenDesktopVdaSetup\XenDesktopVdaSetup.exe" -ErrorAction SilentlyContinue
        if ($vda) {
            write-host "X" -NoNewline
        }
        write-host "] RDS [" -NoNewline
        $rds = get-childitem "\\$server\C$\windows\system32\tsappinstall.exe" -ErrorAction SilentlyContinue
        if ($rds) {
            write-host "X" -NoNewline
        }
        write-host "] - " -NoNewline
        $os = Get-WmiObject -ComputerName $server -Namespace root\cimv2 -Class win32_operatingsystem -ErrorAction SilentlyContinue
        $uptime = ($os.ConvertToDateTime($os.LocalDateTime) – $os.ConvertToDateTime($os.LastBootUpTime))
        switch ($os.caption) {
            "Microsoft Windows Server 2008 Enterprise" {$osver = "Server 2008"}
            "Microsoft Windows Server 2008 R2 Enterprise" {$osver = "Server 2008 R2"}
            "Microsoft Windows Server 2008 R2 Enterprise " {$osver = "Server 2008 R2"}
            "Microsoft Windows Server 2012 Standard" {$osver = "Server 2012"}
            "Microsoft Windows Server 2012 Enterprise" {$osver = "Server 2012"}
            "Microsoft Windows Server 2012 R2 Standard" {$osver = "Server 2012 R2"}
            "Microsoft Windows Server 2012 R2 Enterprise" {$osver = "Server 2012 R2"}
            default {$osver = $os.caption}
        }
        write-host $osver" - " -NoNewline
        write-host $uptime.Days"days,"$uptime.hours"hours,"$uptime.Minutes"minutes"
    } else {
        Write-Host $server" is offline"
    }
}