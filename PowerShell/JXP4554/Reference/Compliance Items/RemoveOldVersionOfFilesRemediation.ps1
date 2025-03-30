$key = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'
$cache = Get-ChildItem $key

ForEach ($item in $cache) {
    if ((Get-ItemProperty -Path $item.PSPath -Name DisplayName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName) -match 'Flash Player.*ActiveX')
    {
        $Version = (Get-ItemProperty -Path $item.PSPath -Name DisplayVersion | Select-Object -ExpandProperty DisplayVersion) -replace '\.', '_'
    }
}


$FileDir = 'C:\Windows\System32\Macromed\Flash'
if (Test-Path $FileDir)
{
   $Files = Get-ChildItem $FileDir | Where-Object {$_.Name -Match '\d+_\d+_\d+_\d+_'}
}
foreach($File in $Files)
{
    if (-not ($File -match $Version))
    {
        Remove-item $File.FullName
    }
}

$FileDir = 'C:\Windows\SysWOW64\Macromed\Flash'
if (Test-Path $FileDir)
{
   $Files = Get-ChildItem $FileDir | Where-Object {$_.Name -Match '\d+_\d+_\d+_\d+_'}
}
foreach($File in $Files)
{
    if (-not ($File -match $Version))
    {
        Remove-item $File.FullName
    }
}

$key = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
$cache = Get-ChildItem $key

ForEach ($item in $cache) {
    if ((Get-ItemProperty -Path $item.PSPath -Name DisplayName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DisplayName) -match 'Flash Player.*ActiveX')
    {
        $Version = (Get-ItemProperty -Path $item.PSPath -Name DisplayVersion | Select-Object -ExpandProperty DisplayVersion) -replace '\.', '_'
    }
}

$FileDir = 'C:\Windows\SysWOW64\Macromed\Flash'
if (Test-Path $FileDir)
{
   $Files = Get-ChildItem $FileDir | Where-Object {$_.Name -Match '\d+_\d+_\d+_\d+'}
}
foreach($File in $Files)
{
    if (-not ($File -match $Version))
    {
        Remove-item $File.FullName
    }
}


$FileDir = 'C:\Windows\System32\Macromed\Flash'
if (Test-Path $FileDir)
{
   $Files = Get-ChildItem $FileDir | Where-Object {$_.Name -Match '\d+_\d+_\d+_\d+_'}
}
foreach($File in $Files)
{
    if (-not ($File -match $Version))
    {
        Remove-item $File.FullName
    }
}