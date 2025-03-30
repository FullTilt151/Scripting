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
		[String]$logFile='C:\Temp\Error.log'
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

function Compare-IEEM {
    $sl1 = Get-ChildItem \\louappwps1331\IESiteList -Filter ieem.xml
    $sl2 = Get-ChildItem \\louappwps1332\IESiteList -Filter ieem.xml

    New-LogEntry "Comparing $($sl1.Name)..." -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
    if ($sl2.LastWriteTime -ne $sl1.LastWriteTime) {
        New-LogEntry "Difference found, replacing..." -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
        Copy-Item $sl1.FullName -Destination $sl2.FullName -Force
    } else {
        New-LogEntry "No difference found!" -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
    }
}

function Compare-HGBIEEM {
    $sl1 = Get-ChildItem \\louappwps1331\IESiteList -Filter HGBieem.xml
    $sl2 = Get-ChildItem \\louappwps1332\IESiteList -Filter HGBieem.xml

    New-LogEntry "Comparing $($sl1.Name)..." -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
    if ($sl2.LastWriteTime -ne $sl1.LastWriteTime) {
        New-LogEntry "Difference found, replacing..." -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
        Copy-Item $sl1.FullName -Destination $sl2.FullName -Force
    } else {
        New-LogEntry "No difference found!" -type 1 -component IEEM -logFile D:\CompareIEEMSiteList\CompareIEEMSiteList_$Date.log
    }
}

$Date = Get-Date -UFormat %m%d%Y

$i = 0

do {
    Compare-IEEM
    Compare-HGBIEEM
    Start-Sleep -Seconds 60
    $i++
} while ($i -lt 5)