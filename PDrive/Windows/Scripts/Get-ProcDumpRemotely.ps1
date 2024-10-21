param(
$ComputerName
)

copy-item \\wkmj029cw9\shared\software\psexec.exe c:\temp -Force

if (Test-Connection $ComputerName -Count 1 -ErrorAction SilentlyContinue) {
    Copy-Item \\wkmj029cw9\shared\software\SysinternalsSuite\procdump.exe \\$computername\c$\temp -Force
    Get-WmiObject win32_process -ComputerName $ComputerName -Filter 'Name = "iexplore.exe"' -Property ProcessID | select -ExpandProperty processid | 
    foreach {
        C:\temp\psexec.exe \\$ComputerName c:\temp\procdump.exe /accepteula -ma $_ c:\temp\iexplore_$_.dmp
    }
} else {
    Write-Output "$ComputerName is offline"
}