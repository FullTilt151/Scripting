
if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

Connect-VIServer louvcswps05.rsc.humad.com 

$array = @()
Import-Csv vmnames.csv -UseCulture | %{
  Try {
    Get-VM -Name $_.VMName -ErrorAction Stop | Out-Null  
  }  
  Catch {
    return  
  }  
  $array += $_  
}
$array | Export-Csv c:\temp\report.csv -NoTypeInformation -UseCulture