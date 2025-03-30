<#
.Synopsis

.DESCRIPTION

.PARAMETER 

.EXAMPLE

.LINK
    http://configman-notes.com

.NOTES

SELECT  sys.netbios_name0 WKID, adv.AdvertisementID,adv.AdvertisementName, 
	stat.LastStateName, stat.lastexecutionresult [Result], DATEADD(HH,-5,stat.laststatustime) [Last Status Time EST], 
	adv.PackageID,
	pkg.Name AS Package, 
	adv.ProgramName AS Program, 
	adv.Comment AS Description,  
	adv.CollectionID
FROM v_advertisement adv 
JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID 
JOIN v_ClientAdvertisementStatus  stat ON stat.AdvertisementID = adv.AdvertisementID 
JOIN v_R_System sys ON stat.ResourceID=sys.ResourceID 
WHERE sys.Netbios_Name0=@WKID and 
	  LastStateName != 'Accepted - No Further Status' and 
	  LastStateName != 'No Status'
order by LastStatusTime desc
#>

PARAM(
    #Parameters in script for New-LogEntry
    [Parameter(Mandatory = $false, HelpMessage = 'Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error')]
    [ValidateSet(1, 2, 3)]
    [Int32]$LogLevel = 2,
    [Parameter(Mandatory = $false, HelpMessage = 'Log File Directory')]
    [String]$LogFileDir = 'C:\Temp\',
    [Parameter(Mandatory = $false, HelpMessage = 'Clear any existing log file')]
    [Switch]$ClearLog
)


#Build variables for New-LogEntry Function

$ScriptName = $MyInvocation.MyCommand.Name
if (-not ($LogFileDir -match '\\$')) {$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$CSVFile = "C:\Temp\$LogFile.csv"
$LogFile = $LogFileDir + $LogFile + '.log'
if ($ClearLog) {
    if (Test-Path $Logfile) {Remove-Item $LogFile}
}

$SiteServer = 'LOUAPPWPS875'
$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace    = "root\sms\site_$SiteCode"
}

$DataSourceWMI = $(Get-CimInstance -ClassName SMS_SiteSystemSummarizer -Namespace root\sms\site_$SiteCode -ComputerName $SiteServer -Filter "Role = 'SMS SQL SERVER' and SiteCode = '$SiteCode' and ObjectType = 1").SiteObject
$DataSource = $DataSourceWMI -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'
$Database = $DataSourceWMI -replace ".*\\([A-Z_]*?)\\$", '$+'
$ShoppingServer = 'LOUSQLWPS360'
$ShoppingDB = 'Shopping2'

$SQLCommand = "SELECT     COD.CompletedOrderId, MCN.MachineName, COD.PackageId, COD.AdvertId, RequestedTimestamp, COD.DeliveryStatus`
FROM         tb_CompletedOrder COD INNER JOIN`
                      tb_Machine MCN ON COD.MachineId = MCN.MachineId`
WHERE     (AdvertId is null or AdvertId = '')"

