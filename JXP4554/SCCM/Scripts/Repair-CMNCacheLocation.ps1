Function Repair-CMNCacheLocation {
    <#
    .SYNOPSIS

    .DESCRIPTION
        All my functions assume you are using the Get-CMNSCCMConnectoinInfo and New-CMNLogEntry functions for these scripts, 
        please make sure you account for that.

    .PARAMETER sccmConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNsccmConnectionInfo in a variable and passing that variable.

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
        Email:	    Jim@ConfigMan-Notes.com
        Date:	    yyyy-mm-dd
        Updated:    
        PSVer:	    3.0
        Version:    1.0.0		
	#>

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $true, HelpMessage = 'SCCM Connection Info - Result of Get-CMNSCCMConnectionInfo')]
        [String]$computerName,

        [Parameter(Mandatory = $false, HelpMessage = 'Force move, even if on good drive')]
        [Switch]$force,

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

        #Assign a value to Force
        if ($PSBoundParameters['force']) {$force = $true}
        else {$force = $false}

        #Build splat for log entries
        $NewLogEntry = @{
            LogFile       = $logFile;
            Component     = 'Repair-CMNCacheLocation';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "computerName = $computerName" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
    }

    process {
        New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry

        if ($PSCmdlet.ShouldProcess($sccmConnectionInfo)) {
            try {
                New-CMNLogEntry -entry "Fixing $computerName" -type 1 @NewLogEntry
                $results = New-Object psobject
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'ComputerName' -Value $computerName
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'CurrentCacheLocation' -Value 'UnKnown'
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'CurrentCacheSize' -Value 'UnKnown'
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'UpdatedCacheLocation' -Value 'None'
                Add-Member -InputObject $results -MemberType NoteProperty -name 'UpdatedCacheSize' -Value 'None'
                Add-Member -InputObject $results -MemberType NoteProperty -Name 'Results' -Value 'Error'
            
                #Gather current Cache Location and size
                $cache = Get-WmiObject -Namespace root\ccm\softmgmtagent -Class cacheconfig -ComputerName $computerName
                if ($cache.Location -eq $null) {$cache.Location = 'Z:\Error'}
                $results.CurrentCacheLocation = $cache.Location
                $results.CurrentCacheSize = $cache.Size
                New-CMNLogEntry -entry "`tCurrent cache location - $($Cache.Location)" -type 1 @NewLogEntry
                if ($PSBoundParameters['force']) {
                    $cache.Location = 'C:\Temp\'
                    $cache.put() | Out-Null
                    $cache.get()
                    Get-Service -ComputerName $computerName -Name CcmExec | Restart-Service
                }
                $drives = [Array](Get-WmiObject -ComputerName $computerName -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Sort-Object -Property FreeSpace -Descending).DeviceID
                New-CMNLogEntry -entry "`tDrives = $drives" -type 1 @NewLogEntry
            
                # Time to figure out what we've got
                New-CMNLogEntry -entry "`tDetermining if virtual" -type 1 @NewLogEntry
                $computerSystem = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $computerName
                if ($computerSystem.Model -match 'Virtual') {
                    New-CMNLogEntry -entry "`tThis is a virtual machine" -type 1 @NewLogEntry
                    $isVirtual = $true
                }
                else {
                    New-CMNLogEntry -entry "`tThis is a physical machine" -type 1 @NewLogEntry
                    $isVirtual = $false
                }
            
                #What OS are we working with?
                #ProductType 1=Workstation, 2 = DC, 3=Server Ref - https://docs.microsoft.com/en-us/windows/desktop/CIMWin32Prov/win32-operatingsystem
                New-CMNLogEntry -entry "`tChecking OS" -type 1 @NewLogEntry
                $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computerName
                if ($os.ProductType -eq 1) {
                    New-CMNLogEntry -entry "`tThis is a workstation" -type 1 @NewLogEntry
                    $isWorkstation = $true
                }
                else {
                    New-CMNLogEntry -entry "`tThis is a server" -type 1 @NewLogEntry
                    $isWorkstation = $false
                }
                   
                #Let's work with workstations first...
                if ($isWorkstation) {
                    if ($drives.Contains('B:') -and $isVirtual) {$CCMCacheDir = 'B:\CCMCache'}
                    else {$CCMCacheDir = 'C:\Windows\CCMCache'}
                }
                elseif ($computerSystem.Domain -eq 'ts.humad.com' -or $computerSystem.Domain -eq 'tmt.loutms.tree') {
                    ## It's a server, is it Citrix?
                    if ((($computerSystem.Name -notmatch '...[CX][MA][FH].*' -or $computerSystem.Name -match '...[CX][MA][ABCDFLNSPX].....S.*')) -and $computerSystem.Name -notmatch '......WP[VU].*') {
                        ## Persistent machines with cache on D:\Program Files\CCMCache
                        New-CMNLogEntry -entry "`tPersistent Citrix Server, setting cache to D:\Program Files\CCMCache" -type 1 @NewLogEntry
                        $CCMCacheDir = 'D:\Program Files\CCMCache'
                    }
                    else {
                        ## Non-persistent machines
                        New-CMNLogEntry -entry "`tNon-persistent Citrix Server, setting cache to E:\Persistent\CCMCache" -type 1 @NewLogEntry
                        $CCMCacheDir = 'E:\Persistent\CCMCache'
                    }
                }
                elseif ($computerSystem.Name -match '............c.*') {
                    #ClusterNode - Cache must be on C: or D:
                    foreach ($drive in $drives) {
                        if ($drive -match '[CD]:') {
                            $CCMCacheDir = "$drive\CCMCache"
                            if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                        }
                    }
                    #Make sure it's on C or D
                    if ($CCMCacheDir -notmatch '[CD]:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                    if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                }
                else {
                    #Standard server, put cache on drive with most free space
                    $CCMCacheDir = "$($drives[0])\CCMCache"
                    if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                }
            
                if ($isWorkstation -and !$isVirtual) {$ccmCacheSize = 51200}
                else {$ccmCacheSize = 5120}
            
                #We should have a cache directory, now to verify and set (need to add checks for cahce size as well)
                if ($CCMCacheDir -ne $results.CurrentCacheLocation -or $PSBoundParameters['force']) {
                    $CacheDriveExists = $false
                    $CacheDrive = $CCMCacheDir.Substring(0, 2)
                    foreach ($drive in $drives) {if ($CacheDrive -eq $drive) {$CacheDriveExists = $true}}
                    if (-not($CacheDriveExists)) {
                        New-CMNLogEntry -entry "`tCache drive doesn''t exist, looking for a new one." -type 1 @NewLogEntry
                        $CCMCacheDir = "$($drives[0])\CCMCache"
                        if ($CCMCacheDir -eq 'C:\CCMCache') {$CCMCacheDir = 'C:\Windows\CCMCache'}
                        New-CMNLogEntry -entry "`tNew cache location is $CCMCacheDir" -type 1 @NewLogEntry
                    } # End if(-not($CacheDriveExists))
                    $results.UpdatedCacheLocation = $CCMCacheDir
                    $cache.Location = $CCMCacheDir
                    if ($cache.Size -ne $ccmCacheSize) {
                        $results.UpdatedCacheSize = $ccmCacheSize
                        $cache.Size = $ccmCacheSize
                    }
                    $cache.put() | Out-Null
                    $cache.Get()
                    New-CMNLogEntry -entry "`tCache location is now $($Cache.Location)" -type 1 @NewLogEntry
                    $results.Results = 'Updated'
                    Get-Service -ComputerName $computerName -Name CcmExec | Restart-Service
                }
                else {
                    New-CMNLogEntry -entry "`tCache location is good" -type 1 @NewLogEntry
                    $results.Results = 'Good'
                } # End of else
            } # End of try
            Catch [System.Exception] {
                New-CMNLogEntry -entry "`t!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`tUnable to fix $computerName" -type 1 @NewLogEntry
                New-CMNLogEntry -entry "`t$($Error[0])" -type 1 @NewLogEntry
                $results.Results = 'Error'
                $results | Export-Csv -Path $logFile -Append -NoTypeInformation
            } # end of catch
        }
    }

    End {
        New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry
        $obj = New-Object -TypeName PSObject -Property $returnHashTable
        $obj.PSObject.TypeNames.Insert(0, 'CMN.ObjectType')
        Return $obj	
    }
} #End Repair-CMNCacheLocation

foreach ($computerName in $computerNames) {
    if (Test-Connection -ComputerName $computerName -Count 1 -ErrorAction SilentlyContinue) {
    } # End if (Test-Connection -ComputerName $computerName -Count 1 -ErrorAction SilentlyContinue)
    New-CMNLogEntry -entry "------------------" -type 1 @NewLogEntry
    $results | Export-Csv -Path $logFile -Append -NoTypeInformation
} # End foreach($computerName in $computerNames)


