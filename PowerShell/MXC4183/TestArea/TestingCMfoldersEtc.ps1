<#
    .SYNOPSIS
        Configure systems according to a CSV to be an MP, DP, or SUP
    .DESCRIPTION
        This script is used to setup a set of new MEMCM servers that are in the MP, DP, or SUP role. It requires
        a CSV file to be input with the headers specefied in the help for the EnvironmentCSV parameter.

        A Credential object is required because we need to create a scheduled task on remote machines, that will
        also be accessing network resources. 
    .PARAMETER EnvironmentCSV
        CSV file containing the follow headers:

        ComputerName,Environment,SiteServer,MP,MP_SSL,DP,SUP,SUP_SSL,SUP_ContentSource,SUSDB,FSP,SQL,SSRS,SSRS_SQL,Datacenter
    .PARAMETER SiteCode
        The site code these changes are executed against
    .PARAMETER Role
        The role to configure for the servers, if they have it specified in the spreadsheet

        MP, DP, or SUP
    .PARAMETER Credential
        A Credential object used to create a scheduled task on remote machines that will also be accessing network resources. 
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        After this script completes, further action will still be needed.

        * Force the relevent ConfigMgr* baselines to run on these machines AFTER role installation. This ensures that all 
            configurations are consistent, and accurate.
        * Software Update Sync should be ran to get the SUPs ready for use (probably go to bed, not fun to watch)
        * Add servers to Distribution Point Groups, and Boundary Groups
<#
1. Prompt user for site code.
2. Ensure user entered proper site.
3. Connect to site.
4. Get package info from site.
   Check package exists, get info.
5. Get info about folder.
#>

#1. Prompt user for site code and validate.
param(
    [parameter(Mandatory = $true, HelpMessage = "Which site are we running this on. WP1, MT1, SP1, WQ1, SQ1")]
    [ValidateSet('WP1', 'SP1', 'WQ1', 'SQ1', 'MT1')]
    [string]$Site = $(Read-Host "Enter the Site to connect to")
    #[string]$PackageID = $(Read-Host "Enter PackageID")
)

$Server = switch ( $Site ) {
    WP1 { 'LOUAPPWPS1658.rsc.humad.com' }
    MT1 { 'LOUAPPWTS1140.rsc.humad.com' }
    SP1 { 'LOUAPPWPS1825.rsc.humad.com' }
    WQ1 { 'LOUAPPWQS1151.rsc.humad.com' }
    SQ1 { 'LOUAPPWQS1150.rsc.humad.com' }
}
#End site code prompt.

#2. Site code is validated. Connect to MEMCM
Import-module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')
New-PSDrive -Name $Site -PSProvider "AdminUI.PS.Provider\CMSite"  -Root $Server -ErrorAction SilentlyContinue
Set-Location $Site":"
#End Connect to MEMCM

#3. Prompt user for packageID, validate and get info.
$PackageID = Read-Host -Prompt 'What is the packageID?'
$PackageInfo = Get-CMPackage -Id $PackageID -Fast
#End prompt for packageID

#4. Get some data about the package. Check for proper folder structure. Store in variables for naming the collections later.
If ($PackageInfo) {
    Write-host "Package Name $($PackageInfo.Name) found!"
    Write-host "Checking for proper folder structure. Please wait..."
    $FolderPath = $Site + ":\Package\Prod\" + $PackageInfo.Manufacturer + "\" + $PackageInfo.Name
    If (Test-Path $FolderPath){
        Write-host "Package has proper folder structure. Checking for proper collections..."
    }
    else{
        Write-host "Package located at unproper folder structure. Moving..."
        Move-CMObject
    }

    $PCollection = $PackageInfo.Manufacturer + " " + $PackageInfo.Name + " " + $PackageInfo.Version
    $VCollection = $PCollection + "_VM"
    $Ppath = $PackageInfo.ObjectPath
    #Write-Host "Package Path:" $PPath
    #Write-Host "Physical Collection: " $PCollection
    #Write-Host "Virtual Collection: " $VCollection
}


