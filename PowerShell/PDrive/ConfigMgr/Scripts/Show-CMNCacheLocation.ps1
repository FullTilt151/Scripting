[CmdletBinding(SupportsShouldProcess = $true, 
	ConfirmImpact = 'Low')]
PARAM
(
	[Parameter(Mandatory = $false)]
	[String[]]$computerNames = [Array]$env:COMPUTERNAME
)

foreach($computerName in $computerNames)
{
	if (Test-Connection -ComputerName $computerName -Count 1 -ErrorAction SilentlyContinue) 
	{
        $cache = Get-WmiObject -ComputerName $computerName -Namespace 'root/CCM/SoftMgmtAgent' -Class CacheConfig
        $message = "$computerName - Cache is in $($cache.Location)"
        if(-not(Test-Path -Path $cache.Location))
        {
            $message += "`tCache location invalid!"
        }
        Write-Output $message
    }
}