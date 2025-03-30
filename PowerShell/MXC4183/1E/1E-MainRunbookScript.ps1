$SiteServer = '\`d.T.~Vb/{5222DF93-9275-48CE-9901-831FA2CAA83E}\`d.T.~Vb/'
$ShoppingDBServer = '\`d.T.~Vb/{5B67B07A-136B-4B1F-8EDD-06776D6B8858}\`d.T.~Vb/'
$ShoppingDB = '\`d.T.~Vb/{D3C3B15F-65D1-4917-AAE1-0BEB262228AD}\`d.T.~Vb/'
$LogLevel = 1
<#
.SYNOPSIS
	This is to accomodate 1E shopping and Physical vs VM Deployments

.DESCRIPTION
	You provide the ObjectType to add the scope to, the Type of object, and the RoleName. If you add a role that already exists,
	the function will behave the same as if the role wasn't there. In either case, the role will be there afterwards.

.LINK
	http://configman-notes.com

.NOTES
	Author:	Jim Parris
	Email:	Jim@ConfigMan-Notes
	Date:	10/19/2016
	PSVer:	2.0/3.0
    Ver:    1.2.3

    Removed some of the email from the first part of the script where we check status/advertID
#>
Function Sent-StatusEmail {
    PARAM
    (
        [Parameter(Mandatory = $true)]
        [String]$Status,
        [Parameter(Mandatory = $true)]
        [String]$StatusMatch,
        [Parameter(Mandatory = $true)]
        [String]$Product,
        [Parameter(Mandatory = $true)]
        [String]$WKID,
        [Parameter(Mandatory = $false)]
        [String]$FullName = 'UnKnown',
        [Parameter(Mandatory = $true)]
        [String]$UserAccount,
        [Parameter(Mandatory = $true)]
        [String]$eMail,
        [Parameter(Mandatory = $true)]
        [String]$Action,
        [Parameter(Mandatory = $true)]
        [String]$PackageID,
        [Parameter(Mandatory = $false)]
        [String]$CRID
    )

    New-LogEntry 'Starting Sent-StatusEmail' 1 'Sent-StatusEmail'
    New-LogEntry "Status = $Status" 1 'Sent-StatusEmail'
    New-LogEntry "StatusMatch = $StatusMatch" 1 'Sent-StatusEmail'
    New-LogEntry "Product = $Product" 1 'Sent-StatusEmail'
    New-LogEntry "WKID = $WKID" 1 'Sent-StatusEmail'
    New-LogEntry "FullName = $FullName" 1 'Sent-StatusEmail'
    New-LogEntry "UserAccount = $UserAccount" 1 'Sent-StatusEmail'
    New-LogEntry "eMail = $eMail" 1 'Sent-StatusEmail'
    New-LogEntry "Action = $Action" 1 'Sent-StatusEmail'
    New-LogEntry "CRID = $CRID" 1 'Sent-StatusEmail'

    Switch ($StatusMatch) {
        'Success' {
            $Subject = "$Product successfully $($Action)ed"
        }
        'SuccessFromFailure' {
            $Subject = "$Product Successfully $($Action)ed"
        }
        'Fail' {
            $Subject = "$Product $($Action)ation Failed"
        }
        'FailedToPending' {
            $Subject = "$Product $($Action)ation Pending"
        }
        'SuccessToAnythingElse' {
            $Subject = "$Product had issues $($Action)ing on/from $WKID"
        }
    }
    $Subject = $Subject -replace '<b>', ''
    $Subject = $Subject -replace '</b>', ''
    if ($CRID.Length -ge 1) {
        $CRID = " with <b>CR#$CRID</b>"
    }
    $eMailMessage = $eMailTemplate -replace '@Message', $eMailMessage[$StatusMatch]
    $eMailMessage = $eMailMessage -replace '@Status', $Status
    $eMailMessage = $eMailMessage -replace '@Product', $Product
    $eMailMessage = $eMailMessage -replace '@WKID', $WKID
    $eMailMessage = $eMailMessage -replace '@FullName', $FullName
    $eMailMessage = $eMailMessage -replace '@UserAccount', $UserAccount
    $eMailMessage = $eMailMessage -replace '@eMail', $eMail
    $eMailMessage = $eMailMessage -replace '@Action', $Action
    $eMailMessage = $eMailMessage -replace '@Lction', ($Action.ToLower())
    $eMailMessage = $eMailMessage -replace '@PackageID', $PackageID
    $eMailMessage = $eMailMessage -replace '@CRID', $CRID
    if ($Action -eq 'Install') {
        $eMailMessage = $eMailMessage -replace '@Direction', 'on'
        $eMailMessage = $eMailMessage -replace '@installExtra', 'You may also, at any time, uninstall this software by visiting the
 <a href="http://go/shopping">Humana App Shop</a>, click on the "Workstation Icon" (My Software) and view All Orders.</p>'
    }
    else {
        $eMailMessage = $eMailMessage -replace '@Direction', 'from'
        $eMailMessage = $eMailMessage -replace '@installExtra', ''
    }
    if ($email.ToLower() -eq 'humanaappshop@humana.com') {
        New-LogEntry "Email for $FullName didn't have a valid email address"
        $eMailMessage = $eMailMessage + " $FullName"
    }
    New-LogEntry $eMailMessage 2
    $SMTPServer = "pobox.humana.com"
    #$SMTPSender = "ConfigMgrSupport@humana.com"
    $SMTPSender = "HumanaAppShop@humana.com"
    switch ($StatusMatch) {
        'Success' {
            Send-MailMessage -To $eMail <# -cc 'HumanaAppShop@humana.com' #> -From $SMTPSender -SmtpServer $SMTPServer -Subject $Subject -Body $eMailMessage -BodyAsHtml
        }
        'Fail' {
            Send-MailMessage -To $eMail -cc 'HumanaAppShop@humana.com' -From $SMTPSender -SmtpServer $SMTPServer -Subject $Subject -Body $eMailMessage -BodyAsHtml
        }
        default {
            Send-MailMessage -To 'HumanaAppShop@Humana.com' -From $SMTPSender -SmtpServer $SMTPServer -Subject $Subject -Body $eMailMessage -BodyAsHtml
        }
    }
}

