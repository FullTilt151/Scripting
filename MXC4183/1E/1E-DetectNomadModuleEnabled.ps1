#Discovery CI script from 1E to detect Nomad module. $True = Nomad is ENABLED. $False = Nomad is DISABLED.
$serviceskey = 'HKLM:\System\CurrentControlSet\Services\'
$servicename = '1EClient'
$imagepathobj = Get-ItemProperty -Path $serviceskey$servicename -Name ImagePath -ErrorAction SilentlyContinue
if($imagepathobj -eq $null){
    return $true
}
$imagepath = $imagepathobj.ImagePath
# To extract path from - "C:\Program Files\1E\Client\1E.Client.exe" -RunService
if ($imagepath.IndexOf('"') -ge 0) {
     $binarypath = $imagepath.Split('"')[1]    
}
 
if((Test-Path $binarypath) -eq $False){
    return $true
}
 
$conffileparentpath = Split-Path -parent $binarypath
$conffilename = '1E.Client.conf'
$conffilepath = Join-Path -Path $conffileparentpath -ChildPath $conffilename
if((Test-Path $conffilepath) -eq $False){
    return $true
}
 
#process the 1E.Client.conf file
Get-Content $conffilepath | Where { $_ -notmatch '^#.*' -and $_ -notmatch '^\s*$' } | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True)) { $h.Add($k[0], $k[1]) } }
 
 
if($h.Get_Item("Module.Nomad.Enabled") -eq 'false'){
    return $false
}
return $true