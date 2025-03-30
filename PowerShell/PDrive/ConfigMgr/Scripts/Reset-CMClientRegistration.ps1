param(
$ComputerName
)

Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    Get-Process CcmExec | Stop-Process -Force
    Remove-Item C:\windows\SMSCFG.INI -Force
    Get-ChildItem Cert:\LocalMachine\SMS -Recurse | Remove-Item -Force
    Start-Service CcmExec
}