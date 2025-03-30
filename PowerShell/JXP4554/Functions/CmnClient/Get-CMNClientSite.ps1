Function Get-CMNClientSite {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$MachineName
    )
    $query = "Select * from SMS_R_System where NetBiosName = '$MachineName' and Client =  1 and Obsolete = 0"
    $deviceSP1 = Get-WmiObject -Query $query @WMIQueryParametersSP1
    $deviceSQ1 = Get-WmiObject -Query $query @WMIQueryParametersSQ1
    $deviceWP1 = Get-WmiObject -Query $query @WMIQueryParametersWP1
    $deviceWQ1 = Get-WmiObject -Query $query @WMIQueryParametersWQ1
    $deviceMT1 = Get-WmiObject -Query $query @WMIQueryParametersMT1
    if ($deviceSP1 -or $deviceSQ1 -or $deviceWP1 -or $deviceWQ1 -or $deviceMT1) {
        if ($deviceSP1) {$Message = 'SP1'}
        elseif ($deviceSQ1) {$Message = 'SQ1'}
        elseif ($deviceWP1) {$Message = 'WP1'}
        elseif ($deviceWQ1) {$Message = 'WQ1'}
        elseif ($deviceMT1) {$Message = 'MT1'}
        else {$Message = 'Error'}
    }
    else {$Message = 'No Client'}
    return $Message
}#End Get-CMNClientSite
