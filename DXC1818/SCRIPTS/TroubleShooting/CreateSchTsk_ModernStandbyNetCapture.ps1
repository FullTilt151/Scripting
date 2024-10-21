[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[System.Windows.Forms.MessageBox]::Show('Paste the WKIDs in the notepad that will open automatically.') 
$InputPath = "filesystem::C:\CIS_Temp\WKIDs.txt"
Start-Process notepad C:\CIS_Temp\WKIDs.txt -Wait

$wkids = Get-Content -Path $InputPath
$wkids | ForEach-Object {
    IF (Test-Connection -ComputerName $_ -Count 2 -ErrorAction SilentlyContinue) {
        Invoke-Command -ComputerName $_ -ScriptBlock {
            New-Item -Path C:\ -Name NetCap -ItemType Directory -Force
            Remove-Item -Path "C:\NetCap\*" -Force -Recurse
            New-Item -Path C:\ -Name "NetCap" -ItemType Directory -Force
        }
        Invoke-Command -ComputerName $_ -ScriptBlock {
            #Unregister-ScheduledTask -TaskName "ModernStandby_StartCapture" -Confirm:$False 
            # create TaskEventTrigger, use your own value in Subscription
            $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
            $trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
            $trigger.Subscription = 
            @"
            <QueryList><Query Id="0" Path="System"><Select Path="System">*[System[EventID=506]]</Select></Query></QueryList>
"@
            $trigger.Enabled = $True 
            $triggers += $trigger
            # create task
            $User = 'Nt Authority\System'
            $Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument '
            $datetime = Get-Date -Format "MMddyyy_HHmm";
            netsh trace start scenario=vpnclient_dbg capture=yes report=yes persistent=yes maxsize=2048 filemode=circular tracefile=C:\NetCap\%COMPUTERNAME%_vpntrace_$datetime.etl'
            Register-ScheduledTask -TaskName ModernStandby_StartCapture -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force
            Clear-Variable -Name trigger
            Clear-Variable -Name triggers   

            # create TaskEventTrigger, use your own value in Subscription
            $CIMTriggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
            $trigger = New-CimInstance -CimClass $CIMTriggerClass -ClientOnly
            $trigger.Subscription = 
            @"
            <QueryList><Query Id="0" Path="System"><Select Path="System">*[System[EventID=507]]</Select></Query></QueryList>
"@
            $trigger.Enabled = $True 
            $triggers += $trigger
            # create task
            $User='Nt Authority\System'
            $Action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument '
            netsh trace stop;
            Get-ChildItem -Path "C:\NetCap\*" -Recurse -File | Where-Object CreationTime -lt  (Get-Date).AddDays(-1) | Remove-Item -Force'
            Register-ScheduledTask -TaskName ModernStandby_StopCapture -Trigger $triggers -User $User -Action $Action -RunLevel Highest -Force
            Clear-Variable -Name trigger
            Clear-Variable -Name triggers
        }
    }
}
