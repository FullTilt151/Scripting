param(
$ComputerName
)
Get-WmiObject -ComputerName $ComputerName -Namespace root\ccm\policy\machine\actualconfig -Class CCM_Updatesource | select -ExpandProperty ScanFailureRetryErrorCodes