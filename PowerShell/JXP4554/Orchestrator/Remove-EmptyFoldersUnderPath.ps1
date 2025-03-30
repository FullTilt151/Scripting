Function Remove-EmptyFoldersUnderPath {
    <#
    .SYNOPSIS
        Returns folders under a path provided and, if the switch is provided, removes them

    .DESCRIPTION
        Returns an array of folders that exist under the path provided.

    .PARAMETER cimSession
        This is a variable containing the cim session to the site server
        
    .PARAMETER siteCode
        String of the 3 charachter site code (so we can build the namespace)

    .PARAMETER removeEmptyFolders
        Switch to indicate if we are going to remove the empty folders

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

    [CmdletBinding(ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'Cim Session to the site server')]
        [PSObject]$cimSession,

        [Parameter(Mandatory = $true, HelpMessage = 'Site code for site server')]
        [String]$siteCode,

        [Parameter(Mandatory = $true, HelpMessage = 'Path to search for empty folders in')]
        [String]$baseFolder,

        [Parameter(Mandatory = $true, HelpMessage = 'Object Type')]
        [ValidateSet('SMS_Package', 'SMS_Advertisement', 'SMS_Query', 'SMS_Report', 'SMS_MeteredProductRule', 'SMS_ConfigurationItem', 'SMS_OperatingSystemInstallPackage', 'SMS_StateMigration', 'SMS_ImagePackage', 'SMS_BootImagePackage', 'SMS_TaskSequencePackage', 'SMS_DeviceSettingPackage', 'SMS_DriverPackage', 'SMS_Driver', 'SMS_SoftwareUpdate', 'SMS_ConfigurationBaselineInfo', 'SMS_Collection_Device', 'SMS_Collection_User', 'SMS_ApplicationLatest', 'SMS_ConfigurationItemLatest')]
        [String]$ObjectType,

        [Parameter(Mandatory = $false, HelpMessage = 'Switch to indicate whether or not to delete empty folders')]
        [Switch]$removeEmptyFolders,

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
        #Assign a value to logEntries
        if ($PSBoundParameters['logEntries']) { $logEntries = $true }
        else { $logEntries = $false }

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Remove-EmptyFoldersUnderProd';
            logEntries    = $logEntries;
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        #Build nameSpace variable
        $nameSpace = "Root/SMS/Site_$siteCode"

        #Create a hashtable with your output info
        $returnHashTable = @{ }

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "cimSession.Computerame = $($cimSession.ComputerName)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "siteCode = $siteCode" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "baseFolder = $baseFolder" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "objectType = $objectType"
        New-CMNLogEntry -entry "removeEmptyFolders = $($removeEmptyFolders.IsPresent)" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry
        #Get ContainerNodeID of baseFolder
        $baseContainerNodeID = Get-CimInstance -CimSession $cimSession -Namespace $nameSpace -Query "SELECT * FROM SMS_ObjectContainerNode WHERE Name = '$baseFolder' and ObjectTypeName = '$objectType'"
        if ($baseContainerNodeID) {
            New-CMNLogEntry -entry "BaseFolderID is $($baseContainerNodeID.ContainerNodeID)" -type 1 @NewLogEntry
        }
        else{
            New-CMNLogEntry -entry "$baseFolder does not appear to exist" -type 3 @NewLogEntry
            Return 65001
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Remove-EmptyFoldersUnderProd