param (
$FolderPath,
$OutputFile = "$($FolderPath)\results.csv"
)

#Not using this now as time zone and UTC can mess up results, but keep in mind for manual observation based on TS completion
#Task sequence completed 0x00000000	OSDSetupHook	6/22/2016 4:55:55 PM	1288 (0x0508)
$DefaultFinalTSTime = [datetime]::ParseExact('6/22/2016 9:55:55 PM','M/d/yyyy h:mm:ss tt', [System.Globalization.CultureInfo]::InvariantCulture)

$PkgKeys = New-Object System.Collections.ArrayList
$PkgSource = @{}
$PkgProtocol = @{}
$PkgMaster = @{}
$PkgBytes = @{}
$PkgBlkrate = @{}
$PkgWorkrate = @{}
$PkgDisconnected = @{}
$PkgBackoff = @{}
$PkgNomadJobSeconds = @{}
$PkgStartedCopyTime = @{}
$PkgLogFile = @{}
$PkgNomadJobCompleted = @{}
$PkgLargeFile = @{}


$PkgObj = @()

$MonthAbbrToNum = @{"Jan"=1;"Feb"=2;"Mar"=3;"Apr"=4;"May"=5;"Jun"=6;"Jul"=7;"Aug"=8;"Sep"=9;"Oct"=10;"Nov"=11;"Dec"=12}

$patternCopyLoopStarted = 'CopyLoop started\. PackageID\: (?<pkgid>([^\(]+))\((?<pkgver>([\d]+))\)'
$patternStartedCopy = 'Evt_StartedCopy \:\s+(?<protocol>[^\s]+)(?: (Site|from)){0,1}( Master\=(?<master>[^\s]+)){0,1} (?<location>([^\s]+)) for (?<pkgid>([^\(]+))\((?<pkgver>([\d]+))\)'
$patternFinalizeCache = 'Finalise Cache (?<pkgid>([^\(]+))\((?<pkgver>([\d]+))\)([\s]+)(?<bytes>([\d]+))' 
$patternJobCompleted = 'Job Completed in (?<time>([^W]+)) WR\=(?<workrate>([\d\.]*)) \((?<disconnected>([^,]*)), (?<backoff>([^\)]*))\) blk/s\=(?<blkrate>([\d]+))'
$patternDate = '(?<month>((\d){1,2}))\/(?<day>\d{2})\/(?<year>((\d){4})) (?<hour>((\d){1,2})):(?<minute>((\d){2})):(?<second>((\d){2})) (?<ampm>(AM|PM))+'

$patternDate1 = '(?<month>\w{3}) (?<day>\d{1,2}) (?<hour>\d{2}):(?<minute>\d{2}):(?<second>\d{2})\.(?<milli>\d{3}) (?<year>\d{4})'
$patternDate2 = '\d{1,2}\/\d{1,2}\/\d{4} (\d){1,2}\:(\d){2}\:(\d){2} (AM|PM){0,1}'

Function WriteLog
{
	Param ([string]$string)
	Add-content $Logfile -value $string

}

