#Check WMI repository size and return "Compliant" if less than 500

$Reposize = (Get-ItemProperty c:\windows\system32\wbem\Repository\OBJECTS.DATA | Select-Object -ExpandProperty Length)
Write-Output "Objects.Data = $Reposize" | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber
If ($Reposize -lt 524288000)
    {
       Write-Output "Compliant"  | Out-File "C:\Temp\WMI_Repo.log" -Append -NoClobber
       Write-Output "Compliant"
    }
else
   {
   Write-Output "Stupid Computers!"
   }