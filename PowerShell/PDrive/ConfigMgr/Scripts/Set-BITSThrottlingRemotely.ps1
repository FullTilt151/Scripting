Get-Content C:\temp\servers.txt | 
ForEach-Object {
    if (Test-Connection -ComputerName $_ -Count 1 -ErrorAction SilentlyContinue) {
        Copy-Item \\louappwps1825\sms_sp1\tools\SetBITSOffhourRate.bat \\$_\c$\temp -Force
        PsExec.exe -accepteula -nobanner -h -n 5 -d -s \\$_ c:\temp\SetBITSOffhourRate.bat
        #pause
    }
}