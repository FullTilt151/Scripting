param(
    [parameter(Mandatory = $true, HelpMessage = "Which site are we running this on?")]
    [ValidateSet('MT1', 'SP1', 'SQ1', 'WP1', 'WQ1')]
    [string]$Site
)
#Prompt for site, MT1, WQ1, SQ1, WP1
if ($Site -eq $null) {$Site = Read-Host 'Enter site (MT1, WQ1, SQ1, WP1)'}
$Server = switch ( $Site ) {
    WP1 {'LOUAPPWPS1658.rsc.humad.com'}
    MT1 {'LOUAPPWTS1140.rsc.humad.com'}
    SP1 {'LOUAPPWPS1825.rsc.humad.com'}
    WQ1 {'LOUAPPWQS1151.rsc.humad.com'}
    SQ1 {'LOUAPPWQS1150.rsc.humad.com'}
}

# Setup Logfile
if (!(Test-Path -Path "$Env:SystemDrive\Temp")) {
    New-Item $Env:SystemDrive\Temp -itemtype directory
}
$CurrDate = (Get-Date)

$APPN = 'CM_Collection_ZeroDeploymentCleanup'
$LogfileZD = "c:\Temp\$APPN.log"

# Start Logfile
"" | Out-File $LogfileZD -Force
"$APPN initiated" | Out-File $LogfileZD -Append
"$Currdate" | Out-File $LogfileZD -Append
"" | Out-File $LogfileZD -Append
# End Setup logfile

$APPNZM = 'CM_Collection_ZeroMemberCleanup'
$LogfileZM = "c:\Temp\$APPNZM.log"

# Start Logfile
"" | Out-File $LogfileZM -Force
"$APPNZM initiated" | Out-File $LogfileZM -Append
"$Currdate" | Out-File $LogfileZM -Append
"" | Out-File $LogfileZM -Append
# End Setup logfile

Import-Module 'C:\Program Files (x86)\ConfigMgr10\bin\NomadBranchAdminUIExt\N1E.Precaching.Powershell\N1E.Precaching.Powershell.psd1'

$PrecacheCollections = Get-PreCachingJobs | Select-Object -ExpandProperty TargetCollectionId

Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
#Setup site and server
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Push-Location $Site":"

$Deployments = Get-CimInstance -ClassName SMS_DeploymentSummary -Namespace root/SMS/site_$($Site) -ComputerName $Server | Select-Object -ExpandProperty CollectionID

$CollectionList = Get-CimInstance -ClassName SMS_Collection -Namespace root\sms\site_$Site -ComputerName $Server | 
                    Where-Object {$_.CollectionID -notlike 'SMS*' -and $_.CollectionType -eq '2' -and $_.ObjectPath -like '/Prod/*' -and $_.CollectionId -notin $PrecacheCollections -and $_.IsReferenceCollection -eq $false} |
                    Select-Object -Property Name, MemberCount, CollectionID, ObjectPath, LastMemberChangeTime

$CollectionListShopping = Get-CimInstance -ClassName SMS_Collection -Namespace root\sms\site_$Site -ComputerName $Server | 
                    Where-Object {$_.CollectionID -notlike 'SMS*' -and $_.CollectionType -eq '2' -and $_.ObjectPath -like '/Deployment Collections - Do Not Modify*'} |
                    Select-Object -Property Name, MemberCount, CollectionID, ObjectPath, LastMemberChangeTime

$CollectionListNoDeploy = $CollectionList | Where-Object {$_.CollectionId -notin $Deployments}
$CollectionListShoppingNoDeploy = $CollectionListShopping | Where-Object {$_.CollectionId -notin $Deployments}

ForEach ($collection in $CollectionListNoDeploy) {
    Write-Output "Deleting $($collection.CollectionID) from $($collection.ObjectPath) --- $($collection.name), it has no deployments, and $($collection.MemberCount) members"
    "Deleting $($collection.CollectionID) [$($collection.ObjectPath)] $($collection.name), it has no deployments, and $($collection.MemberCount) members" | Out-File $LogfileZD -Append
    Remove-CMCollection -Id $collection.CollectionID -Force
}

ForEach ($collectionShopping in $CollectionListShoppingNoDeploy) {
    Write-Output "Deleting $($collectionShopping.CollectionID) from $($collectionShopping.ObjectPath) --- $($collectionShopping.name), it has no deployments, and $($collectionShopping.MemberCount) members"
    "Deleting $($collectionShopping.CollectionID) [$($collectionShopping.ObjectPath)] $($collectionShopping.name), it has no deployments, and $($collectionShopping.MemberCount) members" | Out-File $LogfileZD -Append
    Remove-CMCollection -Id $collectionShopping.CollectionID -Force
}

$YearAndHalf = New-TimeSpan -Days 546
$DateOld = (Get-Date)-$YearAndHalf
$CollectionListNoMbr = $CollectionList | Where-Object {$_.CollectionId -in $Deployments -and $_.MemberCount -eq 0 -and $_.LastMemberChangeTime -lt $DateOld}

ForEach ($collection in $CollectionListNoMbr) {
    Write-Output "Deleting $($collection.CollectionID) from $($collection.ObjectPath) --- $($collection.name), it has 0 memmbers and no changes in 1.5 years"
    "Deleting $($collection.CollectionID) [$($collection.ObjectPath)] $($collection.name), it has 0 members and no changes in 1.5 years" | Out-File $LogfileZM -Append
    Remove-CMCollection -Id $collection.CollectionID -Force
}

Pop-Location