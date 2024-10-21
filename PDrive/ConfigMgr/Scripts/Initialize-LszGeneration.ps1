#.Synopsis
#    This will generate LsZ files for this local ConfigMgr DP (run script on the DP itself).
#    Duncan Russell
#    1E http://www.1e.com
#    version 1.2.3
#    - [DR 4/30/2016] initial script 
#    - [DR 5/2/2016] added progress bar, added additional date checking to avoid pre-request success logs
#    - [DR 5/3/2016] removed pkg list from the SQL query, not needed with CM12
#    - [DR 5/5/2016] added AppModel to SQL query
#    
#.Description
#    This script will take the package directories on the local DP folder and request the LsZ file
#    generation from NomadBranch for each.  It does so in a multi-threaded fashion to optimize server use.
#
#.PARAMETER SiteServer
#    This is the ConfigMgr Primary Site Server.
#
#.PARAMETER SiteCode
#    This is the ConfigMgr Site Code matching the PrimaryServer param
#
#.PARAMETER DpPort
#    This is the TCP port used for this machine's DP web site.  The default value is 80. 
#
#.PARAMETER MaxThreads
#    This is the maximum number of threads to run at any given time.  If resources are too congested try lowering
#    this number.  The default value is 20.
#
#.PARAMETER MaxThreadTime
#    This is the maximum number of minutes each LsZ request will be active before timing out. Note: the request has
#    already been sent so the DP will still process it (if it didn't error out), but the script will no longer wait
#    on a reply after this number of minutes. The default value is 10.
#    
#.PARAMETER SleepTimer
#    This is the time between cycles of the child process detection cycle.  The default value is 200ms.  If CPU 
#    utilization is high then you can consider increasing this delay.  If the child script takes a long time to
#    run, then you might increase this value to around 1000 (or 1 second in the detection cycle).
#
#.PARAMETER PackagePath
#    Location for package content on local server.  Default is C:\SMSPKGC$
#
#.PARAMETER Logging
#    Enables logging.
#
#.PARAMETER LogPath
#    Path for log file if Logging enabled. Default is C:
#    
#.EXAMPLE
#    
#    .\GenLsz-threaded.ps1 -SiteCode P01 -SiteServer PrimaryServer1 -MaxThreads 30 -MaxThreadTime 20 -DpPort 8080 -Logging
#

Param(
    [Parameter(Mandatory=$true)][String]$SiteServer,
    [Parameter(Mandatory=$true)][String]$SiteCode,
    [String]$DpPort = "80",
    $MaxThreads = 20,
    $MaxThreadTime = 10,
    $SleepTimer = 200,
    $PackagePath = "C:\SMSPKGC$",
    [switch]$Logging = $false,
    $LogPath = "C:"
)

Function qryGetPackageHashes{ #param([string]$pkgidList)
    $qry = @"
(
--Packages, Drivers, boot images, WIM
SELECT DISTINCT [PkgID], 
[ContentId],ContentDPMap.Version, [URL], [ServerName], [NewHash]
FROM ContentDPMap
INNER JOIN SMSPackages ON ContentDPMap.ContentID = SMSPackages.PkgID
WHERE AccessType = 1
AND ServerName LIKE '$($LocalServerName)%'
and PackageType not in (5,8)
)
union
(
--Applications
SELECT DISTINCT [PkgID] = SMSPackages.PkgID, [ContentId] = c.Content_UniqueID, [Version] = c.ContentVersion, [URL], [ServerName], [NewHash] = ch.[Hash]
FROM ContentDPMap
INNER JOIN SMSPackages ON ContentDPMap.ContentID = SMSPackages.PkgID
INNER JOIN v_Content c on c.PkgID = ContentDPMap.ContentID
INNER JOIN v_ContentInfo cinf on c.Content_UniqueID = cinf.Content_UniqueID
INNER JOIN SMSContentHash ch on cinf.Content_ID = ch.Content_ID
WHERE AccessType = 1
AND c.Content_ID = (SELECT MAX(Content_ID) from v_Content where PkgID = ContentDPMap.ContentID) 
AND ServerName LIKE '$($LocalServerName)%'
and PackageType = 8
)
union
(
--Software Update deployments
SELECT DISTINCT [PkgID] = SMSPackages.PkgID, [ContentId] = SMSPackages.PkgID, 
ContentDPMap.[Version], [URL], [ServerName], [NewHash] = ch.[Hash]
FROM ContentDPMap
INNER JOIN SMSPackages ON ContentDPMap.ContentID = SMSPackages.PkgID
INNER JOIN v_Content c on c.PkgID = ContentDPMap.ContentID
INNER JOIN v_ContentInfo cinf on c.Content_UniqueID = cinf.Content_UniqueID
INNER JOIN SMSContentHash ch on cinf.Content_ID = ch.Content_ID
WHERE AccessType = 1
AND c.Content_ID = (SELECT MAX(Content_ID) from v_Content where PkgID = ContentDPMap.ContentID) 
AND ServerName LIKE '1e-dp01%'
and PackageType = 3
)
order by ContentID
"@
    if ($Logging -eq $true)
	    {
		    WriteLog "executing SQL query:"
    		WriteLog $qry
	    }
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = $Global:SQLConnectString
    $SqlConnection.Open()
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $qry
    $SqlCmd.Connection = $SqlConnection
    $reader = $SqlCmd.ExecuteReader()
    if (($reader.HasRows))
    	{
            while ($Reader.Read()) {
			    $pkgid = $reader.GetValue(0)
	            $contentid = $reader.GetValue(1)
                $pkgver = $reader.GetValue(2)
	            $URL = $reader.GetValue(3)
	            $SiteServer = $reader.GetValue(4) 
        	    $Newhash = $reader.GetValue(5)
                #Add new pkg info to the PkgObj collection
                $obj = New-Object System.Object
                $obj | Add-Member -type NoteProperty -name pkgid -value $pkgid
                $obj | Add-Member -type NoteProperty -name contentid -value $contentid
                $obj | Add-Member -type NoteProperty -name pkgver -value $pkgver
                $obj | Add-Member -type NoteProperty -name URL -value $URL
                $obj | Add-Member -type NoteProperty -name SiteServer -value $SiteServer
                $obj | Add-Member -type NoteProperty -name Newhash -value $Newhash
                $Global:PkgObj  += $obj

               }
    	} else {
            "No rows!"
            if ($Logging -eq $true){
		        WriteLog "No rows found in SQL server!"
    	    }
        }
    $SqlConnection.Close()
}

