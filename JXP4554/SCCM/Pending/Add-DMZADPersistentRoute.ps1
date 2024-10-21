$FileData = Import-Csv -Path C:\temp\DMZAD.csv

$Object = @()
Foreach ($Entry in $FileData) {
    $Object += New-Object PSObject -Property @{
        Name = $Entry.Netbios_Name0
        Gateway = $Entry.Subnet
    }    
}

$cred = Get-Credential

Foreach ($Obj in $Object) {
    if (Test-Connection -ComputerName $obj.Name -Count 1 -ErrorAction SilentlyContinue) {
        if ([bool](Test-WSMan -ComputerName $obj.Name -ErrorAction SilentlyContinue)) {
            psexec.exe -accepteula -nobanner \\$($obj.Name) -n 5 -h -d powershell.exe "Enable-PSRemoting -Force"
        }   
        Invoke-Command -ComputerName $Obj.Name -ScriptBlock {
            Write-Output -Verbose $env:COMPUTERNAME
            route add -p 10.0.0.0 mask 255.0.0.0 $args[0]
        } -ArgumentList $Obj.Gateway -Credential $cred -ErrorAction SilentlyContinue
    }
}