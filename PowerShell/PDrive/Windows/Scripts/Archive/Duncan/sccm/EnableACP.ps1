# 1E Ltd Copyright 2012
# 
# Name: EnableACP.ps1
# Date: 4/30/2012
# Version 1.0
#
# Disclaimer:                                                                                                                                                                                                                                        
# Your use of this script is at your sole risk. This script is provided "as-is", without any warranty, whether express               
# or implied, of accuracy, completeness, fitness for a particular purpose, title or non-infringement, and is not                      
# supported or guaranteed by 1E. 1E shall not be liable for any damages you may sustain by using this script, whether      
# direct, indirect, special, incidental or consequential, even if it has been advised of the possibility of such damages. 

$pkgID = $args[0]
$siteCode = $args[1]
$siteServer = $args[2]
$acp = 
@"
<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><rh /><mc /><pc>5</pc></Data></Provider></AlternateDownloadSettings>
"@
$MaxWorkRate = 80

new-eventlog -source 1E -logname Application -erroraction silentlycontinue
$pkg = gwmi sms_package -computer $siteServer -namespace root\sms\site_$siteCode -filter "PackageID='$pkgID'"
#this displays the explicit path to the object
$pkg2 = [wmi] $pkg.__Path    #use wmi accelerator to grab the object, including lazy

if ($pkg2.AlternateContentProviders -notmatch "nomad") {
    "enabling acp"
    write-eventlog -logname Application -source 1E -eventID 100 -entrytype Information -message "Enabling default Nomad Branch settings on package $pkgID"
    $pkg2.AlternateContentProviders = $acp
    $pkg2.Put()
}
else #acp already enabled, checking settings
{
    #check to see if work rate is configured properly
    $pkg2xml = [xml] $pkg2.AlternateContentProviders

    if ($pkg2xml.AlternateDownloadSettings.Provider.data.wr -ne $null) {
        if ($pkg2xml.AlternateDownloadSettings.Provider.data.wr -gt $MaxWorkRate) {
        "non-standard config Resetting acp default settings"
        write-eventlog -logname Application -source 1E -eventID 100 -entrytype Information -message "Non-standard Setting Configured - Re-Enabling default Nomad Branch settings on package $pkgID and resetting workrate to 80"
        $pkg2.AlternateContentProviders = $acp
        $pkg2.Put()
        
        }
     else
     {
        
        "acp already enabled, and work rate is acceptable"
     }
        
     }
     else
     {
        "wr is Null, which is considered acceptable"
     }
}