Function WriteLog{
   Param ([string]$string)
   Add-content $Logfile -value "$(Get-date -format G)  $string"
   [System.Threading.Thread]::Sleep(250)
}

#scriptblock for generating LsZ process
$GetLsZGen = {
    Param ([String]$pkgid,[String]$contentid,[String]$SiteServer,[String]$pkgver,[String]$URL,[String]$NewHash,$sessionVars)
    Function WriteLog{
        Param ([string]$string)
        Add-content $sessionVars["Logfile"] -value "$(Get-date -format G)  $string"
        [System.Threading.Thread]::Sleep(250)
    }	
    
    #Add pkgid to active job session variable. and to search array
    ([hashtable]($sessionVars["pkgStartTime"])).Add($contentid, (Get-Date))
    ([System.Collections.ArrayList]($sessionVars["currentSearch"])).Add("$($contentid)_$($pkgver)") | Out-Null
    if($contentid.ToLower() -like "content_*"){
        # URL is different for applications
        $URL = $URL.Replace($pkgid, "$($contentid).$($pkgver)")
        $IsAppModel = $true
    }
    $POST = "http://$($SiteServer):$($sessionVars["DpPort"])/LSZFILES/LSZGEN?pkgid=$($contentid)&ver=$($pkgver)&source=%22$($URL)%22&hash=$($NewHash)"
    if ($sessionVars["log"] -eq $true){
	    WriteLog "Processing job for $($contentid), sending LsZ request"
    }
    
    #Request the LsZ
    try{
        $request = [System.Net.WebRequest]::Create($POST)
        $response = $request.GetResponse()
	    $status = $response.StatusDescription
        while(1 -eq 1){
            #continue to hang the job thread
            Start-Sleep -Seconds 60
        }
    }
    catch [Net.WebException]
    {
        if ($sessionVars["log"] -eq $true){
            WriteLog "ERROR Requesting LsZ for $($contentid):$_"
        }
    }
}

