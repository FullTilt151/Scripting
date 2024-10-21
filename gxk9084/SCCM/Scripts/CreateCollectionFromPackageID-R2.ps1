param(
    [ValidateSet('WQ1','WP1')]
    [string]$Site = 'WQ1',
    [Parameter(Mandatory=$true)]
    [string]$PackageID = $(Read-Host "Input Package ID or enter 0 to quit"),
    [switch]$Reclaim
)

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
"$Currdate" | Out-File $Logfile -Append
"" | Out-File $Logfile -Append
#End Setup logfile

#Connect to CM
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
#Setup site and server
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Push-Location $Site":"
#End Connect to CM

#Check for existence of package#
"Checking for package $PackageID" | Out-File $Logfile -Append
If ($PackageID -eq 0) { 
    "Input is 0, Exiting" | Out-File $Logfile -Append
    EXIT 
}
Else {
    Do {
        $PackageInfo = (Get-CMPackage -Id $PackageID -Fast)
        If ($PackageInfo) {
            if ($Reclaim) {
                $Collection = "Reclaim | " + $PackageInfo.Manufacturer + " " + $PackageInfo.Name + " " + $PackageInfo.Version
                Write-Output "Collection: $Collection"
                If (Get-CMCollection -Name $Collection) {
                    Write-Host $Collection "already exists" 
                    "$Collection already exists" | Out-File $Logfile -Append
                }
                Else {
                    #Create Collection, define limiting collection
                    switch ($site) {
                        'WQ1' {$Limiter = "All Non-HGB Physical and Virtual Workstations Limiting Collection"}
                        'WP1' {$Limiter = "All Non-HGB Physical and Virtual Workstations Excluding Templates Limiting Collection"}
                    }
                    $NewColl = New-CMDeviceCollection -Name $Collection -LimitingCollectionName $Limiter -RefreshType None
                    Write-host *** Collection $Collection created ***
                    Write-Host $($NewColl.CollectionID)
                    #Move collection to folder
                    $FolderPath = $Site + ":\DeviceCollection\Software Reclamation"
                    Move-CMObject -FolderPath $FolderPath -InputObject $NewColl
                    "Created collection $Collection $($NewColl.CollectionID) in $FolderPath" | Out-File $Logfile -Append
                }
            } else {
                $PCollection = $PackageInfo.Manufacturer + " " + $PackageInfo.Name + " " + $PackageInfo.Version
                $VCollection = $PCollection + "_VM"
                $Ppath = $PackageInfo.ObjectPath
                Write-Host "Package Path:" $PPath
                Write-Host "Physical Collection: " $PCollection
                Write-Host "Virtual Collection: " $VCollection
        
                #Check Check for Physical Collection
                If (Get-CMCollection -Name $PCollection) {
                    Write-Host $PCollection "already exists" 
                    "$PCollection already exists" | Out-File $Logfile -Append
                }
                Else {
                    #Create Physical Collection, define limiting collection
                    $PhysLimiter = "All Non-HGB Physical Workstations Limiting Collection"
                    New-CMDeviceCollection -Name $PCollection -LimitingCollectionName $PhysLimiter -RefreshType None | Out-Null
                    Write-host *** Collection $PCollection created ***
                    $PCollID = (Get-CMCollection -Name "$PCollection").CollectionID
                    Write-Host $PCollID
                    #Move collection to folder
                    new-item -Name $PackageInfo.Manufacturer -Path $($Site + ":\DeviceCollection\Prod") -Force -ErrorAction SilentlyContinue
                    new-item -Name $PackageInfo.Name -Path $($Site + ":\DeviceCollection\Prod\" + $PackageInfo.Manufacturer) -Force -ErrorAction SilentlyContinue
                    $FolderPath = $Site + ":\DeviceCollection\Prod\" + $PackageInfo.Manufacturer + "\" + $PackageInfo.Name
                    Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $PCollection)
                    "Created collection $PCollection $PCollID in $FolderPath" | Out-File $Logfile -Append
                }
                #Check for Virtual Collection
                If (Get-CMCollection -Name $VCollection) {
                    Write-Host $VCollection "already exists"
                    "$VCollection already exists" | Out-File $Logfile -Append 
                }
                Else {
                    #Create Virtual Collection, define limiting collection
                    $VirtLimiter = "All Non-HGB Virtual Workstations Limiting Collection"
                    New-CMDeviceCollection -Name $VCollection -LimitingCollectionName $VirtLimiter -RefreshType None | Out-Null
                    Write-host *** Collection $VCollection created ***
                    $VCollID = (Get-CMCollection -Name "$VCollection").CollectionID
                    Write-Host $VCollID
                    #Move collection to folder
                    #New-Item -Path $FolderPath -Force -ErrorAction SilentlyContinue
                    Move-CMObject -FolderPath $FolderPath -InputObject (Get-CMDeviceCollection -Name $VCollection)
                    "Created collection $VCollection $VCollID in $FolderPath" | Out-File $Logfile -Append
                }
            }
        }
        Else {
            Write-Host "Package ID $PackageID does not exist"
            [string]$PackageID = $(Read-Host "Input Package ID or enter 0 to quit")
            If ($PackageID -eq 0) { 
                "Input is 0, Exiting" | Out-File $Logfile -Append
                EXIT 
            }
        }
        $PackageID = $(Read-Host "Input Package ID or enter 0 to quit")
            
    } Until ($PackageID -eq 0)
}

Pop-Location