Function Get-AdvertID {
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$WKID,
        [Parameter(Mandatory = $true)]
        [String]$PackageID
    )
    New-LogEntry 'Starting Get-AdvertID' 1 'Get-AdvertID'
    $SQLCommand = "select ObjectType`
        from vFolderMembers`
        where InstanceKey = '$PackageID'"

    $PackageTypes = Get-CMNDatabaseData -isSQLServer -connectionString "Data Source=$($SCCMConnectionInfo.SCCMDBServer);Integrated Security=SSPI;Initial Catalog=$($SCCMConnectionInfo.SCCMDB)" -query $SQLCommand
    New-LogEntry "Package type is $($PackageTypes.ObjectType)" 1 'Get-AdvertID'
    $IsPackage = $false
    foreach ($PackageType in $PackageTypes) {
        if (($PackageType.ObjectType) -eq 2) {
            $IsPackage = $true
        }
    }
    If ($IsPackage) {
        New-LogEntry "Getting valid AdvertID" 1 'Get-AdvertID'
        $SQLCommand = "select Top 1 AdvertisementID`
        from	v_Advertisement`
        where	PackageID = '$PackageID'`
        and		CollectionID in `
			        (select	CollectionID`
			        from	v_FullCollectionMembership FCM`
			        join	v_R_System STM on FCM.ResourceID=STM.ResourceID`
			        and		stm.Netbios_Name0 = '$WKID'`
			        and		CollectionID in `
				        (Select	CollectionID`
				        from	vFolderMembers FM`
				        join	v_Collection COL on fm.InstanceKey = COL.CollectionID`
				        where	InstanceKey in `
					        (Select	CollectionID `
					        from	v_Collection `
					        where	Name like '%$PackageID%')`
				        And		ContainerNodeID = `
					        (select ContainerNodeID`
					        from	vSMS_Folders`
					        where	Name = 'Deployment Collections - Do Not Modify')))"

        $MonAdvertID = Get-CMNDatabaseData -isSQLServer -connectionString "Data Source=$($SCCMConnectionInfo.SCCMDBServer);Integrated Security=SSPI;Initial Catalog=$($SCCMConnectionInfo.SCCMDB)" -query $SQLCommand
        Return $($MonAdvertID.AdvertisementID)
    }
    else {
        Return $false
    }
}#End Get-AdvertID