#region Init variables and get content list
    #Create the Log file for writing later.
    if ($Logging -eq $true) { $Logfile = "$LogPath\GenLszDPthreaded.log"}
    if ($Logging -eq $true){
	    WriteLog "Starting script"
    }
    $LocalServerName = $env:computername
    $NomadLogFile = (Get-ItemProperty "hklm:\SOFTWARE\1E\NomadBranch" -Name LogFileName).LogFileName 
    $ReadLines = $MaxThreads * 15
    $Global:PkgObj  = @()
    $MonthAbbrToNum = @{"Jan"=1;"Feb"=2;"Mar"=3;"Apr"=4;"May"=5;"Jun"=6;"Jul"=7;"Aug"=8;"Sep"=9;"Oct"=10;"Nov"=11;"Dec"=12}
    
    $sqlinfo = gwmi sms_sci_sitedefinition -computer $SiteServer -namespace root\sms\site_$SiteCode -filter "SiteCode='$SiteCode'"
    $sqlserver = $sqlinfo.SQLServerName
    $sqldb = $sqlinfo.SQLDatabaseName
    $Global:SQLConnectString = "Server=$sqlserver;Database=$sqldb;Integrated Security=True"
    if($sqlserver -eq $Null){
        if ($Logging -eq $true){
		    WriteLog "No SQL server found in $($SiteServer) WMI"
    	}
        Throw "No SQL server found in $($SiteServer) WMI"
    }

    # Get the list of packages from the local DP
    #$PkgList = Get-ChildItem -path $PackagePath | Where-Object -FilterScript {$_.Mode -Like "D*"} # | Select -property Name
    #$PkgListCsv =  "'$([string]::Join("','",$PkgList.Name))'"

    #populate pkgObj
    qryGetPackageHashes #$PkgListCsv

    #Create synchronized hashtable for passing variables across runspaces
    $sessionVars = [hashtable]::Synchronized(@{})
    $sessionVars["DpPort"] = $DpPort
    $sessionVars["log"] = $Logging
    $sessionVars["Logfile"] = $Logfile
    $sessionVars["NomadLogFile"] = $NomadLogFile
    $sessionVars["ReadLines"] = $ReadLines
    $sessionVars["pkgStartTime"] = @{}
    $tempArray = @()
    $sessionVars["currentSearch"] = [System.Collections.ArrayList]$tempArray

    $ISS = [system.management.automation.runspaces.initialsessionstate]::CreateDefault()
    $RunspacePool = [runspacefactory]::CreateRunspacePool(1, $MaxThreads, $ISS, $Host)
    $RunspacePool.Open()
    $Jobs = @()
    
#endregion Begin

#region pre-load jobs
    Write-Progress -Activity "Preloading threads" -Status "Starting Job $($jobs.count)"
    ForEach ($Object in $Global:PkgObj ){
        
        if ($Logging -eq $true){
    	    WriteLog "Preloading job for content $($Object.contentid)"
        }
 
        $PowershellThread = [powershell]::Create().AddScript($GetLsZGen)
        $PowershellThread.AddParameter("pkgid", $Object.pkgid) | Out-Null
        $PowershellThread.AddParameter("contentid", $Object.contentid) | Out-Null
        $PowershellThread.AddParameter("SiteServer", $Object.SiteServer) | Out-Null
        $PowershellThread.AddParameter("pkgver", $Object.pkgver) | Out-Null
        $PowershellThread.AddParameter("URL", $Object.URL) | Out-Null
        $PowershellThread.AddParameter("NewHash", $Object.NewHash) | Out-Null
        $PowershellThread.AddArgument($sessionVars) | Out-Null
        $PowershellThread.RunspacePool = $RunspacePool
        
        $Handle = $PowershellThread.BeginInvoke()
        $Job = "" | Select-Object Handle, Thread, object, Pkgid, Pkgver, Pkgid_ver
        $Job.Handle = $Handle
        $Job.Thread = $PowershellThread
        $Job.Object = $Object.ToString()
        $Job.Pkgid = $Object.pkgid
        $Job.Pkgver = $Object.pkgver
        $Job.Pkgid_ver = "$($Object.contentid)_$($Object.pkgver)"
        
        $Jobs += $Job
    }
        
#endregion Process

