$computers = ('LOUXDWDEVP0006','LOUXDWDEVP0009','LOUXDWDEVP0011','LOUXDWDEVP0018','LOUXDWDEVP0020','LOUXDWDEVP0025','LOUXDWDEVP0029','LOUXDWDEVP0030','LOUXDWDEVP0049')
foreach($computer in $computers){
    Write-Output "Fixing $computer"
    Invoke-Command -ComputerName $computer -ScriptBlock {Get-Process reg | Stop-Process -Force} -AsJob
}