#Remedition script from 1E Nomad CI. This will DISABLE Nomad and uninstall the module.
$serviceskey = 'HKLM:\System\CurrentControlSet\Services\'
$servicename = '1EClient'
$imagepathobj = Get-ItemProperty -Path $serviceskey$servicename -Name ImagePath -ErrorAction SilentlyContinue
if($imagepathobj -eq $null){
    return
}
$imagepath = $imagepathobj.ImagePath
# To extract path from - "C:\Program Files\1E\Client\1E.Client.exe" -RunService
if ($imagepath.IndexOf('"') -ge 0) {
     $binarypath = $imagepath.Split('"')[1]    
}
 
if((Test-Path $binarypath) -eq $False){
    return
}
 
$Args = "-reconfigure", "MODULE.NOMAD.ENABLED=false", "-restart -immediate"
Start-Process $binarypath $Args;