$Machines = Get-CMNSQLQuery $ShoppingServer $ShoppingDB $SQLCommand
[Int32]$CMISPF = 0
[Int32]$CMISPI = 0
[Int32]$CMISPP = 0
[Int32]$CMFSPF = 0
Write-Output "Total machines = $(($Machines | Measure-Object).Count)"
"'CompletedOrderID','MachineName','PackageId','Package Name','Shopping Status','SCCM Status'" | Out-File -FilePath $CSVFile 
foreach ($Machine in $Machines) {
    $SQLCommand = "select	AdvertisementID`
    from	v_Advertisement`
    where	PackageID = '$($Machine.PackageID)'`
    and		CollectionID in `
			    (select	CollectionID`
			    from	v_FullCollectionMembership FCM`
			    join	v_R_System STM on FCM.ResourceID=STM.ResourceID`
			    and		stm.Netbios_Name0 = '$($Machine.MachineName)'`
			    and		CollectionID in `
				    (Select	CollectionID`
				    from	vFolderMembers FM`
				    join	v_Collection COL on fm.InstanceKey = COL.CollectionID`
				    where	InstanceKey in `
					    (Select	CollectionID `
					    from	v_Collection `
					    where	Name like '%$($Machine.PackageID)%')`
				    And		ContainerNodeID = `
					    (select ContainerNodeID`
					    from	vSMS_Folders`
					    where	Name = 'Deployment Collections - Do Not Modify')))"

    $DNMAdvertID = Get-CMNSQLQuery $DataSource $Database $SQLCommand

    $SQLCommand = "SELECT  sys.netbios_name0 WKID, adv.AdvertisementID,adv.AdvertisementName, `
	        stat.LastStateName, stat.lastexecutionresult [Result], DATEADD(HH,-5,stat.laststatustime) [Last Status Time EST], `
	        adv.PackageID,`
	        pkg.Name AS Package, `
	        adv.ProgramName AS Program, `
	        adv.Comment AS Description,  `
	        adv.CollectionID`
        FROM v_advertisement adv `
        JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID `
        JOIN v_ClientAdvertisementStatus  stat ON stat.AdvertisementID = adv.AdvertisementID `
        JOIN v_R_System sys ON stat.ResourceID=sys.ResourceID `
        WHERE sys.Netbios_Name0 = '$($Machine.MachineName)' and `
	          LastStateName != 'Accepted - No Further Status' and `
	          LastStateName != 'No Status' and`
	          adv.PackageID = '$($Machine.PackageId)'"
    
    $SCCMStatus = Get-CMNSQLQuery $DataSource $Database $SQLCommand

    $SQLCommand = "select Name`
        from v_Package `
        where PackageID = '$($Machine.PackageId)'"
    $Package = Get-CMNSQLQuery $DataSource $Database $SQLCommand

    Switch ($Machine.DeliveryStatus) {
        0 {$Status = 'Pending Deployment'}
        1 {$Status = 'Installed'}
        2 {$Status = 'Failed Install'}
        3 {$Status = 'Pending Install'}
        default {$Status = 'Unknown'}
    }

    #Write-Output "$($Machine.CompletedOrderID) - $($Machine.MachineName) - Shopping Status is $Status"
    $SCCMStat = 'Unkown'
    Foreach ($Stat in $SCCMStatus) {
        #Write-Output "`tAdvertisementID $($Stat.AdvertisementID) - $($Stat.AdvertisementName) shows $($Stat.LastStateName) on $($Stat.'Last Status Time EST')"
        if ($Stat.LastStateName -match 'fail') {$SCCMStat = 'Failed'}
        elseif ($Stat.LastStateName -match 'Succ') {$SCCMStat = 'Success'}
    }
    <#
    switch ($Status)
    {
        'Pending Deployment' 
        {
            if($SCCMStat -eq 'Success')
            {
                $FGColor = 'Yellow'
                $CMISPP += 1
            }
            else
            {
                $FGColor = 'Green'
            }
        }
        'Installed' 
        {
            if($SCCMStat -eq 'Success')
            {
                $FGColor = 'Green'
                $CMISPI += 1
            }
            else
            {
                $FGColor = 'Red'
            }
        }
        'Failed Install' 
        {
            if($SCCMStat -eq 'Failed')
            {
                $FGColor = 'Green'
                $CMFSPF += 1
            }
            else
            {
                $FGColor = 'Yellow'
            }
        }
        'Pending Install' 
        {
            if($SCCMStat -eq 'Success')
            {
                $FGColor = 'Blue'
                $CMISPF += 1
            }
            else
            {
                $FGColor = 'Green'
            }
        }
    }
    #>
    "'$($Machine.CompletedOrderID)','$($Machine.MachineName)','$($Machine.PackageId)','$($Package.Name)','$Status','$SCCMStat'" | Out-File -FilePath $CSVFile -Append
}