Function New-LogEntry {
    Param
    (
        [Parameter(Position = 0, Mandatory = $true)]
        [String]$Entry,

        [Parameter(Position = 1, Mandatory = $false)]
        [ValidateSet(1, 2, 3)]
        [INT32]$type = 1,

        [Parameter(Position = 2, Mandatory = $false)]
        [String]$component = $ScriptName
    )
    Write-Verbose $Entry
    if ($type -ge $Script:LogLevel) {
        if ($Entry.Length -eq 0) {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}#End New-LogEntry

Function Get-CMNSCCMConnectionInfo {
    param
    (
        [parameter(Mandatory = $true, HelpMessage = 'Site server where the SMS Provider is installed')]
        [ValidateScript( { Test-Connection -ComputerName $_ -Count 1 -Quiet })]
        [string]$SiteServer
    )

    New-LogEntry 'Starting Get-CMNSCCMConnectionInfo' 1 'Get-CMNSCCMConnectionInfo'
    $SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

    $Script:WMIQueryParameters = @{
        ComputerName = $SiteServer
        Namespace    = "root/SMS/Site_$SiteCode"
    }

    $DataSourceWMI = $(Get-WmiObject -Class SMS_SiteSystemSummarizer -Namespace root\sms\site_$SiteCode -ComputerName $SiteServer -Filter "Role = 'SMS SQL SERVER' and SiteCode = '$SiteCode' and ObjectType = 1").SiteObject
    $SCCMDBServer = $DataSourceWMI -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'
    $SCCMDB = $DataSourceWMI -replace ".*\\([A-Z_0-9]*?)\\$", '$+'
    $ReturnHashTable = @{
        SCCMDBServer = $SCCMDBServer;
        SCCMDB       = $SCCMDB;
        SiteCode     = $SiteCode;
        ComputerName = $SiteServer;
        NameSpace    = "Root\SMS\Site_$SiteCode"
    }
    $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
    $obj.PSObject.TypeNames.Insert(0, 'CMN.SCCMConnectionInfo')
    Return $obj
} #End Get-CMNSCCMConnectionInfo

Function Get-CMNDatabaseData {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$connectionString,
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [switch]$isSQLServer
    )
    New-LogEntry 'Starting Get-CMNDatabaseData' 1 'Get-CMNDatabaseData'
    New-LogEntry "ConnectionString = $connectionString" 1 'Get-CMNDatabaseData'
    New-LogEntry "Query = $query" 1 'Get-CMNDatabaseData'
    New-LogEntry "isSqlServer = $isSQLServer" 1 'Get-CMNDatabaseData'
    if ($isSQLServer) {
        New-LogEntry 'in SQL Server mode' 1 'Get-CMNDatabaseData'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        New-LogEntry 'in OleDB mode' 1 'Get-CMNDatabaseData'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($isSQLServer) {
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    }
    else {
        $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
    }
    $dataset = New-Object -TypeName System.Data.DataSet
    New-LogEntry 'Getting ready to fill adapter' 1 'Get-CMNDatabaseData'
    $adapter.Fill($dataset) | Out-Null
    New-LogEntry 'Returning results' 1 'Get-CMNDatabaseData'
    return $dataset.Tables[0]
    $connection.close()
} #End Get-CMNDatabaseData

Function Get-CMNConnectionString {
    <#
    .Synopsis
        This function will return the connection string

    .DESCRIPTION
        This function will query the database $Database on $DatabaseServer using the $SQLCommand. It uses windows authentication

    .PARAMETER DatabaseServer
        This is the database server that the query will be run on

    .PARAMETER Database
        This is the database on the server to be queried

    .EXAMPLE
		Get-CMNSQLQuery 'DB1' 'DBServer' 'Select * from v_Employees'

    .LINK
        http://configman-notes.com

    .NOTES

    #>
    Param
    (
        [Parameter(Mandatory = $true)]
        [String]$DatabaseServer,
        [Parameter(Mandatory = $true)]
        [String]$Database
    )
    Return "Data Source=$DataBaseServer;Integrated Security=SSPI;Initial Catalog=$Database"
} #End Get-CMNConnectionString

Function Invoke-CMNDatabaseQuery {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$connectionString,
        [Parameter(Mandatory = $true)]
        [string]$query,
        [Parameter(Mandatory = $true)]
        [switch]$isSQLServer
    )
    New-LogEntry 'Starting Invoke-CMNDatabaseQuery' 1 'Invoke-CMNDatabaseQuery'
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($pscmdlet.shouldprocess($query)) {
        $connection.Open()
        $command.ExecuteNonQuery() | Out-Null
        $connection.close()
    }
} #End Invoke-CMNDatabaseQuery


#Import-Module CMNSCCMTools

$LogFile = 'C:\Temp\Check-OrderStatus.log'
if ($ClearLog) {
    if (Test-Path $Logfile) {
        Remove-Item $LogFile
    }
}

$eMailTemplate = '<html><head>
<title>Humana AppShop Application @Product @Status</title>
</head><body>
<h1 style=''font-size:20.0pt;font-family:"Arial","sans-serif";color:#4F6228''><b>Humana App Shop</b></h1>
<hr>
@Message
</body></html>'

$eMailMessage = @{
    Success               = '<p><B>@Product successfully @Actioned</b>.</p>
<p>The software you requested <b>@Product</b> was successfully @Actioned on <b>@WKID</b> for
 <b>@FullName (@UserAccount)</b>. @installExtra
 <p>Thank you for using <a href="http://go/shopping">Humana App Shop</a></p>';

    Fail                  = '<p><b>Application @Actionation @Status</b></p>
<p>The @Actionation of <b>@Product</b> on <b>@WKID</b> @CRID encountered an issue and failed to @Action
 @Direction your workstation. Please ensure that you have followed the appropriate guidelines from
 your previously APPROVED email. Please request a re@Action by visiting the Humana App Shop by
 resubmitting a new request. If this is the second time the software has failed to @Action @Direction your
 workstation, please open a request through Service Catalog&gt;&gt;
 <a href="http://servicecatalog.humana.com/sc/catalog.product.aspx?product_id=HUM_CSS">(CSS
 &mdash; Report an Issue)</a> to have the software manually @Actioned by DSI.</p>
 <p><span style=''color:red''><b>Attention Virtual Machines Users:</b></span></p>
 <p><span style=''color:red''>Please take note, if you are on a virtual machine, please check
 the Local Disk (C:) space. Depending on the software you selected, lack of
 appropriate space could affect the installation. Try cleaning disk space and
 resubmitting a new request. If more drive space is still required, please
 open a request here&gt;&gt; </span><a href="http://go/reportanissue">(Go/Reportanissue)</a>.</p>
 <p><a href="http://go/shopping">Humana App Shop</a></p>';

    SuccessFromFailure    = '<p>Congratulations, you can now use <b>@Product</b>! It appears that
 shopping had reported a problem, however, the issue has been corrected. If you receive any emails or notice shopping showing a
 status of failure, please ignore.</p>';

    FailedToPending       = '<p>This is an informational email. It appears that something may have
 interrupted the install of <b>@Product</b> on <b>@WKID</b> for <b>@FullName (@UserAccount)</b>. The problem has been
 corrected and the install will proceed. This requires no action on your part.</p>';

    SuccessToAnythingElse = '<p><b>This message is only sent to HumanaAppShop and not the user.</b></p>
 <p>It appears there may be a problem with the @actionation of <b>@Product</b> @Direction <b>@WKID</b> - <b>@FullName (@UserAccount)</b></p>
 <p>PackageID = <b>@PackageID</b> @CRID</p>'
}

$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -SiteServer $SiteServer
$SCCMConnectionString = Get-CMNConnectionString -DatabaseServer $SCCMConnectionInfo.SCCMDBServer -Database $SCCMConnectionInfo.SCCMDB
$ShoppingConnectionString = Get-CMNConnectionString -DatabaseServer $ShoppingDBServer -Database $ShoppingDB

$SCCMToShoppintResults = @{
    'Accepted - No Further Status' = 0;
    'Cancelled'                    = 2;
    'Failed'                       = 2;
    'No Status'                    = 0;
    'Reboot Pending'               = 1;
    'Retrying'                     = 3;
    'Running'                      = 3;
    'Succeeded'                    = 1;
    'Waiting'                      = 3;
    Null                           = 3;
}

New-LogEntry 'Starting Script' 2
New-LogEntry "SiteServer = $SiteServer"
New-LogEntry "ShoppingDBServer = $ShoppingDBServer"
New-LogEntry "ShoppingDB = $ShoppingDB"
New-LogEntry "SCCMDBServer = $($SCCMConnectionInfo.SCCMDBServer)"
New-LogEntry "SCCMDB = $($SCCMConnectionInfo.SCCMDB)"

#Execute query to get list pending installs

$Query = "SELECT tb_completedorder.completedorderid,
       tb_machine.machinename,
       tb_completedorder.advertid,
       tb_completedorder.packageid,
       tb_completedorder.ordertype,
       tb_user.fullname,
       tb_user.useraccount,
       tb_user.useremail,
       tb_application.displayname,
       tb_application.applicationref,
       tb_completedorder.deliverystatus
FROM   tb_completedorder
       INNER JOIN tb_machine
               ON tb_completedorder.machineid = tb_machine.machineid
       INNER JOIN tb_user
               ON tb_completedorder.userid = tb_user.userid
       INNER JOIN tb_application
               ON tb_completedorder.applicationid = tb_application.applicationid
WHERE  ( tb_completedorder.deliverystatus = 3
          OR tb_completedorder.deliverystatus = 2 )
       AND ( tb_completedorder.advertid <> ''
             AND tb_completedorder.programname <> 'AppModel' )
       AND ( Datediff(day, requestedtimestamp, Getdate()) < 3 )
       AND ( tb_machine.machinename <> ''
              OR tb_machine.machinename IS NOT NULL )
ORDER  BY tb_completedorder.completedorderid"

New-LogEntry 'Getting OrderStatus'
$OrderIDs = Get-CMNDatabaseData -isSQLServer -connectionString $ShoppingConnectionString -query $Query
$Count_OrderIDs = $OrderIDs | Measure-Object | Select-Object -ExpandProperty Count
New-LogEntry "Preparing to cycle through results. Count = $Count_OrderIDs"
$OrderCount = 1
#Cycle through results
if ($Count_OrderIDs -gt 0) {
    foreach ($OrderID in $OrderIDs) {
        New-LogEntry 'First, verify advertid - Update tb_CompletedOrders as necessary'
        if ($ShowProgress) {
            Write-Progress -Activity 'Process Orders' -Status "Processing order $($OrderID.CompletedOrderID)" -PercentComplete (($OrderCount / $Count_OrderIDs) * 100) -CurrentOperation "$OrderCount/$Count_OrderIDs"
            $OrderCount++
        }
        New-LogEntry "Getting AdvertID for $($OrderID.MachineName) and PackageID $($OrderID.PackageID)"
        $AdvertID = Get-AdvertID -WKID $OrderID.MachineName -PackageID $OrderID.PackageID
        if ($AdvertID -ne $OrderID.AdvertID -and $AdvertID) {
            New-LogEntry 'Preparing to update advertid'
            $Query = "Update tb_CompletedOrder`
                    set AdvertID = '$AdvertID'`
                    where CompletedOrderID = '$($OrderID.CompletedOrderID)' --Original $($OrderID.AdvertID)"
            Invoke-CMNDatabaseQuery -connectionString $ShoppingConnectionString -query $Query -isSQLServer
            New-LogEntry $Query 2
        }

        #Query Status from CAS
        $Query = "SELECT  stat.LastStateName`
		    FROM v_advertisement adv`
		    JOIN v_Package  pkg ON adv.PackageID = pkg.PackageID`
		    JOIN v_ClientAdvertisementStatus stat ON stat.AdvertisementID = adv.AdvertisementID`
		    JOIN v_R_System sys ON stat.ResourceID=sys.ResourceID`
		    WHERE sys.Netbios_Name0='$($OrderID.MachineName)' and`
			    stat.AdvertisementID = '$($OrderID.AdvertID)' and`
			      LastStateName != 'Accepted - No Further Status' and `
			      LastStateName != 'No Status'"
        $Status = (Get-CMNDatabaseData -isSQLServer -connectionString $SCCMConnectionString -query $Query).LastStateName
        if ($TestEmailCompleted) {
            Sent-StatusEmail -StatusMatch 'Success' -Status 'was <b>successful</b>' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail -UserAccount $OrderID.UserAccount -Action 'install' -PackageID $OrderID.PackageID -CRID $OrderID.ApplicationRef
            Sent-StatusEmail -StatusMatch 'Fail' -Status 'has <b>failed</b>' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail -UserAccount $OrderID.UserAccount -Action 'install' -PackageID $OrderID.PackageID -CRID $OrderID.ApplicationRef
            Sent-StatusEmail -StatusMatch 'SuccessFromFailure' -Status 'was <b>successful</b>' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail -UserAccount $OrderID.UserAccount -Action 'install' -PackageID $OrderID.PackageID -CRID $OrderID.ApplicationRef
            Sent-StatusEmail -StatusMatch 'FailedToPending' -Status 'is <b>pending</b>' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail -UserAccount $OrderID.UserAccount -Action 'install' -PackageID $OrderID.PackageID -CRID $OrderID.ApplicationRef
            Sent-StatusEmail -StatusMatch 'SuccessToAnythingElse' -Status 'has <b>failed</b>' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail -UserAccount $OrderID.UserAccount -Action 'install' -PackageID $OrderID.PackageID -CRID $OrderID.ApplicationRef
            $TestEmailCompleted = $false
        }
        if ($Status) {
            New-LogEntry "WKID = $($OrderID.MachineName)"
            [Int16]$SCCMStatus = $SCCMToShoppintResults[$Status]
            if ($OrderID.OrderType -eq 'I') {
                $Action = 'Install'
            }
            else {
                $Action = 'Uninstall'
            }
            if ($OrderID.UserEmail -eq $null -or $OrderID.UserEmail -eq '') {
                $OrderID.UserEmail = 'HumanaAppShop@Humana.com'
            }
            #Sent-StatusEmail -StatusMatch 'Success' -Status 'Success' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail
            if (($SCCMStatus -ne $OrderID.DeliveryStatus) -and ($SCCMStatus -match '[0-3]') -and ($OrderID.DeliveryStatus -match '[0-3]')) {
                #Update Status in tb_completedOrder
                $Query = "Update tb_CompletedOrder`
                        Set DeliveryStatus = $SCCMStatus`
                        where CompletedOrderID = '$($OrderID.CompletedOrderID)' --Original $($OrderID.DeliveryStatus)"
                Invoke-CMNDatabaseQuery -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                New-LogEntry $Query 2
            }
        }
    }#End Foreach
    if ($ShowProgress) {
        Write-Progress -Activity 'Process Orders' -Completed
    }

    #Scan for any success or fail status in the past 3 days that do not have an email sent and send the email
    $Query = "SELECT tb_completedorder.completedorderid,
       tb_machine.machinename,
       tb_completedorder.advertid,
       tb_completedorder.packageid,
       tb_completedorder.ordertype,
       tb_user.fullname,
       tb_user.useraccount,
       tb_user.useremail,
       tb_application.displayname,
       tb_application.applicationref,
       tb_completedorder.deliverystatus
FROM   tb_completedorder
       JOIN tb_machine
         ON tb_completedorder.machineid = tb_machine.machineid
       JOIN tb_user
         ON tb_completedorder.userid = tb_user.userid
       JOIN tb_application
         ON tb_completedorder.applicationid = tb_application.applicationid
       LEFT JOIN humana_status_email_sent EMS
              ON EMS.completedorderid = tb_completedorder.completedorderid
WHERE  ( ( tb_completedorder.deliverystatus = 1 )
          OR ( tb_completedorder.deliverystatus = 2 ) )
       AND ( tb_completedorder.programname != 'AppModel' )
       AND ( Datediff(day, requestedtimestamp, Getdate()) < 9 )
       AND ( ( EMS.mailsent IS NULL )
              OR ( EMS.mailsent != tb_completedorder.deliverystatus
                    OR EMS.ordertype != tb_completedorder.ordertype ) )
ORDER  BY tb_completedorder.CompletedOrderId"
    $OrderIDs = Get-CMNDatabaseData -connectionString $ShoppingConnectionString -query $Query -isSQLServer
    $EmailNeeded_Count = $OrderIDs | Measure-Object | Select-Object -ExpandProperty Count
    if ($EmailNeeded_Count -gt 0) {
        $OrderCount = 1
        Foreach ($OrderID in $OrderIDs) {
            if ($ShowProgress) {
                Write-Progress -Activity 'Send Emails' -Status "Processing order $($OrderID.CompletedOrderID)" -PercentComplete (($OrderCount / $EmailNeeded_Count) * 100) -CurrentOperation "$OrderCount/$($EmailNeeded_Count)"
                $OrderCount ++
            }
            if ($OrderID.OrderType -eq 'I') {
                $Action = 'install'
            }
            else {
                $Action = 'uninstall'
            }
            if (($OrderID.CompletedOrderId.GetType().Name -ne 'DBNull') -and ($OrderID.CompletedOrderId -ne $null) -and ($OrderID.CompletedOrderId -ne '')) {
                if (($OrderID.UserEmail -eq $null) -or ($OrderID.UserEmail -eq '') -or ($OrderID.UserEmail.GetType().Name -eq 'DBNull')) {
                    New-LogEntry "eMail invalid for orderID $($OrderID.CompletedOrderId) - $($OrderID.FullName) - $($OrderID.AdvertID) $($OrderID.MachineName)" 3
                    if ($OrderID.PSObject.Properties["UserEmail"]) {
                        New-LogEntry 'Setting email address' 2
                        $OrderID.UserEmail = "HumanaAppShop@humana.com"
                    }
                    else {
                        New-LogEntry 'Creating email address' 2
                        $OrderID | Add-Member -MemberType NoteProperty -Name 'UserEmail' -Value 'HumanaAppShop@humana.com'
                    }
                    New-LogEntry "eMail is now $($OrderID.UserEmail)" 2
                }
                if ($OrderID.DeliveryStatus -eq 1) {
                    New-LogEntry "Send $($OrderID.UserEmail) Success email" 2
                    Sent-StatusEmail -StatusMatch 'Success' -Status 'was <b>successful</b>' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail -UserAccount $OrderID.UserAccount -Action $Action -PackageID $OrderID.PackageID -CRID $OrderID.ApplicationRef
                    #Check to see if there is already a row for that orderID
                    $Query = "SELECT     CompletedOrderID, MailSent, OrderType`
                    FROM         Humana_Status_Email_sent`
                    WHERE     (CompletedOrderID = $($OrderID.CompletedOrderId))"
                    $Result = Get-CMNDatabaseData -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                    if (($Result.CompletedOrderID) -ge 1) {
                        $Query = "UPDATE    Humana_Status_Email_sent`
                        SET              MailSent = 1, OrderType = '$($OrderID.OrderType)'
                        WHERE     (CompletedOrderID = $($OrderID.CompletedOrderID))"
                        Invoke-CMNDatabaseQuery -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                    }
                    else {
                        #No Rows, time it insert it
                        $Query = "INSERT INTO Humana_Status_Email_sent
                                                (CompletedOrderID, MailSent, OrderType)
                        VALUES     ($($OrderID.CompletedOrderID), 1, '$($OrderID.OrderType)')"
                        Invoke-CMNDatabaseQuery -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                    }
                }
                elseif ($OrderID.DeliveryStatus -eq 2) {
                    New-LogEntry "Send $($OrderID.UserEmail) Failed email" 2
                    Sent-StatusEmail -StatusMatch 'Fail' -Status 'has <b>failed</b>' -Product $OrderID.DisplayName -WKID $OrderID.MachineName -FullName $OrderID.FullName -eMail $OrderID.UserEmail -UserAccount $OrderID.UserAccount -Action $Action -PackageID $OrderID.PackageID -CRID $OrderID.ApplicationRef
                    #Check to see if there is already a row for that orderID
                    $Query = "SELECT     CompletedOrderID, MailSent`
                    FROM         Humana_Status_Email_sent`
                    WHERE     (CompletedOrderID = $($OrderID.CompletedOrderId))"
                    $Result = Get-CMNDatabaseData -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                    if (($Result.CompletedOrderID) -ge 1) {
                        $Query = "UPDATE    Humana_Status_Email_sent`
                        SET              MailSent = 2, OrderType = '$($OrderID.OrderType)'
                        WHERE     (CompletedOrderID = $($OrderID.CompletedOrderID))"
                        Invoke-CMNDatabaseQuery -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                    }
                    else {
                        #No Rows, time it insert it
                        $Query = "INSERT INTO Humana_Status_Email_sent
                                                (CompletedOrderID, MailSent, OrderType)
                        VALUES     ($($OrderID.CompletedOrderID), 2, '$($OrderID.OrderType)')"
                        Invoke-CMNDatabaseQuery -connectionString $ShoppingConnectionString -query $Query -isSQLServer
                    }
                }
            }
        }
        if ($ShowProgress) {
            Write-Progress -Activity 'Send Emails' -Completed
        }
    }
}

New-LogEntry 'Finished!' 2