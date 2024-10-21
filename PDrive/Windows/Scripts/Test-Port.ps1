Do{
(new-object Net.Sockets.TcpClient).Connect("LOUMYSLTS06.rsc.humad.com", 3306)
Get-Date
Start-Sleep -Seconds 45
}while(1 -eq 1)
