$sourceloc = "\\wkmjbmedl\e"
$destloc = "\\lounaswps01\pdrive\workarea\dxr5354"
$args = "/mir /r:0 /w:0"

write-host "The source location is currently: " -foregroundcolor cyan -backgroundcolor black -nonewline;  $sourceloc
write-host "The destination location is currently: " -foregroundcolor cyan -backgroundcolor black -nonewline;  $destloc

get-childitem $sourceloc
"robocopy.exe" + $sourceloc + $destloc + $args