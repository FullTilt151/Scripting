param(
    [Parameter(Mandatory = $true)]
    [string]$Days_Old
    )

[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\Temp\WKIDs.txt"
Start-Process notepad C:\Temp\WKIDs.txt -Wait

$WKIDs = Get-Content -Path $InputPath
ForEach ($WKID in $WKIDs) {
    If (Test-Connection -ComputerName $WKID -Count 2 -Quiet -ErrorAction SilentlyContinue) {
        Robocopy '\\LOUNASWPS08\PDRIVE\Dept907.CIT\Windows\Software\Delprof2 1.6.0' \\$WKID\C$\Windows\System32 DelProf2.exe /Z
        Invoke-Command -ComputerName $WKID -ScriptBlock {
            $action = New-ScheduledTaskAction -Execute "DelProf2.exe' -Argument '/d:$Using:Days_Old /q"
            $trigger = New-ScheduledTaskTrigger -Daily -At 2AM
            Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "Remove OLD UserProfiles" -Description "Delete profiles older than $Using:Days_Old days" -Force -User SYSTEM -RunLevel "Highest"
        }
    }
}
Remove-Item -Path C:\Temp\WKIDs.txt -Force