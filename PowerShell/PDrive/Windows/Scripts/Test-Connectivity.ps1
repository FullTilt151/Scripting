$ErrorActionPreference = 'SilentlyContinue'
Get-Content C:\temp\servers.txt |
ForEach-Object {
    if (Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue) {
        $Ping = $true
    } else {
        $Ping = $false
    }

    if (Test-Path \\$_\c$\windows -ErrorAction SilentlyContinue) {
        $Cdrive = $true    
    } else {
        $Cdrive = $false
    }

    if ((Get-WmiObject win32_logicaldisk -ComputerName $_ -Filter "DriveType='3' and DeviceID = 'D:'" -ErrorAction SilentlyContinue) -ne $null) {
        $DDrive = $true
        #Copy-Item \\lounaswps01\pdrive\Dept907.CIT\ConfigMgr\Packages\Microsoft\ConfigMGR\Client\1702\SP1Setup.cmd \\$_\c$\temp -ErrorAction SilentlyContinue
        #& psexec.exe \\$_ -h -d c:\temp\SP1Setup.cmd -nobanner
    } else {
        $DDrive = $false
        #Copy-Item \\lounaswps01\pdrive\Dept907.CIT\ConfigMgr\Packages\Microsoft\ConfigMGR\Client\1702\SP1Setup_No_D_drive.cmd \\$_\c$\temp -ErrorAction SilentlyContinue
        #& psexec.exe \\$_ -h -d c:\temp\SP1Setup_No_D_drive.cmd -nobanner
    }

    $RDP = (new-object Net.Sockets.TcpClient).Connect($_, 3389)
    if ($RDP -eq $null) {
        $RDP = $true
    } else {
        $RDP = $false
    }

    "$_, $Ping, $Cdrive, $DDrive, $RDP" | Out-File c:\temp\TestConnection.txt -Append
}