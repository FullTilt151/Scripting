$NLMType = [Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B')
$INLM = [Activator]::CreateInstance($NLMType)
$nConnected  = 1
$NLBDom = 0x02
$INetworks = $INLM.GetNetworks($nConnected)
 
$stopTrace = 0
 
foreach ($INetwork in $INetworks) { $stopTrace = @{$true=1;$false=0}[$INetwork.GetCategory() -ne $NLBDom] }
if ($stopTrace)
{
    Write-Host ("Stop tracing!")
    netsh trace stop
}
