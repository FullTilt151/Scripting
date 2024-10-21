write-host "((( Testing LOUKMSWPS01... )))" -ForegroundColor Cyan
(new-object Net.Sockets.TcpClient).Connect("LOUKMSWPS01", 1688)
write-host "If no errors, connection was successful!`n"
write-host "((( Testing SIMKMSWPS01... )))" -ForegroundColor Cyan
(new-object Net.Sockets.TcpClient).Connect("SIMKMSWPS01", 1688)
write-host "If no errors, connection was successful!"