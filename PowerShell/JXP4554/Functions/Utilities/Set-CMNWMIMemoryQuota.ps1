Function Set-CMNWMIMemoryQuota
{
    [CmdletBinding(SupportsShouldProcess = $true, 
	    ConfirmImpact = 'Low')]
    PARAM
    (
	    [Parameter(Mandatory = $false)]
	    [String[]]$ComputerNames = [Array]$env:COMPUTERNAME,

	    [Parameter(Mandatory = $false)]
	    [Int32]$Memory = 1024,

	    [Parameter(Mandatory = $false)]
	    [Switch]$RestartServices
    )

    foreach($ComputerName in $ComputerNames)
    {
	    if (Test-Connection -ComputerName $ComputerName -Count 1 -ErrorAction SilentlyContinue)
	    {
			Write-Output "Fixing $ComputerName"
		    $ProviderHostQuotaConfiguration = Get-WmiObject -ComputerName $ComputerName -Class __ProviderHostQuotaConfiguration -Namespace root
		    $ProviderHostQuotaConfiguration.MemoryPerHost = $Memory * 1048576
		    $ProviderHostQuotaConfiguration.Put()
		    if($PSBoundParameters['RestartServices'])
		    {
			    Get-Service -ComputerName $ComputerName -Name Winmgmt | Stop-Service -Force
			    Get-Service -ComputerName $ComputerName | Where-Object {$_.StartType -match 'Auto' -and $_.Status -ne 'Running'} | Start-Service
		    }
	    }
    }
}
<#

$src = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWPS1658
$WMIQueryParameters =  $src.WMIQueryParameters
$Query = "Select * from SMS_FullCollectionMemberShip where CollectionID = 'WP102ED4'"
Set-CMNWMIMemoryQuota -ComputerNames ((Get-WmiObject -Query $Query @WMIQueryParameters).Name) -RestartServices
#>