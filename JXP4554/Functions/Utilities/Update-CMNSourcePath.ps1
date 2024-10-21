Function Update-CMNSourcePath
{
	<#
	.SYNOPSIS
 
	.DESCRIPTION
 
	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of 
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.
		
 	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE
     
	.LINK
		http://configman-notes.com

	.NOTES
		FileName:    Update-CMNSourcePath.ps1
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     2016-03-22
		Updated:     2016-03-22
		Version:     1.0.0

        0  Regular software distribution package.
        3  Driver package.
        4  Task sequence package.
        5  Software update package.
        6  Device setting package.
        7 Virtual application package.
        257  Image package.
        258  Boot image package.
        259 Operating system install package.
	#>

	[CmdletBinding(SupportsShouldProcess = $true, 
		ConfirmImpact = 'Low')]
	
	PARAM
	(
		[Parameter(Mandatory = $true,
			HelpMessage = 'SCCM Connection Info')]
		[PSObject]$SCCMConnectionInfo,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Source path to change')]
        [String]$sourcePath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Destination path to set')]
        [String]$destPath,

        [Parameter(Mandatory = $true,
            HelpMessage = 'Package Types to move')]
        [ValidateSet('Package','Driver package','Task sequence','Software update','Device setting','Virtual applicaiton package','Image package','Boot image package','Operating system install package')]
        [String[]]$pkgTypes,

 		[Parameter(Mandatory = $false,
			HelpMessage = 'LogFile Name')]
		[String]$logFile = 'C:\Temp\Error.log',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Log entries')]
		[Switch]$logEntries,

		[Parameter(Mandatory = $false,
			HelpMessage = 'Max Log size')]
		[Int32]$maxLogSize = 5242880,

		[Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs')]
        [Int32]$maxHistory = 5
	)

	Begin 
	{
        $pkgTypeHT = @{'Package' = 0;
            'Driver package' = 3;
            'Task sequence' = 4;
            'Software update' = 5;
            'Device setting' = 6;
            'Virtual applicaitonpackage' = 7;
            'Image package' = 257;
            'Boot image package' = 258;
            'Operating system install package' = 259;
        }
		# Disable Fast parameter usage check for Lazy properties
		$CMPSSuppressFastNotUsedCheck = $true
		#Build splat for log entries 
		$NewLogEntry = @{
			LogFile = $logFile;
			Component = 'Update-CMNSourcePath';
			maxLogSize = $maxLogSize;
			maxHistory = $maxHistory;
		}

		#Build splats for WMIQueries
        $WMIQueryParameters = @{
            ComputerName = $SCCMConnectionInfo.ComputerName;
            NameSpace = $SCCMConnectionInfo.NameSpace;
        }

		if($PSBoundParameters['logEntries'])
		{
			New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
			New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
			New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
		}
        
        $query = 'SELECT * FROM SMS_Package'# where PackageType in (0, 5)'
        $query = 'SELECT * FROM SMS_SoftwareUpdatesPackage'
        $packages = Get-CimInstance -Query $query @WMIQueryParameters
        $sourcePathWMI = [regex]::Replace($sourcePath,'(?<SingleQuote>\\)','\${SingleQuote}')
        $destPathWMI = [regex]::Replace($destPath,'(?<SingleQuote>\\)','\${SingleQuote}')
	}
	
	Process 
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
		# Main code part goes here
        
        foreach($package in $packages)
        {
            if($package.PkgSourceFlag -eq 2)
            {
                if($package.PkgSourcePath -match "$sourcePathWMI")
                {
                    Write-Output ($package.PkgSourcePath -replace "$sourcePathWMI","$destPath")
                }
            }
        }
	}

	End
	{
		if($PSBoundParameters['logEntries']){New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
	}
} #End Update-CMNSourcePath

$Con = Get-CMNSCCMConnectionInfo -siteServer LOUAPPWTS1140
Update-CMNSourcePath -SCCMConnectionInfo $Con -logEntries -sourcePath '\\lounaswps01\pdrive' -destPath '\\lounaswps09\pdrive' -pkgTypes 'Software update', 'Package'