# Prompt for CR. You know the drill.
param(
    [Parameter(Mandatory=$true)]
    [string]$CR
)

#Connect to remote WMI, pass the CR, use get() method to get the lazy properties not displayed.
$TestPkg = Get-WmiObject -Namespace root\sms\site_WQ1 -Class SMS_PackageBaseClass -Impersonation 3 -ComputerName LOUAPPWQS1151.rsc.humad.com | Where-Object {$_.PackageID -eq $CR }
$TestPkg.get()
$TestPkg = $TestPkg.AlternateContentProviders

If($TestPkg -eq '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'){
    Write-Host -ForegroundColor Green "CR: $CR has ACP properties!"
    Write-Host -ForegroundColor Green "Those properties are: $TestPkg"
}
else{
    Write-Host -ForegroundColor Red "No ACP settings found. Setting ACP to Nomad."
    # Update 
    $TestPkg = Get-WmiObject -Namespace root\sms\site_WQ1 -Class SMS_PackageBaseClass -Impersonation 3 -ComputerName LOUAPPWQS1151.rsc.humad.com | Where-Object {$_.PackageID -eq $CR }
    $TestPkg.get()
    $TestPkg.AlternateContentProviders = '<AlternateDownloadSettings SchemaVersion="1.0"><Provider Name="NomadBranch"><Data><ProviderSettings /><pc>1</pc></Data></Provider></AlternateDownloadSettings>'
    $TestPkg.put()
    Write-Host -ForegroundColor Green "ACP for $CR set to Nomad!"
}

<#
$CMPkg = Get-CimInstance -Namespace root\sms\site_WQ1 -Class SMS_PackageBaseClass -ComputerName LOUAPPWQS1151.rsc.humad.com | Where-Object {$_.PackageID -eq 'WQ1000CE' }
$CMPkg | Get-CimInstance | Select-Object AlternateContentProviders

Nomad: WQ1000CE
No No: WQ100066
\\lounaswps08\pdrive\workarea\mxc4183\CMPackageExports\WQ1000CE.zip

$UpdateLists = Get-CimInstance -Namespace root\sms\site_TST -Class SMS_AuthorizationList
 
foreach ($UpdateList in $UpdateLists) {
    $UpdateList = $UpdateList | Get-CimInstance
    
    $Updates = $UpdateList.Updates
    ...
}
#>