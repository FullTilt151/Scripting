param(
    [parameter(Mandatory = $true, HelpMessage = "Which site are we running this on. WP1, MT1, SP1, WQ1, SQ1")]
    [string]$Site,
    [string]$PackageID = $(Read-Host "Input Package ID or enter 0 to quit")
)
#Prompt for site, MT1, WQ1, SQ1, WP1
if ($Site -eq $null) { $Site = Read-Host 'Enter site (MT1, WQ1, SQ1, WP1)' }
$Server = switch ( $Site ) {
    WP1 { 'LOUAPPWPS1658.rsc.humad.com' }
    MT1 { 'LOUAPPWTS1140.rsc.humad.com' }
    SP1 { 'LOUAPPWPS1825.rsc.humad.com' }
    WQ1 { 'LOUAPPWQS1151.rsc.humad.com' }
    SQ1 { 'LOUAPPWQS1150.rsc.humad.com' }
}


#-Setup Logfile
$Logfile = "$Env:SystemDrive\Temp\Collection_Creation_Logs\$PackageID.log"
$CurrDate = (Get-Date)

if (!(Test-Path -Path "$Env:SystemDrive\Temp\Collection_Creation_Logs")) {
    new-item $Env:SystemDrive\Temp\Collection_Creation_Logs -itemtype directory
}
#-Start Logfile
"" | Out-File $Logfile -Force
"$PackageID initiated" | Out-File $Logfile -Append
"$Currdate" | Out-File $Logfile -Append
"" | Out-File $Logfile -Append
#End Setup logfile

#Connect to CM
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
#Setup site and server
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Set-Location $Site":"
#End Connect to CM

#Check for existence of package#
If ($PackageID -eq 0)
{ EXIT }
Else {
    $PackageInfo = (Get-CMPackage -Id $PackageID -Fast)
    If ($PackageInfo) {
        $PCollection = $PackageInfo.Manufacturer + " " + $PackageInfo.Name + " " + $PackageInfo.Version
        $VCollection = $PCollection + "_VM"
        $Ppath = $PackageInfo.ObjectPath
        Write-Host "Package Path:" $PPath
        Write-Host "Physical Collection: " $PCollection
        Write-Host "Virtual Collection: " $VCollection
    
        #Check Check for Physical Collection
        If (Get-CMCollection -Name $PCollection) {
            Write-Host $PCollection + "already exists" 
        }
        Else {
            #Create Physical Collection, define limiting collection
            $PhysLimiter = "All Non-HGB Physical Workstations Limiting Collection"
            New-CMDeviceCollection -Name $PCollection -LimitingCollectionName $PhysLimiter | Out-Null
            Write-host *** Collection $PCollection created ***
            #Move collection to folder
            $FolderPath = $Site + ":\DeviceCollection\Prod\" + $PackageInfo.Manufacturer + "\" + $PackageInfo.Name
            New-Item -Path $FolderPath -Force -ErrorAction SilentlyContinue
            Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $PCollection)
        }
        #Check for Virtual Collection
        If (Get-CMCollection -Name $VCollection) {
            Write-Host $VCollection + "already exists" 
        }
        Else {
            #Create Virtual Collection, define limiting collection
            $VirtLimiter = "All Non-HGB Physical Workstations Limiting Collection"
            New-CMDeviceCollection -Name $VCollection -LimitingCollectionName $VirtLimiter | Out-Null
            Write-host *** Collection $VCollection created ***
            #Move collection to folder
            $FolderPath = $Site + ":\DeviceCollection\Prod\" + $PackageInfo.Manufacturer + "\" + $PackageInfo.Name
            New-Item -Path $FolderPath -Force -ErrorAction SilentlyContinue
            Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $VCollection)
        }


  
    }
    Else {
        Write-Host "Package ID $PackageID does not exist"
    }
}
        
    
   