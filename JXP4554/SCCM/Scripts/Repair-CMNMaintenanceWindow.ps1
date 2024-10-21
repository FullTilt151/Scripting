[CmdletBinding()]
PARAM(
    [Parameter(Mandatory = $false, HelpMessage = 'Do we ignore maintenance windows?')]
    [switch]$ignoreMW
)
#Get cimclass for future use
$client = Get-CimClass -Namespace Root\CCM -ClassName SMS_Client

$mwInstances = Get-CimInstance -Namespace ROOT\ccm\ClientSDK -ClassName CCM_ServiceWindow -Filter "Type != 6"
if ($mwInstances.Count -ne 0) {
    $inMW = $false
    if ($mwInstances.Count -gt 0) {
        $currentTime = Get-Date
        foreach ($mwInstance in $mwInstances) {
            if ($mwInstance.StartTime -gt $currentTime -and $mwInstance.EndTime -gt $currentTime) {$inMW = $true}
        }
    }
}
else {$inMW = $true}

if ($inMW -or $PSBoundParameters['ignoreMW']) {
    try {
        Write-Output 'Cleaning CCM Temp Dir'
        $ccmTempDir = (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\CCM).TempDir
        if ((Test-Path $ccmTempDir) -and $ccmTempDir -ne $null -and $ccmTempDir -ne '') {Get-ChildItem -Path $ccmTempDir | Where-Object {!$_.PSisContainer} | Remove-Item -Force -ErrorAction SilentlyContinue}
    }
    catch {
        Write-Output "Unable to clear $ccmTempDir"
        Return "Unable to clear $ccmTempDir"
    }

    #Clear out the WMI repository where policy was stored, force refresh
    Write-Output 'Resetting Policy'
    Invoke-CimMethod -CimClass $client -MethodName ResetPolicy -Arguments @{uFlags = 1} | Out-Null

    Restart-Service -Name CcmExec

   try {
        Write-Output 'Refreshing compliance state'
        $sccmClient = New-Object -ComObject Microsoft.CCM.UpdatesStore
        $sccmClient.RefreshServerComplianceState()
    }
    catch {
        Write-Output 'Unable to refresh compliance state'
        Return 'Unable to refresh compliance state'
    }

    try {
        Write-Output 'Running Machine Policy Retrieval & Evaluation Cycle'
        Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000021}'} -ErrorAction SilentlyContinue | Out-Null

        Write-Output 'Running Discovery Data Collection Cycle'
        Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000003}'} -ErrorAction SilentlyContinue | Out-Null

        Write-Output 'Running Hardware Inventory Cycle'
        Invoke-CimMethod -CimClass $client -MethodName TriggerSchedule -Arguments @{sScheduleID = '{00000000-0000-0000-0000-000000000001}'} -ErrorAction SilentlyContinue | Out-Null
    }
    catch {
        Write-Output "Unable to reset $env:COMPUTERNAME"
        Write-Output $Error.
        Return "Unable to reset $env:COMPUTERNAME"
    }

    Return "$env:COMPUTERNAME complete!"
}
else{
    Write-Output "$env:COMPUTERNAME is not currently in it's maintenance window and ignoreMW parameter was not specified, not resetting client"
}