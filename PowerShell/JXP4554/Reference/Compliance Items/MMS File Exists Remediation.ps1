<#
.Synopsis

.DESCRIPTION

.PARAMETER

.EXAMPLE

.LINK
    http://parrisfamily.com

.NOTES

#>

$FilePath = "$($env:windir)\System32\Macromed\Flash\MMS.cfg"
if (-not (test-path $FilePath))
{
    "AutoUpdateDisable=1" | Out-File $FilePath -Encoding ascii
    "SilentAutoUpdateEnable=0" | Out-File $FilePath -Encoding ascii -Append
}
$FilePath = "$($env:windir)\Syswow64\Macromed\Flash\MMS.cfg"
if (-not (test-path $FilePath))
{
    "AutoUpdateDisable=1" | Out-File $FilePath -Encoding ascii
    "SilentAutoUpdateEnable=0" | Out-File $FilePath -Encoding ascii -Append
}
