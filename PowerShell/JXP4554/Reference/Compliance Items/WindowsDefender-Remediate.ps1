$EngineVersion = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Signature Updates' -Name EngineVersion -ErrorAction SilentlyContinue

if ($EngineVersion -eq '1.1.3007.0')
{
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Signature Updates' -Name EngineVersion -ErrorAction SilentlyContinue
}