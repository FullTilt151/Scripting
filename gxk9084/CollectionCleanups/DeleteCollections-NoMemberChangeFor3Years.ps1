param(
    [parameter(Mandatory = $true, HelpMessage = "Which site are we running this on. WP1, MT1, SP1, WQ1, SQ1")]
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


#-Setup Logfile
$APPN = "NoMembershipChangesFor3YearsDeploymentCleanup"
$Logfile = "$Env:SystemDrive\Temp\$APPN.log"
$CurrDate = (Get-Date)
if (!(Test-Path -Path "$Env:SystemDrive\Temp")) {
    new-item $Env:SystemDrive\Temp -itemtype directory
}
#-Start Logfile
"" | Out-File $Logfile -Force
"$APPN initiated" | Out-File $Logfile -Append
"$Currdate" | Out-File $Logfile -Append
"" | Out-File $Logfile -Append
#End Setup logfile
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
#Setup site and server
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Set-Location $Site":"
$CollectionList = Get-WMIobject -Class SMS_Collection -Namespace root\sms\site_$Site -ComputerName $Server | Where-Object {$_.CollectionID -notlike 'SMS*' -and $_.CollectionType -eq '2'} | Select-Object -Property Name, CollectionID, LastMemberChangeTime, ObjectPath, IsReferenceCollection
ForEach ($collection in $CollectionList) {
    #how many days since the last membership change, if more than 3years (1095 days), delete it. 
    $lmct = [datetime]::ParseExact($($collection.LastMemberChangeTime).Split('.')[0], "yyyyMMddHHmmss", [System.Globalization.CultureInfo]::InvariantCulture)
    $diff = (New-TimeSpan -Start $lmct -End (Get-Date)).days
    Write-Host $diff
    if ($diff -ge 1095) {
        Write-Host "Deleting" $collection.CollectionID "from" $collection.ObjectPath "---" $collection.name", has had no membership changes for" $diff "days"
        "Deleting " + $collection.CollectionID + " [" + $collection.ObjectPath + "] " + $collection.name + ", has had no membership changes for " + $diff + "days" | Out-File $Logfile -Append
        Remove-CMCollection -Id $collection.CollectionID -Force
    }
}
   