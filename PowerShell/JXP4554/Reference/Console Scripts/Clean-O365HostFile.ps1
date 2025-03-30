$hostPath = "$($env:windir)\System32\Drivers\etc\hosts"
$hostFile = Get-Content -Path $hostPath
$newFile = New-Object -TypeName System.Collections.ArrayList
$isEdited = $false
for ($x = 0; $x -lt $hostFile.Count; $x++) {
    if ($hostFile[$x] -match '193.91.18.193.*autodiscover.humana.com') {
        $isEdited = $true
    }
    else {
        $newFile.Add($hostFile[$x]) | Out-Null
    }
}
if ($isEdited) {Out-File -FilePath $hostPath -InputObject $newFile -Encoding ascii -Force}