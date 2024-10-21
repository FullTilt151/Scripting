#-Determine and set path to this script.
$ScriptLocation = $MyInvocation.Mycommand.Path
$ScriptPath = Split-Path $ScriptLocation
Set-Location $ScriptPath
$hostnames = @()

$inputfile= "$ScriptPath\hostnames.txt"
$outputfile= "$ScriptPath\hostnamesResults.txt"
"Starting.." | Out-File $outputfile -Force
"" | Out-File $outputfile -Append

Get-Content $inputfile | Foreach-Object {$hostnames += $_} 
foreach ( $Line in $hostnames )
{
$Line | Out-File $outputfile -Append
if(Test-Connection -ComputerName $Line -Quiet)
  {
  "...Running services start update on $Line" | Out-File $outputfile -Append
  $cmdline="psexec.exe"
  $cmdargs="-accepteula -s \\$Line sc config xagt start= delayed-auto"    
  Start-Process $cmdline -ArgumentList $cmdargs -Wait
  }
else
  { 
  "...did not respond" | Out-File $outputfile -Append
  "" | Out-File $outputfile -Append
  }
}