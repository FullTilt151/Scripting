Function Get-CMNClientServiceWindow {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $false)]
        [String]$ComputerName = $env:COMPUTERNAME
    )
    $ReturnObject = New-Object System.Collections.ArrayList
    $ServiceWindows = Get-WmiObject -ComputerName $ComputerName -Class CCM_ServiceWindow -Namespace root\ccm\ClientSDK
    foreach ($ServiceWindow in $ServiceWindows) {
        $Duration = ($ServiceWindow.Duration / 60)
        $StartTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($ServiceWindow.StartTime)
        $EndTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($ServiceWindow.EndTime)
        switch ($ServiceWindow.Type) {
            1 {$Type = 'All Programs Service Window'}
            2 {$Type = 'Program Service Window'}
            3 {$Type = 'Reboot Required Service Window'}
            4 {$Type = 'Software Update Service Window'}
            5 {$Type = 'OSD Service Window'}
            6 {$Type = 'Non-working hours (Set in Software Center)'}
        }
        $ReturnHashTable = @{
            ID = $ServiceWindow.ID
            Duration = $Duration;
            StartTime = $StartTime;
            EndTime = $EndTime;
            Type = $Type;
        }
        $ReturnObject.Add($ReturnHashTable) | Out-Null
    }
    #$obj = New-Object -TypeName PSObject -Property $ReturnObject
    #$obj.PSObject.TypeNames.Insert(0,'CMN.ClientServiceWindow')
    Return $ReturnObject
}#End Get-CMNClientServiceWindow
