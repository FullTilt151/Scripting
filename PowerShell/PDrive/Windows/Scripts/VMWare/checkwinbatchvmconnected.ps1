
Import-Module active*

$serverlist = @()
for ($i = 1; $i -le 999; $i++)
{ 
    if ($i -lt 10) { $num = "00" + $i} elseif ($i -lt 100) { $num = "0" + $i} else {$num = $i}
    $serverlist += ("grbappwpw" + $num)
}

ForEach ($server in $serverlist) {

  $rtn = Test-Connection -CN $server -Count 1 -BufferSize 16 -Quiet

  IF($rtn -match 'False') {write-host -ForegroundColor Red $server
  add-content -Path C:\temp\winbatchfreenames.txt $server }

  ELSE { Write-host -ForegroundColor green $server }

}




