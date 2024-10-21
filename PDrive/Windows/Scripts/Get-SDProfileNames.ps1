$csv = Import-Csv C:\temp\Book1.csv

$csv | ForEach-Object {
    $WKID = $_.DeviceName
    ($_.ScriptOutput).Split('') | ForEach-Object { "$WKID,$_" | Out-File c:\temp\SDprofiles.txt -Append }
}

$sdp = Import-Csv C:\temp\SDprofiles.txt -Header WKID,Profile
$sdp | Where-Object {$_.profile -ne '' -and $_.Profile -ne 'PBN' -and $_.Profile -notlike "Boot-*"}

$sdp[0].Profile.Replace('.enc','') -match '[a-zA-Z]{4}$'