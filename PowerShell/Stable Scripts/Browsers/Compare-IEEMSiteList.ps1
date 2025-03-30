Function New-LogEntry
{
	[CmdletBinding(ConfirmImpact = 'Low')]
	
    # Writes to the log file
    Param
    (
        [Parameter(Mandatory = $true,
			Position = 0,
			HelpMessage = 'Entry for the log')]
        [String]$entry,

        [Parameter(Mandatory = $true,
			Position = 1,
			HelpMessage = 'Type of message, 1 = Informational, 2 = Warning, 3 = Error')]
	    [ValidateSet(1, 2, 3)]
        [INT32]$type,

        [Parameter(Mandatory = $true,
			Position = 2,
			HelpMessage = 'Component')]
        [String]$component,

		[Parameter(Mandatory = $true,
			Position = 4,
			HelpMessage = 'Log File')]
		[String]$logFile
    )
    Write-Verbose $entry
    if ($entry.Length -eq 0)
    {
        $entry = 'N/A'
    }
    $tzOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
    $tzOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$tzOffset)"
    $entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $entry, (Get-Date -Format "MM-dd-yyyy"), $tzOffset, $pid, $type, $component
    $entry | Out-File $logFile -Append -Encoding ascii
}

function Compare-EMSLXML {
    New-LogEntry "Gathering XML files to compare." -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
    $Files = Get-ChildItem \\louappwps1331.rsc.humad.com\iesitelist -Filter *.xml
    $Files | ForEach-Object {
        New-LogEntry "$($_ | select-object Name, LastWriteTime)" -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
        if ($_.LastWriteTime -ne (Get-Item "\\$($DestServers[0])\iesitelist\$($_.Name)").LastWriteTime) {
            New-LogEntry "Syncing $($_.Name) to $($DestServers[0])." -type 2 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
            Copy-Item -Path $_.FullName -Destination "\\$($DestServers[0])\iesitelist\" -Force -Verbose
        }
        if ($_.LastWriteTime -ne (Get-Item "\\$($DestServers[1])\iesitelist\$($_.Name)").LastWriteTime) {
            New-LogEntry "Syncing $($_.Name) to $($DestServers[1])." -type 2 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
            Copy-Item -Path $_.FullName -Destination "\\$($DestServers[1])\iesitelist\" -Force -Verbose
        }
    }
    New-LogEntry "Compare complete." -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
}

$DestServers = 'LOUAPPWPS1331.rsc.humad.com','LOUAPPWPS1632.rsc.humad.com'

$Date = Get-Date -UFormat %m%d%Y

$i = 0

do {
    New-LogEntry "==========[Starting EMSL XML Compare]==========" -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
    Compare-EMSLXML
    New-LogEntry "==========[Ending EMSL XML Compare]==========" -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
    Start-Sleep -Seconds 60
    $i++
} while ($i -lt 5)