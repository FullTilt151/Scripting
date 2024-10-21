Function Remove-CMNCollection {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

    .PARAMETER logFile
        File for writing logs to, default is c:\temp\eror.log

    .PARAMETER logEntries
        Switch for logging entries, default is $false

    .PARAMETER maxLogSize
        Max size for the log. Defaults to 5MB.

    .PARAMETER maxLogHistory
            Specifies the number of history log files to keep, default is 5

    .EXAMPLE

    .LINK
        http://configman-notes.com

    .NOTES
        Author:	    Jim Parris
        Email:	    Jim@ConfigMan-Notes
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info')]
        [PSObject]$sccmConnectionInfo,

        [Parameter(Mandatory = $true, HelpMessage = 'CollectionID to remove')]
        [String]$collectionID,

        [Parameter(Mandatory = $false, HelpMessage = 'Do we delete if it is an inlcude or exclude collection?')]
        [Switch]$doForce,

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
            Component     = 'Remove-CMNCollection';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        # Create a hashtable with your output info
        $returnHashTable = @{}

        $cimSession = new-cimsession -ComputerName $sccmConnectionInfo.ComputerName
        $collection = Get-CimInstance -Query "Select * from SMS_Collection where CollectionID = '$collectionID'" -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession

        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "collectionID = $collectionID" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "doForce =$doForce" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry}

        if ($PSCmdlet.ShouldProcess($collectionID)) {
            #check for dependencies
            $isLimitingCollection = $false
            $isIncludeCollection = $false
            $isExcludeCollection = $false
            $dependencies = Get-CimInstance -query "Select * from SMS_CollectionDependencies where SourceCollectionID = '$collectionID'" -CimSession $cimSession -Namespace $sccmConnectionInfo.NameSpace
            foreach ($dependency in $dependencies) {
                switch ($dependency.RelationShipType) {
                    1 {
                        #Limiting collection
                        if ($logEntries) {New-CMNLogEntry -entry "Collection $depCollectionID is the limiting collection for collection $($dependency.DependentCollectionID)" -type 3 @NewLogEntry}
                        $returnHashTable['LimitingCollectionFor'] += [Array]$dependency.DependentCollectionID
                        $isLimitingCollection = $true
                    }

                    2 {
                        #Include collection
                        if ($logEntries) {New-CMNLogEntry -entry "Collection $depCollectionID is included in collection $($dependency.DependentCollectionID)" -type 1 @NewLogEntry}
                        $returnHashTable['IncludeCollectionFor'] += [Array]$dependency.DependentCollectionID
                        $isIncludeCollection = $true
                        if ($doForce) {
                            $depCollection = Get-CimInstance -Query "Select * from SMS_Collection where CollectionID = '$($dependency.DependentCollectionID)'" -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
                            $depCollection = $depCollection | Get-CimInstance
                            foreach ($depCollectionRule in $depCollection.CollectionRules) {
                                if($depCollectionRule.IncludeCollectionID -eq $collectionID){
                                    try {
                                        if ($logEntries) {New-CMNLogEntry -entry "Removing rule from $($depCollection.Name) ($($depCollection.CollectionID))" -type 1 @NewLogEntry}
                                        Invoke-CimMethod -InputObject $depCollection -CimSession $cimSession -MethodName DeleteMembershipRule -Arguments @{collectionRule = $depCollectionRule} | Out-Null
                                    }
                                    catch {
                                        $message = "Failed to remove rule from collection $($depCollection.Name) ($($dependency.DependentCollectionID))"
                                        if($logEntries){New-CMNLogEntry -entry $message -type 3 @NewLogEntry}
                                        throw $message
                                    }
                                }
                            }
                        }
                    }

                    3 {
                        #Exclude collection
                        if ($logEntries) {New-CMNLogEntry -entry "Collection $collectionID is excluded in collection $($dependency.DependentCollectionID)" -type 1 @NewLogEntry}
                        $returnHashTable['ExludeCollectionFor'] += [Array]$dependency.DependentCollectionID
                        $isExcludeCollection = $true
                        if ($doForce) {
                            $depCollection = Get-CimInstance -Query "Select * from SMS_Collection where CollectionID = '$($dependency.DependentCollectionID)'" -Namespace $sccmConnectionInfo.NameSpace -CimSession $cimSession
                            $depCollection = $depCollection | Get-CimInstance
                            
                            foreach ($depCollectionRule in $depCollection.CollectionRules) {
                                if($depCollectionRule.ExcludeCollectionID -eq $collectionID){
                                    try {
                                        if ($logEntries) {New-CMNLogEntry -entry "Removing rule from $($depCollection.Name) ($($depCollection.CollectionID))" -type 1 @NewLogEntry}
                                        Invoke-CimMethod -InputObject $depCollection -CimSession $cimSession -MethodName DeleteMembershipRule -Arguments @{collectionRule = $depCollectionRule} | Out-Null
                                    }
                                    catch {
                                        $message = "Failed to remove rule from collection $($depCollection.Name) ($($dependency.DependentCollectionID))"
                                        if($logEntries){New-CMNLogEntry -entry $message -type 3 @NewLogEntry}
                                        throw $message
                                    }
                                }
                            }
                        }
                    }
                }
            }
            #delete collection
            try{
                if($logEntries){New-CMNLogEntry -entry "Removing collection $collectionID" -type 1 @NewLogEntry}
                Remove-CimInstance -inputObject $collection -ErrorAction SilentlyContinue | out-null
            }

            catch{
                $message = "Failed to remove collection $($collection.Name) ($collectionID)"
                if($logEntries){New-CMNLogEntry -entry $message -type 3 @NewLogEntry}
                throw $message
            }
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.DeleteCollectionResults')
        Return $obj	
    }
} #End Remove-CMNCollection
