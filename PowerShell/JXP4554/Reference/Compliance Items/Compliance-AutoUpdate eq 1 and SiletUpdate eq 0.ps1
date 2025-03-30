<#
.Synopsis
    Remediation script for Adobe Flash

.DESCRIPTION
    This script looks to see if the MMS.cfg file exists for Adobe Flash. It checks both the 32 and 64 bit directories.
    If it's there, it looks to see if the autoupdate is disabled. If it find's it isn't, it fixes it.

.LINK
    http://parrisfamily.com

.NOTES

#>
$Remediate = $false
$Compliant = $true

$FilePath = "$($env:windir)\SysWOW64\Macromed\Flash\mms.cfg"
if (Test-Path $FilePath)
{
    (Get-Content $FilePath) | ForEach-Object{$_ -replace '(?i)AutoUpdateDisable\s*=\s*0', 'AutoUpdateDisable=1'} | ForEach-Object{$_ -replace '(?i)SilentAutoUpdate\s*=\s*1', 'SilentAutoUpdate=0'} | ForEach-Object{$_ -replace '(?i)SilentAutoUpdateEnable\s*=\s*1', 'SilentAutoUpdateEnable=0'} | Set-Content $FilePath
}
$FilePath = "$($env:windir)\System32\Macromed\Flash\mms.cfg"
if (Test-Path $FilePath)
{
    (Get-Content $FilePath) | ForEach-Object{$_ -replace '(?i)AutoUpdateDisable\s*=\s*0', 'AutoUpdateDisable=1'} | ForEach-Object{$_ -replace '(?i)SilentAutoUpdate\s*=\s*1', 'SilentAutoUpdate=0'} | ForEach-Object{$_ -replace '(?i)SilentAutoUpdateEnable\s*=\s*1', 'SilentAutoUpdateEnable=0'} | Set-Content $FilePath
}

$FilePath = "$($env:windir)\SysWOW64\Macromed\Flash\mms.cfg"
if (Test-Path $FilePath)
{
    (Get-Content $FilePath) | ForEach-Object
	{
		if($_ -match '(?i)AutoUpdateDisable\s*=\s*0')
		{
			$Compliant = $false
			if($Remediate){$_ -replace '(?i)AutoUpdateDisable\s*=\s*0', 'AutoUpdateDisable=1'}
		}
	} | ForEach-Object
	{
		if($_ -match '(?i)SilentAutoUpdate\s*=\s*1')
		{
			$Compliant = $false
			if($Remediate){$_ -replace '(?i)SilentAutoUpdate\s*=\s*1', 'SilentAutoUpdate=0'}
		}
	} | ForEach-Object
	{if($_ -match '(?i)SilentAutoUpdateEnable\s*=\s*1')
		{
			$Compliant = $false
			if($Remediate){$_ -replace '(?i)SilentAutoUpdateEnable\s*=\s*1', 'SilentAutoUpdateEnable=0'}
		}
	}
}
$FilePath = "$($env:windir)\System32\Macromed\Flash\mms.cfg"
if (Test-Path $FilePath)
{
    (Get-Content $FilePath) | ForEach-Object
	{
		if($_ -match '(?i)AutoUpdateDisable\s*=\s*0')
		{
			$Compliant = $false
			if($Remediate){$_ -replace '(?i)AutoUpdateDisable\s*=\s*0', 'AutoUpdateDisable=1'}
		}
	} | ForEach-Object
	{
		if($_ -match '(?i)SilentAutoUpdate\s*=\s*1')
		{
			$Compliant = $false
			if($Remediate){$_ -replace '(?i)SilentAutoUpdate\s*=\s*1', 'SilentAutoUpdate=0'}
		}
	} | ForEach-Object
	{
		if($_ -match '(?i)SilentAutoUpdateEnable\s*=\s*1')
		{
			$Compliant = $false
			if($Remediate){$_ -replace '(?i)SilentAutoUpdateEnable\s*=\s*1', 'SilentAutoUpdateEnable=0'}
		}
	}
}
Write-Host $Compliant