Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Push-Location WP1:
$MPs = Get-CMManagementPoint | Select-Object -ExpandProperty NetworkOSPath 
#$MPs = 'LOUAPPWPS1644'
Pop-Location
$MPs |
ForEach-Object {
    $path = "$_\d$\sms\MP\OUTBOXES\stat.box"
    $server = $_.replace('\\','')
    Invoke-Command -ComputerName $server -ScriptBlock {
        #Set-Item WSMan:\localhost\Shell\MaxMemoryPerShellMB 4096 -Force
        $time = Get-Date
        #$count = [System.IO.Directory]::EnumerateFiles('D:\sms\MP\outboxes\stat.box','*.*','AllDirectories') | Measure-Object | Select-Object -ExpandProperty Count
        $count = Get-ChildItem 'd:\sms\MP\outboxes\stat.box' | Measure-Object | Select-Object -ExpandProperty count
        "$time - $using:path - $count files"
    }
}