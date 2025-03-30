# add a machine to a ruleset
#http://<ShopDnsAliasFQDN>/shopping/api/machines/AssignMachineToRuleSet?MachineName=<MachineName>&Domain=<Domain>&RuleSetName=<RuleSetName> 
$AssignMachineToRuleSet = "/api/machines/AssignMachineToRuleSet"

# refresh inventory from AppClarity
#http://<ShopDnsAliasFQDN>/shopping/api/machines/inventoryrefresh?MachineName=<MachineName> &Domain=<Domain>
$InventoryRefresh = "/api/machines/InventoryRefresh"

#Get Legacy Packages to install
#http://<ShopDnsAliasFQDN>/shopping/api/osd/GetMappedPackages?MachineName=<MachineName>&domain=<Domain>
$GetLegacyPackages = "/api/osd/GetMappedPackages"

#Get MachineCentric Apps
#http://<ShopDnsAliasFQDN>/shopping/api/osd/GetMappedMachineCentricApplications?MachineName=<MachineName>&Domain=<Domain>
$GetMachineCentricApps = "/api/osd/GetMappedMachineCentricApplications"

$Domain = "HUMAD"
$MachineName = "WKMJ05G8FH"

$ShoppingURL = "http://appshop.humana.com/shopping"

""
"------------Refresh Inventory-----------------------------------------"
""
# refresh method
$request="$ShoppingURL" +"$InventoryRefresh" + "?Domain=$Domain&MachineName=$MachineName"
"calling $request"
$result = Invoke-WebRequest -Uri $request -Method Post -ContentType "text/xml" -UseDefaultCredentials
$result.Content

"waiting 30 seconds for inventory refresh"
Start-Sleep -s 60 

""
"------------Get Legacy Packages---------------------------------------"
""
# Legacy Packages
$request="$ShoppingURL" + "$GetLegacyPackages" + "?Domain=$Domain&MachineName=$MachineName"
"calling $request"
$result = Invoke-WebRequest -Uri $request -Method Post -ContentType "text/xml" -UseDefaultCredentials
[xml]$Packages = $result.Content
$Packages.arrayofmappedPackage.MappedPackage

""
"------------Get Machine Centric Apps----------------------------------"
""
# Machine Centric Apps
$request="$ShoppingURL" + "$GetMachineCentricApps" + "?Domain=$Domain&MachineName=$MachineName"
"calling $request"
$result = Invoke-WebRequest -Uri $request -Method Post -ContentType "text/xml" -UseDefaultCredentials
[xml]$Apps = $result.Content
$Apps.ArrayOfMappedMachineCentricApplication.MappedMachineCentricApplication.MappedApplication 
