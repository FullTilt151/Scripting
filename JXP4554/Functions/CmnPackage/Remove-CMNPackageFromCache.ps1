Function Remove-CMNPackageFromCache {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER SCCMConnectionInfo
			This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
			Get-CMNSCCMConnectionInfo in a variable and passing that variable.

		.PARAMETER showProgress
			Show a progressbar displaying the current operation.

		.PARAMETER logFile
			File for writing logs to

		.PARAMETER logEntries
			Switch to say whether or not to create a log file

		.PARAMETER maxLogSize
			Max size for the log. Defaults to 5MB.

		.PARAMETER maxLogHistory
				Specifies the number of history log files to keep, default is 5

 		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			FileName:    Remove-CMNPackageFromCache.ps1
			Author:      James Parris
			Contact:     jim@ConfigMan-Notes.com
			Created:     2016-03-22
			Updated:     2016-03-22
			Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM
    (
        [Parameter(Mandatory = $true,
            HelpMessage = 'PackageID to remove')]
        [String]$packageID
    )

    begin {
    }

    process {
        #Connect to Resource Manager COM Object
        $resman = new-object -ComObject "UIResource.UIResourceMgr"
        $cacheInfo = $resman.GetCacheInfo()

        #Enum Cache elements, compare date, and delete older than 60 days
        $element = $cacheinfo.GetCacheElements()  | Where-Object {$_.ContentID -eq $packageID}
        if ($element) {$cacheInfo.DeleteCacheElement($element.CacheElementID)}
    }

    end {
    }
} #End Remove-CMNPackageFromCache
