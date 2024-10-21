#-Determine and set path to this script.
$ScriptLocation = $MyInvocation.Mycommand.Path
$ScriptPath = Split-Path $ScriptLocation
Set-Location $ScriptPath
$hostnames = @()

$inputfile = "$ScriptPath\WKIDS.txt"
$outputfile = "$ScriptPath\WKIDResults.txt"
"Starting.." | Out-File $outputfile -Force
"" | Out-File $outputfile -Append

Get-Content $inputfile | Foreach-Object { $hostnames += $_ } 
foreach ( $Line in $hostnames ) {
  $Line | Out-File $outputfile -Append
  if (Test-Connection -ComputerName $Line -Quiet) {
    {
      "...Running client uninstall on $Line" | Out-File $outputfile -Append
      <#$cmdline = "psexec.exe"
      $cmdargs = "-accepteula \\$Line winmgmt /resetrepository"    
      Start-Process $cmdline -ArgumentList $cmdargs -Wait#>
      Invoke-Command -ComputerName $Line -ScriptBlock {C:\Windows\ccmsetup\ccmsetup.exe -Uninstall}
      Start-Sleep 400
      Invoke-Command -ComputerName $Line -ScriptBlock {C:\Windows\ccmsetup\ccmsetup.exe SMSSITECODE=WP1 RESETKEYINFORMATION=TRUE}
    }
  }
  else { 
    "...did not respond" | Out-File $outputfile -Append
    "" | Out-File $outputfile -Append
  }
}