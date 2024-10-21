Get-Content C:\temp\wkids.txt | 
ForEach-Object {
    if (Test-Connection $_ -Count 1 -ErrorAction SilentlyContinue) {
        $Cmver = (Get-ItemProperty "\\$_\c$\Windows\CCM\CcmExec.exe" -ErrorAction SilentlyContinue | select -ExpandProperty VersionInfo).FileVersion
        if ($cmver -ne '5.00.8355.1000 (SCCM.160209-0318)') {
            "$_ $Cmver"
        } else {
            "$_ $Cmver"
            \\wkmj029cw9\shared\software\SysinternalsSuite\psexec.exe \\$_ powershell.exe -executionpolicy bypass "Remove-Item Cert:\LocalMachine\SMS -Recurse -Verbose"
            Get-Service "SMS Agent Host" -ComputerName $_ | Restart-Service -Force
        }
    } else {
        "$_ offline"
    }
}