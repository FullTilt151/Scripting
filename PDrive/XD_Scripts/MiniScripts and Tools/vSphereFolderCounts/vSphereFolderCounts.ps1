if ((Get-PSSnapin | where { $_.Name -like "VMWare*"}) -eq $null)
{
	Add-PSSnapin VMware.VimAutomation.Core
}

Connect-VIServer louvcswps05.rsc.humad.com  

Get-Content -Path folders.txt | %{
  New-Object PSObject -Property @{
    Folder = $_
    VMCount = Get-Folder -Name $_ | Get-VM | Export-Csv c:\temp\76pilot.csv
  }
}
