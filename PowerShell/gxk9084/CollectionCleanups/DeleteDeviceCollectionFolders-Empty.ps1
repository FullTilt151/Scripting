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
$APPN = "DeleteEmptyDeviceCollectionFolders"
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
$ContainerList = Get-WMIobject -Class SMS_ObjectContainerNode -Namespace root\sms\site_$Site -ComputerName $Server | Where-Object {$_.IsEmpty -eq 'True' -and $_.ObjectType -eq '5000'} | Select-Object -Property Name, ContainerNodeID, IsEmpty, ObjectType, ParentContainerNodeID, FolderGUID
If ($ContainerList -ne $null) {
    Do {
        ForEach ($container in $ContainerList) {
            #Delete,we know there are empty folders because the IsEmpty property is True 
            #Get the parent folder
            $fpath = (Get-WMIobject -Class SMS_ObjectContainerNode -Namespace root\sms\site_$($Site) -ComputerName $($Server) -Filter "ContainerNodeID='$($container.ParentContainerNodeID)'")
            if ($fpath.ParentContainerNodeID -ne "0"){
            $ppath = $fpath
                Do{
                $ppath = (Get-WMIobject -Class SMS_ObjectContainerNode -Namespace root\sms\site_$($Site) -ComputerName $($Server) -Filter "ContainerNodeID='$($fpath.ParentContainerNodeID)'") 
                $fpath = "$($ppath.Name)\$($fpath.Name)"
                } Until ($ppath.ParentContainerNodeID -eq "0")
            }
            Write-Host "Deleting" $container.ContainerNodeID $container.name
            "Deleting " + $container.name + " because it is empty" | Out-File $Logfile -Append
            Remove-Item -Path "$($Site):\DeviceCollection\$($fpath.name)\$($container.name)" -force -whatif
        }
        $ContainerList = Get-WMIobject -Class SMS_ObjectContainerNode -Namespace root\sms\site_$Site -ComputerName $Server | Where-Object {$_.IsEmpty -eq 'True' -and $_.ObjectType -eq '5000'} | Select-Object -Property Name, ContainerNodeID, IsEmpty, ObjectType, ParentContainerNodeID, FolderGUID
    } Until ($ContainerList -eq $null)
}


        
    
   