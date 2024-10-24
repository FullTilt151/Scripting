# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2011
# 
# NAME: 
# 
# AUTHOR: Duncan Russell , SysAdminTechNotes.com
# DATE  : 2/17/2014
# 
# COMMENT: 
# 
# ==============================================================================================
$siteServer = "LOUAPPWPS875"
$siteCode = "cas"

$packages = gwmi sms_package -computer $siteServer -namespace root\sms\site_$siteCode
$packages | % {$pkg2 = [wmi] $_.__Path;if ($pkg2.AlternateContentProviders -match "nomad"){$pkg2xml = [xml] $pkg2.AlternateContentProviders;if($pkg2xml.AlternateDownloadSettings.Provider.data.wr -gt 0){Write-Host ("{0}:{1}" -f $pkg2xml.AlternateDownloadSettings.Provider.data.wr, $pkg2.Name ) }}}
