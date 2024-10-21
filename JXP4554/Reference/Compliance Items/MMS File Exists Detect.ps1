<#
.Synopsis

.DESCRIPTION

.PARAMETER

.EXAMPLE

.LINK
    http://parrisfamily.com

.NOTES

#>

$FilePath1 = "$($env:windir)\System32\Macromed\Flash\MMS.cfg"
$FilePath2 = "$($env:windir)\Syswow64\Macromed\Flash\MMS.cfg"
if ((test-path $FilePath1) -or (Test-Path $FilePath2))
{
    Write-Host $true
}
else
{
    Write-Host $false
}