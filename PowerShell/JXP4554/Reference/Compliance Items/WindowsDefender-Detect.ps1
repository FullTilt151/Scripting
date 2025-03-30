[bool]$ServiceExists = $false
[bool]$EngineVersionExists = $false
$Service = 'Windows Defender'
$EngineVersion = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Signature Updates' -Name EngineVersion -ErrorAction SilentlyContinue
if ($EngineVersion -eq '1.1.3007.0')
{
    $EngineVersionExists = $true
}
if (Get-Service -Name $Service -ErrorAction SilentlyContinue)
{
    $ServiceExists = $true
}
if (-not($ServiceExists) -and $EngineVersionExists)
{
    Write-Host $true
}
else
{
    Write-Host $false
}