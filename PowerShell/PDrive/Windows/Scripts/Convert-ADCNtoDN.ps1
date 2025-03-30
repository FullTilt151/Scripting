function ConvertFrom-Canonical {
    param(
    [string]$canoincal=(trow '$Canonical is required!')
    )
    $canoincal = "HUMAD.com/" + $canoincal
    $obj = $canoincal.Replace(',','\,').Split('/')
    [string]$DN = "CN=" + $obj[$obj.count - 1]
    for ($i = $obj.count - 2;$i -ge 1;$i--){$DN += ",OU=" + $obj[$i]}
    $obj[0].split(".") | ForEach-Object { $DN += ",DC=" + $_}
    return $dn
}