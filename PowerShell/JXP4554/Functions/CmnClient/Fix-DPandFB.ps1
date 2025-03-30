<#
.Synopsis
This script will cycle through all packages and verify the DP Group is set to All Workstations DP Group and that the allow Fallback checkbox is checked
.Example
"Fix DPs and FallBack.ps1"
.Parameter
None
.Notes
NAME: Fix DPs and Fallback.ps1
AURTHOR: James Parris
LASTEDIT: 1/6/2014
KEYWORDS: DP Groups,FallBack
.Link
http://www.parrisfamily.com
#Requires -Version 3.0
#>

<#
1. Get Subfolders
2. Get Packages
3. Get the DP's
    a. if Empty, move on
    b. if HGB, make sure it stays
    c. if All DP's - Remove
    d. if Server DP's - Remove
    e. ensure All Workstation DP's are there
    f. Get all Deployments
        1. Make sure Fallback is checked
#>

[CmdletBinding( SupportsShouldProcess = $False, ConfirmImpact = "None", DefaultParameterSetName = "" ) ]
param(
[parameter(
    Position = 1,
    Mandatory=$true )
    ]
    [Alias("SC")]
    [ValidateNotNullOrEmpty()]
    [string]$SiteServer="",

    [parameter(
    Position = 2,
    Mandatory=$true )
    ]
    [Alias("FP")]
    [ValidateNotNullOrEmpty()]
    [string]$FolderPath=""
)

Function New-LogEntry {
    # Writes to the log file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,

        [Parameter(Position=1,Mandatory=$true)]
        [INT32] $type,

        [Parameter(Position=2,Mandatory=$true)]
        [STRING] $component = 'Create-SUGs'
        )

        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Global:LogFile -Append -Encoding ascii
}

$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode
Import-Module ($env:SMS_ADMIN_UI_PATH.Substring(0,$env:SMS_ADMIN_UI_PATH.Length – 5) + '\ConfigurationManager.psd1') | Out-Null
Set-Location "$($SiteCode):"
$Site = "$($SiteCode):" | Out-Null
if (-not (Get-PSDrive -Name $SiteCode)){
    Write-Error "There was a problem loading the Configuration Manager powershell module and accessing the site's PSDrive."
    exit 1
}

$Packages = @()
$ChildFolders = @()
$Children = $null
$IDPath = @()
$GreatChildFolders = $null
$ChildFolders = $null
$Folders = $null

[array]$Folders = $FolderPath.Split("\")

$i = 0
foreach ($Folder in $Folders){
    $FolderID = $null
    if ($i -eq 0){
        $RootFolder = "0"
    }
    $FolderID = (Get-WmiObject -Class SMS_ObjectContainerNode -Namespace root\SMS\site_$($SiteCode) -ComputerName $($SiteServer) -Filter "Name = '$($Folder)' and ObjectType = '2' and ParentContainerNodeID = '$($RootFolder)'").ContainerNodeID
    $RootFolder = $FolderID
    $IDPath += $FolderID
    $i++
}

$ParentFolder = $StartFolder = (Get-WmiObject -Class SMS_ObjectContainerNode -Namespace root\SMS\site_$($SiteCode) -ComputerName $($SiteServer) -Filter "ContainerNodeID = '$($IDPath[-1])'").ContainerNodeID

$Children = (Get-WmiObject -Class SMS_ObjectContainerNode -Namespace root\SMS\site_$($SiteCode) -ComputerName $($SiteServer) -Filter "ParentContainerNodeID = '$($ParentFolder)'").ContainerNodeID
$ChildFolders += $Children

foreach ($Child in $ChildFolders){
    try {
        $GreatChildFolders = (Get-WmiObject -Class SMS_ObjectContainerNode -Namespace root\SMS\site_$($SiteCode) -ComputerName $($SiteServer) -Filter "ParentContainerNodeID = '$($Child)'").ContainerNodeID
    }
    catch [System.Management.Automation.PropertyNotFoundException] {
        Write-Verbose "This was the last folder."
    }

    $ChildFolders += $GreatChildFolders
}

foreach ($ChildFolder in $ChildFolders){
    try {
        $Packages += (Get-WmiObject -Class SMS_ObjectContainerItem -Namespace root\SMS\site_$($SiteCode) -ComputerName $($SiteServer) -Filter "ContainerNodeID = '$($ChildFolder)'").InstanceKey
        Write-Host "Getting package for $ChildFolder"
    }
    catch [System.Management.Automation.PropertyNotFoundException] {
        Write-Verbose "This was the last Package."
    }
}

foreach ($Pkg in $Packages){
    try{
        $Package = Get-WmiObject -Class SMS_Package -Namespace root\sms\site_$SiteCode -ComputerName $($SiteServer) -Filter "PackageID = '$($Pkg)'"
        if ($Package.Manufacturer -eq "" -and $Package.Name -eq ""){
        #if (@(Get-Variable Package).Length -eq 0){
            Write-Host "Blank"
        }
        else {
            Write-Host "$($Pkg) - $($Package.Manufacturer) $($Package.Name) Len $($Pkg.Length()) - $($Package.Length())"
        }
    }
    catch [System.Management.Automation.PropertyNotFoundException] {
        Write-Verbose "This was the last Package."
    }
}
<#

Write-Host "Getting Deployments"
$Deployments = Get-CMDeployment

foreach($Deployment in $Deployments){
    Write-Host "Getting info for package $($Deployment.PackageID)"
    $Package = Get-CMPackage -Id $Deployment.PackageID
    $Filter = "packageid = `"$($Package.PackageID)`""
    $Adverts = get-wmiobject sms_advertisement -ComputerName $SiteServer -Namespace root\sms\site_$Site -Filter $Filter
    foreach($Advert in $Adverts){
        write-host "Working Advert $($Advert.Name)"
        $Result = $Advert.AdvertFlags -band 4294836223
        if $Advert.
        $Advert.AdvertFlags = $Result
        $Advert.Put()

        Write-Host $Result
    }
}

#>