#Get the files in the $FolderPath
Get-ChildItem $FolderPath -Filter *Nomad*.lo* -Recurse -Exclude *hist*,*Locator* | 
Foreach-Object {

    #Get the content for current file
    $content = Get-Content $_.FullName
    "...processing file $($_.FullName)"


    #Get an array of line numbers for Evt_StartedCopy
    #Note: Select-String's MatchInfo objects have a 1-based LineNumber property which you can use.
    #Get-Content returns a 0-based Object[].

    $indx = [int[]](Select-String "((CopyLoop Started\.)|(Evt_StartedCopy \:)|(Finalise Cache ))" $_.FullName | % {$_.LineNumber})

    if($indx.Count -gt 0){
        $iCounter = 0
        foreach($idx in $indx){
            $currentLine = (Get-Content $_.FullName)[($idx-1)]
            $nextLine = (Get-Content $_.FullName)[$idx]

            $mStats = [regex]::Matches($currentLine, $patternCopyLoopStarted)
            foreach($mStat in $mStats){
                $keyName = "$($mStat.Groups["pkgid"]).$($mStat.Groups["pkgver"])"
                $mDates = [regex]::Matches($currentLine, $patternDate1)
                if($mDates.Count -gt 0){
                    foreach($mdate in $mDates){
                        $theDate = Get-Date -Month ($MonthAbbrToNum[($mdate.Groups["month"].value)]) -Day ($mdate.Groups["day"].value) -Year ($mdate.Groups["year"].value) -Hour ($mdate.Groups["hour"].value) -Minute ($mdate.Groups["minute"].value) -Second ($mdate.Groups["second"].value) -Millisecond ($mdate.Groups["milli"].value)
                        if(-not $PkgStartedCopyTime.ContainsKey($keyName)){$PkgStartedCopyTime.Add($keyName, $theDate)}
                    }
                }else {
                    $mDates = [regex]::Matches($currentLine, $patternDate2)
                    if(-not $PkgStartedCopyTime.ContainsKey($keyName)){$PkgStartedCopyTime.Add($keyName, ($mDates.Value) )}
                }
            }

            $mStats = [regex]::Matches($currentLine, $patternStartedCopy)
            foreach($mStat in $mStats){
                $keyName = "$($mStat.Groups["pkgid"]).$($mStat.Groups["pkgver"])"
                if(-not $PkgKeys.Contains($keyName)){$PkgKeys.Add($keyName) | Out-Null}
                if(-not $PkgSource.Contains($keyname)){$PkgSource.Add($keyName, $mStat.Groups["location"])}
                if(-not $PkgProtocol.Contains($keyname)){$PkgProtocol.Add($keyName, $mStat.Groups["protocol"])}
                if(-not $PkgMaster.Contains($keyname)){$PkgMaster.Add($keyName, $mStat.Groups["master"])}
                if(-not $PkgLogFile.Contains($keyname)){$PkgLogFile.Add($keyName, ($_.FullName))}
                
                #Check if Large File
                $largeFileLine = (Get-Content $_.FullName)[$idx+1]
                if($largeFileLine -match "Large file"){$PkgLargeFile.Add($keyName,"TRUE")}

            }



            #Get the FinalizeCache params
            $mStats = [regex]::Matches($currentLine, $patternFinalizeCache)
            foreach($mStat in $mStats){
                $keyName = "$($mStat.Groups["pkgid"]).$($mStat.Groups["pkgver"])"
                if(-not $PkgKeys.Contains($keyname)){$PkgKeys.Add($keyname) | Out-Null}
                if(-not $PkgBytes.ContainsKey($keyName)){
                    $PkgBytes.Add($keyName, ($mStat.Groups["bytes"]))

                }

                #Get the JobCompleted params from the next line
                $mStats2 = [regex]::Matches($nextLine, $patternJobCompleted)
                foreach($mStat2 in $mStats2){
                    $timeStr = ([string]($mStat2.Groups["time"])).Trim()
                    $time = 0
                    if($timeStr -match "seconds") {
                        $time = [int](($timeStr -replace "seconds", $null).Trim())
                    } elseif($timeStr -match "minutes") {
                        $time = ([int](($timeStr -replace "minutes", $null).Trim())) * 60
                    } else {
                        $timeParts = $timeStr.Split(":")
                        foreach($part in $timeParts){
                            if($part -match "d") {$time += ( [int]($part -replace "d",$null) * 86400 ) }
                            if($part -match "h") {$time += ( [int]($part -replace "h",$null) * 3600 ) }
                            if($part -match "m") {$time += ( [int]($part -replace "m",$null) * 60 ) }
                            if($part -match "s") {$time += ( [int]($part -replace "s",$null) ) }
                        }
                    }

                    ## Removed because can be unreliable value for really short times, or really long times
                    ##$PkgNomadJobSeconds.Add($keyName, $time)
                    $PkgBlkrate.Add($keyName, ($mStat2.Groups["blkrate"]))
                    $PkgWorkrate.Add($keyName, ($mStat2.Groups["workrate"]))
                    $PkgDisconnected.Add($keyName, (($mStat2.Groups["disconnected"] -replace "disconnected ",$null) -replace " Seconds", $null ))
                    $PkgBackoff.Add($keyName, (($mStat2.Groups["backoff"] -replace "Backoff ",$null) -replace " Seconds", $null ))

                    #Get the JobCompleted date from that line
                    $mDates = [regex]::Matches($nextLine, $patternDate1)
                    if($mDates.Count -gt 0){
                        foreach($mdate in $mDates){
                            $theDate = Get-Date -Month ($MonthAbbrToNum[($mdate.Groups["month"].value)]) -Day ($mdate.Groups["day"].value) -Year ($mdate.Groups["year"].value) -Hour ($mdate.Groups["hour"].value) -Minute ($mdate.Groups["minute"].value) -Second ($mdate.Groups["second"].value) -Millisecond ($mdate.Groups["milli"].value)
                            if(-not $PkgNomadJobCompleted.ContainsKey($keyName)){$PkgNomadJobCompleted.Add($keyName, $theDate)}
                        } 
                    }else {
                        $mDates = [regex]::Matches($nextLine, $patternDate2)
                        if(-not $PkgNomadJobCompleted.ContainsKey($keyName)){$PkgNomadJobCompleted.Add($keyName, ([string]($mDates.Value)))}
                    }
                }

            }
        }
    }
}

