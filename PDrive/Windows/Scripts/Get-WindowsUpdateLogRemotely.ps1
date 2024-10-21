param(
$ComputerName
)

Invoke-Command -ComputerName $ComputerName -ScriptBlock {
    Get-WindowsUpdateLog
}

Copy-Item \\$ComputerName\c$\users\$env:USERNAME\desktop\WindowsUpdate.log c:\temp\WindowsUpdate_$ComputerName.log -Verbose