<#
.Synopsis
    This script will create the operating system limiting collections.
.DESCRIPTION
   This script will create the operating system limiting collections. The variable $OperatingSystems contains the operating systems.
   The variable $OPeratingSystemQueries contains the value we are looking for in V_R_System.OperatingSystemNameandVersion.

.EXAMPLE
   Another example of how to use this cmdlet

.PARAMETER Server
    This is the SMS Provider server we are going to work with.

.PARAMETER LogLevel
    Sets the minimum logging level, default is 1.
    1 - Informational
    2 - Warning
    3 - Error

.PARAMETER LogFileDir
    Directory where you want the log file. Defaults to C:\Temp\

.LINK
    Blog
    http://parrisfamily.com

.NOTES
 #>

$Server = 'LOUAPPWPS875'
$Site = $(Get-WmiObject -ComputerName $Server -Namespace root\SMS -Class SMS_ProviderLocation).SiteCode
$ScriptName = $MyInvocation.MyCommand.Name
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = 'C:\Temp\' + $LogFile + '.log'

Function New-LogEntry {
    # Writes to the log file
    Param(
        [Parameter(Position=0,Mandatory=$true)]
        [STRING] $Entry,

        [Parameter(Position=1,Mandatory=$true)]
        [INT32] $type,

        [Parameter(Position=2,Mandatory=$true)]
        [STRING] $component = 'Move-Content'
        )

        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        Write-Verbose $Entry
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
}

New-LogEntry "Starting script at $(Get-Date)" 1 "Move-Content"

do {
    function distro {
        # Find all content with State = 1, State = 2 or State = 3, see http://msdn.microsoft.com/en-us/library/cc143014.aspx
        $Script:distro = Get-WmiObject -Namespace root\sms\site_$($Site) -computername $Server -Query "SELECT * FROM SMS_PackageStatusDistPointsSummarizer WHERE State != 0" | Where-Object {$_.state -ne 0}
    }

    distro
    $count = $Script:distro.count

    if ($count -eq 0) {
        New-LogEntry "Complete! Sending email" 1 "Distro"
        Send-MailMessage -Body "All done!" -Subject "ConfigMgr Alert: Content distribution is complete!" -to jparris@humana.com -from no-reply@humana.com -smtpserver pobox.humana.com
    } else {
        write-warning $count
        New-LogEntry "$($count) packages are waiting, starting to redistribute" 1 "Distro"
        foreach($pkg in $Script:distro)
        {
            $Status = switch($pkg.State)
            {
                0 {"INSTALLED"}
                1 {"INSTALL_PENDING"}
                2 {"INSTALL_RETRYING"}
                3 {"INSTALL_FAILED"}
                4 {"REMOVAL_PENDING"}
                5 {"REMOVAL_RETRYING"}
                6 {"REMOVAL_FAILED"}
                default {"UnKnown - $($pkg.State)"}
            }
            New-LogEntry "Package $($pkg.PackageID) to $($pkg.ServerNALPath) = $Status" 1 "Distro"
            if (($pkg.State -eq 3) -or ($pkg.State -ge 7))
            {
                $pkg.SourceNALPath -match '(?i)(\\\\[^\\]*)' | Out-Null
                $ServerNALPath = $Matches[0]
                $query = "Select * from SMS_DistributionPoint where ServerNalPath like '%$($ServerNALPath)%' and PackageID = '$($pkg.PackageID)'"
                $DistPointPkg = Get-WmiObject -ComputerName $Server -Namespace "root\sms\site_$($Site)" -Query $query
                New-LogEntry "Redisrbuting $($pkg.PackageID)" 1 "Distro"
                $DistPointPkg.RefreshNow = $true
                [Void]$DistPointPkg.Put()
            }
        }
        write-warning $count
        New-LogEntry "Sleeping for 1 hour after redeploying $($count) packages" 1 "Distro"
        start-sleep -Seconds 3600
        distro
        $count = $Script:distro.count
    }
}
while ($count -ne 0)