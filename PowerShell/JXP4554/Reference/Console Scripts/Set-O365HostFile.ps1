$hostPath = "$($env:windir)\System32\Drivers\etc\hosts"
$hostFile = Get-Content -Path $hostPath
$isEdited = $false
for ($x = 0; $x -lt $hostFile.Count; $x++) {
    if ($hostFile[$x] -match 'autodiscover.humana.com') {
        $isEdited = $true
        $hostFile[$x] = "193.91.18.193 autodiscover.humana.com"
    }
}
if ($isEdited) {Out-File -FilePath $hostPath -InputObject $hostFile -Encoding ascii -Force}
else {"`n193.91.18.193 autodiscover.humana.com" | Out-File -FilePath $hostPath -Append -Encoding ascii}