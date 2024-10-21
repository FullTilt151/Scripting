Function Show-CMNPackageProgress {
    <#
		.SYNOPSIS

		.DESCRIPTION

		.PARAMETER ObjectID

		.EXAMPLE

		.LINK
			http://configman-notes.com

		.NOTES
			Author:	Jim Parris
			Email:	Jim@ConfigMan-Notes
			Date:   4/10/2018
			PSVer:	2.0/3.0
			Updated:
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    PARAM(
        [Parameter(Mandatory = $true,
            HelpMessage = 'Computer to check')]
        [String]$computerName,
		
        [Parameter(Mandatory = $false,
            HelpMessage = 'PackageID to search for')]
        [String]$packageID
    )
    begin {
        #build splats
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Show-CMNPackageProgress';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }

        #hashtable to return results
        $returnHashTable = @{}
		
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "computerName = $computerName" @NewLogEntry
            New-CMNLogEntry -entry "packageID = $packageID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "NewLogEntry = $NewLogEntry" -type 1 @NewLogEntry
        }

    }

    Process {
        if ($PSCmdlet.ShouldProcess($computerName)) {
            New-CMNLogEntry -entry "Testing connection to $computerName" -type 1 @NewLogEntry
            if (Test-Connection -ComputerName $computerName -Count 1) {
                New-CMNLogEntry -entry "Succesfull test to $computerName" -type 1 @NewLogEntry
            }
            else {
                New-CMNLogEntry -entry "Failed to connect to $computerName" -type 3 @NewLogEntry
                throw "Faield to connect to $computerName"
            }

            #Get cache dir
            New-CMNLogEntry -entry 'Getting Cache Info' -type 1 @NewLogEntry
            $cacheInfo = Get-CimInstance -Query "SELECT * FROM CacheConfig WHERE ConfigKey='Cache'" -ComputerName $computerName -Namespace 'ROOT\ccm\SoftMgmtAgent'

            #Get free space on cache drive
            New-CMNLogEntry -entry 'Getting Cache Drive' -type 1 @NewLogEntry
            $cacheDrive = $cacheInfo.Location.Substring(1, 2)
            New-CMNLogEntry -entry "Getting free space on $cacheDrive on $computerName" -type 1 @NewLogEntry
            $freeSpace = (Get-CimInstance -Query "SELECT * FROM Win32_LogicalDisk WHERE DeviceID='$cacheDrive'" -ComputerName $computerName -Namespace 'ROOT\cimv2').FreeSpace
            New-CMNLogEntry -entry "$computerName has $freeSpace on $cacheDrive" -type 1 @NewLogEntry
			#get execmgr log
			New-CMNLogEntry -entry "Getting execmgr.log" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "Get log base directory from registry" -type 1 @NewLogEntry
            $key = 'SOFTWARE\\Microsoft\\CCM\\Logging\\@Global'
            $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computerName)
            $RegKey = $Reg.OpenSubKey($key)
            $ccmLogDir = $RegKey.GetValue("LogDirectory")
            $ccmLogDir -match '(.):\\(.*)' | Out-Null
			$ccmLogDir = "\\$computerName\$($Matches[1])$\$($Matches[2])"
			New-CMNLogEntry -entry "Getting execmgr.log from $ccmLogDir" -type 1 @NewLogEntry
            $execMgrLog = Get-Content -Path "$ccmLogDir\execmgr.log"
			#scan for packageID
			New-CMNLogEntry -entry "Got execmgr.log, now scanning for $packageID" -type 1 @NewLogEntry
			$execmgr = New-Object System.Array
			foreach($execmgrrow in $execMgrLog){
				if($execmgrrow.contains($packageID)){$execmgr.Add($execmgrrow)}
			}
            ## root\ccm\ContentTransferManager CCM_CTM_DownloadHistory.ContentID = PackageID for transfer jobs
}
    }

    end {
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.PackageProgress')
        Return $obj	
    }
}