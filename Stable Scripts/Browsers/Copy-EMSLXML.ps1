$IELocal = Get-Content -Path .\EnterpriseModeSiteList\ieem-win10.xml
$IEServer = Get-Content -Path \\louappwps1331\IESiteList\ieem-Win10.xml

$EdgeLocal = Get-Content -Path .\EnterpriseModeSiteList\ieem-Win10-Test.xml
$EdgeServer = Get-Content -Path \\louappwps1331\IESiteList\ieem-Win10-Test.xml

Compare-Object -ReferenceObject $EdgeLocal -DifferenceObject $EdgeServer
Compare-Object -ReferenceObject $IELocal -DifferenceObject $IEServer

Copy-Item -Path .\EnterpriseModeSiteList\ieem*.xml -Destination \\louappwps1331\IESiteList -Recurse -Force -Verbose
Copy-Item -Path .\EnterpriseModeSiteList\ieem*.xml -Destination \\louappwps1332\IESiteList -Recurse -Force -Verbose
Copy-Item -Path .\EnterpriseModeSiteList\ieem*.xml -Destination \\louappwps1632\IESiteList -Recurse -Force -Verbose
