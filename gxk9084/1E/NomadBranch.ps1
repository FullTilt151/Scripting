Write-Output "This needs to be ran with Administrative rights"
#
$machines = Get-Content -Path "C:\temp\wkids.txt"
$OutputPath = "C:\TEMP\nomadBranchEXERan"
#
$machines |
    ForEach-Object {
    Write-Output $_
    IF (Test-Connection -Computername $_ -count 2 -ErrorAction SilentlyContinue) {
        Invoke-Command -ComputerName $_ -ScriptBlock{Nomadbranch.exe -ActivateAll}
        
    }
    Else {$Offline = "$_ is offline"}
  }