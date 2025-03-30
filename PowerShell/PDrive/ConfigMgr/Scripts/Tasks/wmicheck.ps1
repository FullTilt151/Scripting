#-Determine and set path to this script.
$ScriptLocation = $MyInvocation.Mycommand.Path
$ScriptPath = Split-Path $ScriptLocation
Set-Location $ScriptPath
$hostnames = @()

$inputfile= "$ScriptPath\host.txt"
$outputfile= "$ScriptPath\hostResults.txt"
"Starting.." | Out-File $outputfile -Force
"" | Out-File $outputfile -Append

Get-Content $inputfile | Foreach-Object {$hostnames += $_} 
foreach ( $Line in $hostnames )
{
$Line | Out-File $outputfile -Append
if(Test-Connection -ComputerName $Line -Quiet)
{
$wmiqueryresult = gwmi win32_computersystem -Computername $Line | select -ExpandProperty Name | select -First 1
if($wmiqueryresult -eq $Line)
  {
  "...Passed" | Out-File $outputfile -Append
  "" | Out-File $outputfile -Append
  }
else
  {
  "...Running repair of WMI on $Line" | Out-File $outputfile -Append
  "...Stopping winmgmt service"| Out-File $outputfile -Append
  (get-service -ComputerName $Line -Name winmgmt).Stop()
  "...Resetting repository"| Out-File $outputfile -Append
  "" | Out-File $outputfile -Append
  $cmdline="psexec.exe"
  $cmdargs="-accepteula \\$Line winmgmt /resetrepository"    
  Start-Process $cmdline -ArgumentList $cmdargs -Wait
  }
}
else
  { 
  "...did not respond" | Out-File $outputfile -Append
  "" | Out-File $outputfile -Append
  }
}