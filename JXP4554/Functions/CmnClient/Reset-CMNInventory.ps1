Function Reset-CMNInventory {
    <#
    .SYNOPSIS

    .DESCRIPTION

    .PARAMETER action
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNaction in a variable and passing that variable.

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
        [Parameter(Mandatory = $false, HelpMessage = 'Computer(s) to perform the reset on')]
        [String[]]$computerNames = [Array]$env:COMPUTERNAME,

        [Parameter(Mandatory = $false, HelpMessage = 'Action to inventory, options are Hardware, Software, DDR, or File')]
        [ValidateSet('Hardware', 'Software', 'DDR', 'File')]
        [PSObject]$action = 'Hardware',

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
            Component     = 'Reset-CMNInventory';
            maxLogSize    = $maxLogSize;
            maxLogHistory = $maxLogHistory;
        }

        $inventoryGUID = @{
            'Hardware' = '{00000000-0000-0000-0000-000000000001}';
            'Software' = '{00000000-0000-0000-0000-000000000002}';
            'DDR'      = '{00000000-0000-0000-0000-000000000003}';
            'File'     = '{00000000-0000-0000-0000-000000000010}';
        }
        
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "action = $action" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogHistory = $maxLogHistory" -type 1 @NewLogEntry
        }
    }

    process {
        if ($logEntries) {New-CMNLogEntry -entry 'Beginning process loop' -type 1 @NewLogEntry}

        if ($PSCmdlet.ShouldProcess($action)) {
            foreach ($computerName in $computerNames) {
                try {
                    Get-CimInstance -ComputerName $computerName -Namespace root\CCM\InvAgt -ClassName InventoryActionStatus -Filter "InventoryActionID = '$($inventoryGUID[$action])'" -ErrorAction SilentlyContinue | Remove-CimInstance
                    Invoke-CimMethod -ComputerName $computerName -Namespace root\ccm -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = $inventoryGUID[$action]} -ErrorAction SilentlyContinue | Out-Null
                }
                catch {
                    if ($logEntries) {
                        New-CMNLogEntry -entry "Unable to reset inventory on $computerName" -type 3 @NewLogEntry
                        New-CMNLogEntry -entry $Error.ErrorDetails -type 3 @NewLogEntry
                    }
                    Write-Output "Unable to reset inventory on $computerName"
                    Write-Output $Error.ErrorDetails
                }
            }
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Reset-CMNInventory

Reset-CMNInventory 