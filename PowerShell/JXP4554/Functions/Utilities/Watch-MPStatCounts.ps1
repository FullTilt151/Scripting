$SCCMConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWPS1658'
$SiteSystems = Get-CMNSiteSystems -SCCMConnectionInfo $SCCMConnectionInfo -role 'SMS Distribution Point'
$SiteServer = Get-CMNSiteSystems -SCCMConnectionInfo $SCCMConnectionInfo -role 'SMS Site Server'
$path = 'D:\SMS\MP\OUTBOXES\stat.box\'
While (1 -eq 1) {
    $total = 0
    $date = Get-Date -Format G
    $Results = New-Object PSObject
    Add-Member -InputObject $Results -MemberType NoteProperty -Name 'Date' -Value $date
    foreach ($SiteSystem in $SiteSystems) {
        $path = "\\$SiteSystem\d$\SMS\MP\OUTBOXES\STAT.box\"
        $backlog = "$path\Backlog\"
        $count = ([System.IO.Directory]::EnumerateFiles($path, '*.SVF') | Measure-Object | Select-Object -ExpandProperty count).ToString("#,#")
        $total += $count
        Add-Member -InputObject $Results -MemberType NoteProperty -Name $SiteSystem -Value $count
    }
    $path = "\\$SiteServer\d$\Program Files\Microsoft Configuration Manager\inboxes\statmgr.box\statmsgs"
    $count = ([System.IO.Directory]::EnumerateFiles($path,'*.SVF') | Measure-Object | Select-Object -ExpandProperty count).ToString("#,#")
    Add-Member -InputObject $Results -MemberType NoteProperty -Name $SiteServer -Value $count
    Add-Member -InputObject $Results -MemberType NoteProperty -Name 'Total on MPs' -Value $total.ToString("#,#")
    $total += $count
    Add-Member -InputObject $results -MemberType NoteProperty -Name 'Grand Total' -Value $total.ToString("#,#")
    #Add in Messsages/Minute
    if($previousResults){
        #calculate Messages/Minute for each MP
        $seconds = (New-TimeSpan -Start $previousResults.Date -End $results.Date).TotalSeconds
        foreach($result in $Results.PSObject.Properties){
            if($result.Name -notin ('Grand Total','Total on MPs','Date')){
                if($seconds -gt 0){Add-Member -InputObject $Results -MemberType NoteProperty -Name "$($result.Name) Msg per Min" -Value (($previousResults.($result.Name) - $result.Value) / $seconds * 60)}
                else{Add-Member -InputObject $Results -MemberType NoteProperty -Name "$($result.Name) Msg per Min" -Value 'N/A'}
            }
        }
    }
    else{
        #Put N/A for each of the MP's Messages/Minute
        foreach($result in $Results.PSObject.Properties){
            if($result.Name -notin ('Grand Total','Total on MPs','Date')){
                Add-Member -InputObject $Results -MemberType NoteProperty -Name "$($result.Name) Msg per Min" -Value 'N/A'
            }
        }
    }
    $previousResults = $Results
    Write-Output $Results
    Export-Csv -InputObject $Results -Path 'C:\Temp\StatCount.csv' -Append -NoTypeInformation -Force
    $runtime = (New-TimeSpan -Start $date -End (Get-Date)).Seconds
    if($runtime -lt 60){Start-Sleep -Seconds (60 - $runtime)}
}