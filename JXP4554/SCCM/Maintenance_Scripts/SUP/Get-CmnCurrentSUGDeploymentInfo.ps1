[CmdletBinding()]
PARAM(
    [Parameter(Mandatory = $true, HelpMessage = 'SiteServer Name')]
    [String]$siteServer
)

Function Get-CmnSoftwareUpdateGroup {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CMNSCCMConnectoinInfo and New-CmnLogEntry functions for these scripts, 
        please make sure you account for that.

    .PARAMETER sccmConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNsccmConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
         Switch to say if we write to the log file. Otherwise, it will just be write-verbose

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'Software Update Group to enumerate')]
        [String]$softwareUpdateGroup,

        [Parameter(Mandatory = $false, HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false, HelpMessage = 'Max Log size')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Max number of history logs')]
        [Int]$maxLogHistory = 5
    )

    begin {
        # Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) {$logEntries = $true}
        else {$logEntries = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Get-CmnSoftwareUpdateGroup';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        $cimSession = New-CimSession -ComputerName $sccmConnectionInfo.Computername

        # Create a hashtable with your output info
        $returnHashTable = @{}

        New-CmnLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CmnLogEntry -entry "sccmConnectionInfo = $sccmConnectionInfo" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "softwareUpdateGroup = $softwareUpdateGroup" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CmnLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CmnLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        if ($PSCmdlet.ShouldProcess($softwareUpdateGroup)) {
            $sms_SoftwareUpdateGroup = Get-CimInstance -CimSession $cimSession -Query "Select * from SMS_AuthorizationList where LocalizedDisplayName = '$softwareUpdateGroup'" -Namespace $sccmConnectionInfo.NameSpace
            $sms_SoftwareUpdateGroup = Get-CimInstance -CimSession $cimSession -InputObject $sms_SoftwareUpdateGroup
            New-CmnLogEntry -entry 'Building array of updates' -type 1 @NewLogEntry
            $returnHashTable.Add('Authorization List', $sms_SoftwareUpdateGroup.LocalizedDisplayName)
            $updates = New-Object -TypeName System.Collections.ArrayList
            if ($sms_SoftwareUpdateGroup.Updates.Count -ne 0 -and $sms_SoftwareUpdateGroup.Updates.Count -ne $null) {
                foreach ($update in $sms_SoftwareUpdateGroup.Updates) {
                    New-CmnLogEntry -entry "Getting update CI_ID $update" -type 1 @NewLogEntry
                    $updateDetail = Get-CimInstance -CimSession $cimSession -Query "SELECT * FROM SMS_SoftwareUpdate WHERE CI_ID='$update'" -Namespace $sccmConnectionInfo.NameSpace
                    $updateObject = New-Object PSObject -Property @{
                        CI_UniqueID = $updateDetail.CI_UniqueID;
                        ArticleID                      = $updateDetail.ArticleID;
                        BulletinID                     = $updateDetail.BulletinID;
                        LocalizedCategoryInstanceNames = $updateDetail.LocalizedCategoryInstanceNames;
                        LocalizedDescription           = $updateDetail.LocalizedDescription;
                        LocalizedDisplayName           = $updateDetail.LocalizedDisplayName;
                    }
                    New-CmnLogEntry -entry "Update Detail $($updateObject)" -type 1 @NewLogEntry
                    $updates.Add($updateObject) | Out-Null
                }
                $returnHashTable.Add('Updates',$updates)
            }
        }
    }

    End {
        New-CmnLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.SoftwareUpdateGroup')
        Return $obj	
    }
} #End Get-CmnSoftwareUpdateGroup

$sccmConnectionInfo = @{}
try {
    #Get the site code from the site server
    $siteCode = $(Get-CimInstance -ComputerName $siteServer -Namespace 'root/SMS' -ClassName SMS_ProviderLocation -ErrorAction SilentlyContinue).SiteCode
}
catch {
    #if we don't get a result, we have a problem.
    throw "Unable to connect to Site Server $siteServer"
    break
}
#Now, to determine the SQL Server and database being used for the site.
$DataSourceWMI = $(Get-CimInstance -ClassName SMS_SiteSystemSummarizer -Namespace root/sms/site_$siteCode -ComputerName $siteServer -Filter "Role = 'SMS SQL SERVER' and SiteCode = '$siteCode' and ObjectType = 1").SiteObject
$sccmConnectionInfo.Add('SccmDBServer', ($DataSourceWMI -replace '.*\\\\([A-Z0-9_.]+)\\.*', '$+'))
$sccmConnectionInfo.Add('SCCMDB', ($DataSourceWMI -replace ".*\\([A-Z_0-9]*?)\\$", '$+'))
$sccmConnectionInfo.Add('SiteCode', $SiteCode)
$sccmConnectionInfo.Add('ComputerName', $SiteServer)
$sccmConnectionInfo.Add('NameSpace', "Root/SMS/Site_$siteCode")

$cimSession = New-CimSession -ComputerName LOUAPPWTS1140
$sms_UpdateAssigments = Get-CimInstance -ClassName SMS_UpdatesAssignment -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
$sms_UpdateGroupAssigments = Get-CimInstance -ClassName SMS_UpdateGroupAssignment -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
$sms_SoftwareUpdateGroup = Get-CimInstance -CimSession $cimSession -ClassName SMS_AuthorizationList -Namespace $sccmConnectionInfo.NameSpace
$sms_SoftwareUpdateGroup = Get-CimInstance -CimSession $cimSession -InputObject $sms_SoftwareUpdateGroup
