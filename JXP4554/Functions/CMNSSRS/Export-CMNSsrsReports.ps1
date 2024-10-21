Function Export-CMNSsrsReports {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CMNSCCMConnectoinInfo and New-CMNLogEntry functions for these scripts, 
        please make sure you account for that.

    .PARAMETER reportServer
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNreportServer in a variable and passing that variable.

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
        http://msdn.microsoft.com/en-us/library/aa225878(v=SQL.80).aspx
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'Reportserver')]
        [PSObject]$reportServer,

        [Parameter(Mandatory = $false, HelpMessage = 'Port for report server, default 8081')]
        [int]$port,

        [Parameter(Mandatory = $true, HelpMessage = 'Directory to copy the report files to')]
        [String]$baseDir,

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
            Component     = 'Export-CMNSsrsReports';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Create a hashtable with your output info
        $returnHashTable = @{}

        #Ensure there is a trailing \ on the path

        New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
        New-CMNLogEntry -entry "reportServer = $reportServer" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "port = $port" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
        New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        if ($PSCmdlet.ShouldProcess($reportServer)) {
            [void][System.Reflection.Assembly]::LoadWithPartialName("System.Xml.XmlDocument");
            [void][System.Reflection.Assembly]::LoadWithPartialName("System.IO");
 
            $ReportServerUri = "http://${reportServer}:$port/ReportServer/ReportService2005.asmx";
            $Proxy = New-WebServiceProxy -Uri $ReportServerUri -Namespace SSRS.ReportingService2005 -UseDefaultCredential ;
 
            $items = $Proxy.ListChildren("/", $true) | Select-Object Type, Path, ID, Name | Where-Object {$_.type -eq "Report"};
 
            $folderName = Get-Date -format "yyyy-MMM-dd-hhmmtt";
            $fullFolderName = $baseDir + $folderName;
            [System.IO.Directory]::CreateDirectory($fullFolderName) | out-null
 
            foreach ($item in $items) {
                #need to figure out if it has a folder name
                $subfolderName = split-path $item.Path;
                $reportName = split-path $item.Path -Leaf;
                $fullSubfolderName = $fullFolderName + $subfolderName;
                if (-not(Test-Path $fullSubfolderName)) {
                    #note this will create the full folder hierarchy
                    [System.IO.Directory]::CreateDirectory($fullSubfolderName) | out-null
                }
 
                $rdlFile = New-Object System.Xml.XmlDocument;
                [byte[]] $reportDefinition = $null;
                $reportDefinition = $Proxy.GetReportDefinition($item.Path);
 
                #note here we're forcing the actual definition to be stored as a byte array if you take out the @() from the MemoryStream constructor, you'll get an error
                [System.IO.MemoryStream] $memStream = New-Object System.IO.MemoryStream(@(, $reportDefinition));
                $rdlFile.Load($memStream);
 
                $fullReportFileName = $fullSubfolderName + "\" + $item.Name + ".rdl";
                #Write-Host $fullReportFileName;
                $rdlFile.Save( $fullReportFileName);
            }
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Export-CMNSsrsReports

Export-CMNSsrsReports -reportServer lousrswps18.rsc.humad.com -port 8081 -baseDir 'c:\temp\WP1\' -logFile 'c:\temp\Export-CMNSsrsReports.log' -logEntries
Export-CMNSsrsReports -reportServer lousrswps20.rsc.humad.com -port 8081 -baseDir 'c:\temp\SP1\' -logFile 'c:\temp\Export-CMNSsrsReports.log' -logEntries