#region Process jobs
    $ResultTimer = Get-Date
    While (@($Jobs | Where-Object {$_.Handle -ne $Null}).count -gt 0)  {
        $searchList = ([System.Collections.ArrayList]($sessionVars["currentSearch"]) -join "|")
        
        $Remaining = "$($($Jobs | Where-Object {$_.Handle.IsCompleted -eq $False}).Pkgid)"
        If ($Remaining.Length -gt 60){
            $Remaining = $Remaining.Substring(0,60) + "..."
        }
        Write-Progress `
            -Activity "Waiting for Jobs - $($MaxThreads - $($RunspacePool.GetAvailableRunspaces())) of $MaxThreads threads running" `
            -PercentComplete (($Jobs.count - $($($Jobs | Where-Object {$_.Handle.IsCompleted -eq $False}).count)) / $Jobs.Count * 100) `
            -Status "$(@($($Jobs | Where-Object {$_.Handle.IsCompleted -eq $False})).count) remaining - $remaining" 

        #search NomadBranch.log for completed jobs
        $patternOK = 'OK - "LSZFILES\\(?<pkgid_ver>(' + $searchList + '))\.LsZ" \$\$\<LSZwork_(?:[^\(]+)\((?:\d*)\)\>\<\w{3} (?<month>\w{3}) (?<day>\d{2}) (?<hour>\d{2}):(?<minute>\d{2}):(?:\d{2}\.\d{3}) (?<year>\d{4})' 
        $patternExists = 'LsZfile "(?<pkgid_ver>(' + $searchList + '))\.LsZ" already exists \$\$\<[^\>]+\>\<\w{3} (?<month>\w{3}) (?<day>\d{2}) (?<hour>\d{2}):(?<minute>\d{2}):(?:\d{2}\.\d{3}) (?<year>\d{4})'
        $mc = [regex]::Matches((Get-Content $NomadLogFile -Tail $ReadLines | Out-String),$patternOK,"Multiline")
        $mc2 = [regex]::Matches((Get-Content $NomadLogFile -Tail $ReadLines | Out-String),$patternExists,"Multiline")
        foreach($m in $mc){
            $lszMatchDate = Get-Date -Month ($MonthAbbrToNum[($m.Groups["month"].value)]) -Day ($m.Groups["day"].value) -Year ($m.Groups["year"].value) -Hour ($m.Groups["hour"].value) -Minute ($m.Groups["minute"].value)
            ForEach ($Job in $($Jobs | Where-Object { ( $_.Handle.IsCompleted -eq $False ) -and ( $_.Pkgid_ver -eq ($m.Groups["pkgid_ver"].value) ) -and ( $lszMatchDate -gt (([hashtable]($sessionVars["pkgStartTime"])).Get_Item($Job.Pkgid)) ) })){
                if ($Logging -eq $true){
        		    WriteLog "SUCCESS LszGen for content $($Job.Pkgid)"
                }
                if(([hashtable]($sessionVars["pkgStartTime"])).ContainsKey($($Job.Pkgid))){
                    ([hashtable]($sessionVars["pkgStartTime"])).Remove($($Job.Pkgid))
                }
                ([System.Collections.ArrayList]($sessionVars["currentSearch"])).Remove($m.Groups["pkgid_ver"].value) | out-null
               
                $Job.Thread.Dispose()
                $Job.Thread = $Null
                $Job.Handle = $Null
                $ResultTimer = Get-Date                
            }
        }
        
        $searchList = ([System.Collections.ArrayList]($sessionVars["currentSearch"]) -join "|")
        foreach($m in $mc2){
            $lszMatchDate = Get-Date -Month ($MonthAbbrToNum[($m.Groups["month"].value)]) -Day ($m.Groups["day"].value) -Year ($m.Groups["year"].value) -Hour ($m.Groups["hour"].value) -Minute ($m.Groups["minute"].value)
            ForEach ($Job in $($Jobs | Where-Object { ( $_.Handle.IsCompleted -eq $False ) -and ( $_.Pkgid_ver -eq ($m.Groups["pkgid_ver"].value) ) -and ( $lszMatchDate -gt (([hashtable]($sessionVars["pkgStartTime"])).Get_Item($Job.Pkgid)) ) })){
                if ($Logging -eq $true){
        		    WriteLog "WARNING LsZ already existed for content $($Job.Pkgid)"
                }
                if(([hashtable]($sessionVars["pkgStartTime"])).ContainsKey($($Job.Pkgid))){
                    ([hashtable]($sessionVars["pkgStartTime"])).Remove($($Job.Pkgid))
                }
                ([System.Collections.ArrayList]($sessionVars["currentSearch"])).Remove($m.Groups["pkgid_ver"].value) | out-null
               
                $Job.Thread.Dispose()
                $Job.Thread = $Null
                $Job.Handle = $Null
                $ResultTimer = Get-Date                
            }
        }

        #Process queued jobs, check to see if over MaxThreadTime
        ForEach ($Job in $($Jobs | Where-Object {$_.Handle.IsCompleted -eq $False -and ([hashtable]($sessionVars["pkgStartTime"])).ContainsKey($_.Pkgid) })){
            if ( ( (get-date) - (([hashtable]($sessionVars["pkgStartTime"])).Get_Item($($Job.Pkgid))) ).totalMinutes -gt $MaxThreadTime) {
                if ($Logging -eq $true){
    		        WriteLog "WARNING: No longer monitoring for $($Job.Pkgid_ver).LsZ, exceeded $($MaxThreadTime) minute(s)."
                }
                if(([hashtable]($sessionVars["pkgStartTime"])).ContainsKey($($Job.Pkgid))){
                    ([hashtable]($sessionVars["pkgStartTime"])).Remove($($Job.Pkgid))
                }
                ([System.Collections.ArrayList]($sessionVars["currentSearch"])).Remove($Job.Pkgid_ver) | out-null
                $Job.Thread.dispose()
                $Job.Thread = $null
                $Job.Handle = $null
            }
        }

        Start-Sleep -Milliseconds $SleepTimer
        
    } 
    $RunspacePool.Close() | Out-Null
    $RunspacePool.Dispose() | Out-Null
    if ($Logging -eq $true){
        WriteLog "Script completed"
    }    
#endregion End 
