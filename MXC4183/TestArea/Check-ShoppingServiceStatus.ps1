# This script will check if the Shopping service is running. If it is, it will then check the shopping.receiver.log file for last write time, if it's older than 7 minutes, email me to check. 
# Log example: New-CmnLogEntry -entry "Machine $computerName needs a restart." -type 2 -component 'Installer' -logFile $logFile -logEntries -MaxLogSize 10485760

Function New-CmnLogEntry {
    [CmdletBinding(ConfirmImpact = 'Low')]
    Param
    (
        [Parameter(Mandatory = $true, HelpMessage = 'This is the text that is the log entry.')]
        [String]$entry,

        [Parameter(Mandatory = $true, HelpMessage = 'Defines the type of message, 1 = Informational (default), 2 = Warning, and 3 = Error.')]
        [ValidateSet(1, 2, 3)]
        [INT32]$type,

        [Parameter(Mandatory = $true, HelpMessage = 'Specifies the Component information. This could be the name of the function or thread, or whatever you like, to further help identify what is being logged.')]
        [String]$component,

        [Parameter(Mandatory = $false, HelpMessage = 'File for writing logs to (default is c:\temp\eror.log).')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false, HelpMessage = 'Set to $true to write to the log file. Otherwise, it will just be write-verbose (default is $false).')]
        [Boolean]$logEntries = $false,

        [Parameter(Mandatory = $false, HelpMessage = 'Max size for the log (default is 5MB).')]
        [Int]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false, HelpMessage = 'Specifies the number of history log files to keep (default is 5).')]
        [Int]$maxLogHistory = 5
    )

    # Get Timezone info
    $now = Get-Date
    $tzInfo = [System.TimeZoneInfo]::Local
    
    # Get Timezone Offset
    $tzOffset = $tzInfo.BaseUTcOffset.Negate().TotalMinutes
    
    # If it's daylight savings time, we need to adjust
    if ($tzInfo.IsDaylightSavingTime($now)) {
        $tzAdjust = ((($tzInfo.GetAdjustmentRules()).DaylightDelta).TotalMinutes)[0]
        $tzOffset -= $tzAdjust
    }

    # Now, to figure out the format. if the timezone adjustment is posative, we need to represent it as +###
    if ($tzOffset -ge 0) {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$($tzOffset)"
    }
    # Otherwise, we need to represent it as -###
    else {
        $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")$tzOffset"
    }

    # Create entry line, properly formatted
    $cmEntry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $entry, (Get-Date -Format "MM-dd-yyyy"), $tzOffset, $pid, $type, $component

    if ($PSBoundParameters['logEntries']) {
        # Now, see if we need to roll the log
        if (Test-Path $logFile) {
            # File exists, now to check the size
            if ((Get-Item -Path $logFile).Length -gt $MaxLogSize) {
                # Rename file
                $backupLog = ($logFile -replace '\.log$', '') + "-$(Get-Date -Format "yyyymmdd-HHmmss").log"
                Rename-Item -Path $logFile -NewName $backupLog -Force
                # Get filter information
                # First, we do a regex search, and just get the text before the .log and after the \
                $logFile -match '(\w*).log' | Out-Null
                # Now, we add a trailing * for the filter
                $logFileName = "$($Matches[1])*"
                # Get the path for the log so we know where to search
                $logPath = Split-Path -Path $logFile
                # And we remove any extra rollover logs.
                Get-ChildItem -Path $logPath -filter $logFileName | Where-Object { $_.Name -notin (Get-ChildItem -Path $logPath -Filter $logFileName | Sort-Object -Property LastWriteTime -Descending | Select-Object -First $maxLogHistory).name } | Remove-Item
            }
        }
        # Finally, we write the entry
        $cmEntry | Out-File $logFile -Append -Encoding ascii
    }
    # Also, we write verbose, just incase that's turned on.
    Write-Verbose $entry
} # End New-CmnLogEntry


$PSEmailServer = "pobox.humana.com"

# Check if the service is running.
New-CmnLogEntry -entry "Checking if the Shopping Receiver service is running..." -type 1 -component 'Service'
$ShoppingService = Get-Service -ComputerName LOUAPPWPS1658 -Name shopping.receiver.v5.5.100

If($ShoppingService.Status -ne 'Running'){
    New-CmnLogEntry -entry "Shopping Receiver service NOT running! Emailing Mike." -type 3 -component 'Service'
    #Email me that it's not running.
    Send-MailMessage -to 'mcook9@Humana.com' -from 'configmgrsupport@humana.com' -Subject "Shopping Receiver service status: $($ShoppingService.Status)"
    #Start the service
    New-CmnLogEntry -entry "Attempting to start receiver service..." -type 1 -component 'Service'
    Start-Service -ComputerName LOUAPPWPS1658 -Name shopping.receiver.v5.5.100
    Start-Sleep -seconds 60
    $ShoppingService.Refresh()
        If($ShoppingService.Status -eq 'Running'){
            New-CmnLogEntry -entry "Shopping Receiver successfully started" -type 1 -component 'Service'
            Send-MailMessage -to 'mcook9@Humana.com' -from 'configmgrsupport@humana.com' -Subject "Shopping Receiver service status: $($ShoppingService.Status)"
        }else{
            New-CmnLogEntry -entry "Shopping Receiver still not started. Emailing team for further investigation." -type 1 -component 'Service'
            Send-MailMessage -to 'configmgrsupport@humana.com' -from 'mcook9@Humana.com' -Subject "Restart attempt didn't go so well. Go take a look at the Shopping Receiver on the site server."
        } 
}

<# Now we've checked the service, let's make sure the log is rolling.
$LastWriteTime = (Get-Item -Path "\\louappwps1658\c$\ProgramData\1E\Shopping.Receiver\v5.5.100\Shopping.Receiver.log" | Get-Content -Tail 1).Substring(11,5)
$CurrentTime = (Get-date).ToShortTimeString()

$file = "\\louappwps1658\c$\ProgramData\1E\Shopping.Receiver\v5.5.100\Shopping.Receiver.log"
Get-ChildItem $file -force | Select-Object LastWriteTime

(Get-date -UFormat "%Y-%m-%d %R")

(Get-Item -Path "\\louappwps1658\c$\ProgramData\1E\Shopping.Receiver\v5.5.100\Shopping.Receiver.log").LastWriteTime
#>




