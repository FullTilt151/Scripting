<#
    .SYNOPSIS 
    Disable all scheduled tasks that trigger when the machine goes idle
    
    .DESCRIPTION
    This script uses Get-ScheduledTask to find all scheduled tasks that have triggers for the machine being idle.
    This list is output to c:\temp\Disable_Idle_ScheduledTasks.log for recording purposes. All tasks found are 
    disabled using Disable-ScheduledTask and the script exits. 

    Author: Daniel Ratliff, Client Innovation Technologies
    Date: 03/07/2014
    
    .INPUTS
    None. You cannot pipe objects to Disable_Idle_ScheduledTasks.ps1.

    .OUTPUTS
    This script outputs a list of scheduled tasks to be disabled to c:\temp\Disable_Idle_ScheduledTasks.log

    .EXAMPLE
    .\Disable_Idle_ScheduledTasks.ps1

    .EXAMPLE
    PowerShell.exe -ExecutionPolicy Bypass -File Disable_Idle_ScheduledTasks.ps1
#>

$idletasks = Get-ScheduledTask | Where-Object {$_.Triggers -like "*idle*"}
$idletasks | Format-Table -AutoSize | out-file c:\temp\Disable_Idle_ScheduledTasks.log
$idletasks | foreach { Disable-ScheduledTask -InputObject $_}