#Enumerate start times, and see if a stop time was also found
$totalSeconds = 0
$PkgTotalCount = 0

foreach($key in $PkgKeys){

    if(-not $PkgSource.ContainsKey($key)){$PkgSource.Add($key, $null)}
    if(-not $PkgProtocol.ContainsKey($key)){$PkgProtocol.Add($key, $null)}
    if(-not $PkgMaster.ContainsKey($key)){$PkgMaster.Add($key, $null)}
    if(-not $PkgBytes.ContainsKey($key)){$PkgBytes.Add($key, 0)}
    if(-not $PkgBlkrate.ContainsKey($key)){$PkgBlkrate.Add($key, $null)}
    if(-not $PkgWorkrate.ContainsKey($key)){$PkgWorkrate.Add($key, $null)}
    if(-not $PkgDisconnected.ContainsKey($key)){$PkgDisconnected.Add($key, $null)}
    if(-not $PkgBackoff.ContainsKey($key)){$PkgBackoff.Add($key, $null)}
    if(-not $PkgNomadJobCompleted.ContainsKey($key)){$PkgNomadJobCompleted.Add($key, $null)}
    if(-not $PkgLargeFile.ContainsKey($key)){$PkgLargeFile.Add($key, $null)}
    

    if($PkgStartedCopyTime.ContainsKey($key) -and $PkgNomadJobCompleted.ContainsKey($key)){
        $PkgNomadJobSeconds.Add( $key, ((New-TimeSpan -Start $PkgStartedCopyTime[$key] -End $PkgNomadJobCompleted[$key]).TotalSeconds) )
    } else {$PkgNomadJobSeconds.Add($key, $null)}
    

    $obj = New-Object System.Object
    $obj | Add-Member -type NoteProperty -name PkgIdAndVer -value $key
    $obj | Add-Member -type NoteProperty -name Protocol -value ($PkgProtocol[$key])
    $obj | Add-Member -type NoteProperty -name Master -value ($PkgMaster[$key])
    $obj | Add-Member -type NoteProperty -name ContentSource -value ($PkgSource[$key])
    $MBytes = ($PkgBytes[$key].Value) / 1048576
    $obj | Add-Member -type NoteProperty -name MBytes -value ( "{0:N4}" -f  $MBytes)
    $obj | Add-Member -type NoteProperty -name LargeFileFlag -value ($PkgLargeFile[$key])
    
    if($PkgNomadJobSeconds[$key] -ne $null){
        $timespan = New-TimeSpan -Seconds ($PkgNomadJobSeconds[$key])
        $obj | Add-Member -type NoteProperty -name JobTime -value ( "{0}h:{1}m:{2}s" -f $timespan.Hours, $timespan.Minutes, $timespan.Seconds )
        $obj | Add-Member -type NoteProperty -name JobTimeInSecs -value ($PkgNomadJobSeconds[$key])
    } else {
        $obj | Add-Member -type NoteProperty -name JobTime -value "???"
        $obj | Add-Member -type NoteProperty -name JobTimeInSecs -value "???"
    }

    $obj | Add-Member -type NoteProperty -name BlkRate -value ($PkgBlkrate[$key])
    $obj | Add-Member -type NoteProperty -name WorkRate -value ($PkgWorkrate[$key])
    $discVal = [int]($PkgDisconnected[$key])
    if($discVal -gt $timespan.TotalSeconds){$discVal = "???"}
    $obj | Add-Member -type NoteProperty -name DisconnSecs -value ($discVal)
    $backoffVal = [int]($PkgBackoff[$key])
    if($backoffVal -gt $timespan.TotalSeconds){$backoffVal = "???"}
    $obj | Add-Member -type NoteProperty -name BackoffSecs -value ($backoffVal)
    $obj | Add-Member -type NoteProperty -name StartedAt -value ($PkgStartedCopyTime[$key])
    $obj | Add-Member -type NoteProperty -name CompletedAt -value ($PkgNomadJobCompleted[$key])
    $obj | Add-Member -type NoteProperty -name LogFile -value ($PkgLogFile[$key])
    $PkgObj  += $obj

}

$PkgObj | Export-Csv -Path $OutputFile -NoTypeInformation -Force
