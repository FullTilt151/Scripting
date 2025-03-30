$Path = 'C:\Program Files (x86)\Now Micro\Right Click Tools\RCT-Options.ini'
if (Test-Path -Path $Path -ErrorAction SilentlyContinue) {
    $ini = Get-Content $Path
    if ($ini[2] -ne 'AutoUpdate=False') {
        $ini[2] = 'AutoUpdate=False'
        Set-Content -Value $ini -Path $Path
    }
}