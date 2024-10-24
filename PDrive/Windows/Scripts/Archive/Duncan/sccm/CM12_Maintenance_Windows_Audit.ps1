[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,HelpMessage="Please Enter Site Server Name")]
        $SiteServer,
    [Parameter(Mandatory=$True,HelpMessage="Please Enter Site Server Code")]
        $SiteCode,
    [Parameter(Mandatory=$True,HelpMessage="Please Enter report destination folder, example c:\temp")]
        $FileLocation
     )

Function Convert-DayNumbersToDayName
{
    [CmdletBinding()]
    Param(
         [String]$DayNumber
         )
        
    Switch ($DayNumber)
    {
          "1" {$DayName = "Sunday"}
          "2" {$DayName = "Monday"}
          "3" {$DayName = "TuesDay"}
          "4" {$DayName = "WednesDay"}
          "5" {$DayName = "ThursDay"}
          "6" {$DayName = "FriDay"}
          "7" {$DayName = "Saturday"}

    }
    
    Return $DayName
}

Function Convert-MonthToNumbers
{
    [CmdletBinding()]
    Param(
         [String]$MonthNumber
         )
        
    Switch ($MonthNumber)
    {
          "1" {$MonthName = "January"}
          "2" {$MonthName = "Feburary"}
          "3" {$MonthName = "March"}
          "4" {$MonthName = "April"}
          "5" {$MonthName = "May"}
          "6" {$MonthName = "June"}
          "7" {$MonthName = "July"}
          "8" {$MonthName = "August"}
          "9" {$MonthName = "September"}
          "10" {$MonthName = "October"}
          "11" {$MonthName = "November"} 
          "12" {$MonthName = "December"}
    }
    
    Return $MonthName
}

Function Convert-WeekOrderNumber
{
    [CmdletBinding()]
    Param(
         [String]$WeekOrderNumber
         )
        
    Switch ($WeekOrderNumber)
    {
          0 {$WeekOrderName = "Last"}
          1 {$WeekOrderName = "First"}
          2 {$WeekOrderName = "Second"}
          3 {$WeekOrderName = "Third"}
          4 {$WeekOrderName = "Fourth"}

    }
    
    Return $WeekOrderName
}

Function Convert-ScheduleString
{
    Param(
         $ScheduleString,
         $SiteCode,
         $SiteServer
         )
     
     $Class = "SMS_ScheduleMethods"
     $Method = "ReadFromString"
     $Colon = ":"
     $WMIConnection = [WMIClass]"\\$SiteServer\root\SMS\Site_$SiteCode$Colon$Class"
     $String = $WMIConnection.psbase.GetMethodParameters($Method)
     $String.StringData = $ScheduleString
     $ScheduleData = $WMIConnection.psbase.InvokeMethod($Method,$String,$null)
     
     $ScheduleClass = $ScheduleData.TokenData

     switch($ScheduleClass[0].__CLASS)
     {
        "SMS_ST_RecurWeekly" 
                           {
                             $ContentValidationShedule = "Occurs every: $($ScheduleClass[0].ForNumberOfWeeks) weeks on " + (Convert-DayNumbersToDayName -DayNumber $ScheduleClass[0].Day)
                             Return $ContentValidationShedule
                           }
       
       "SMS_ST_RecurInterval"
                           {
                            $ContentValidationShedule = "Occures every $($ScheduleClass[0].DaySpan) days"
                            Return $ContentValidationShedule
                           }
                           
       "SMS_ST_RecurMonthlyByDate"
                           {

                               If($ScheduleClass[0].MonthDay -eq 0){
                                    $ContentValidationShedule = "Occures the last day of every " + (Convert-MonthToNumbers -MonthNumber $ScheduleClass[0].ForNumberOfMonths)
                                    Return $ContentValidationShedule
                               }
                               Else{
                                    $ContentValidationShedule = "Occures day $($ScheduleClass[0].MonthDay) of every " + (Convert-MonthToNumbers -MonthNumber $ScheduleClass[0].ForNumberOfMonths)
                                    Return $ContentValidationShedule
                               }
                           }
                           
       "SMS_ST_RecurMonthlyByWeekday"    
                           {
                               $ContentValidationShedule = "Occures the " + (Convert-WeekOrderNumber -weekordernumber $ScheduleClass[0].WeekOrder) + " " + (Convert-DayNumbersToDayName -DayNumber $ScheduleClass[0].Day) + " of every " + (Convert-MonthToNumbers -MonthNumber $ScheduleClass[0].ForNumberOfMonths)
                               Return $ContentValidationShedule
                           }                 
      
      "SMS_ST_NonRecurring"
                           {
                            $ContentValidationShedule = "No Schedule"
                            Return $ContentValidationShedule
                           }                     
     }
    
}

#HTML style
$HeadStyle = "<style>"
$HeadStyle = $HeadStyle + "BODY{background-color:peachpuff;}"
$HeadStyle = $HeadStyle + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$HeadStyle = $HeadStyle + "TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}"
$HeadStyle = $HeadStyle + "TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:palegoldenrod}"
$HeadStyle = $HeadStyle + "</style>"

$CurrentDate = Get-Date
$EmptyArray = @()
$FileName = "MW_Audit.Html"

ConvertTo-Html -Head $HeadStyle -Body "<h2>Collection Maintenance Windows Audit: $CurrentDate</h2>" -ErrorAction STOP | Out-File "$FileLocation\$FileName"

    Try{
        $ColSettingsQuery = Get-WmiObject -Namespace "root\sms\site_$SiteCode" -Class "SMS_CollectionSettings" -ErrorAction STOP -ComputerName $SiteServer
    }
    Catch{
        Write-Host "Error: $($_.Exception.Message)"
    }


foreach($Item in $ColSettingsQuery)
{
    $Item.Get()

        
        $ColName = Get-WmiObject -Namespace "root\sms\site_$SiteCode" -Class "SMS_Collection" -Filter "CollectionID='$($Item.CollectionID)'"-ErrorAction STOP -ComputerName $SiteServer
        
        ConvertTo-Html -Head $HeadStyle -Body "<h3>$($ColName.Name)</h3>" |Out-File "$FileLocation\$FileName" -Append

        Foreach($MW in $Item.ServiceWindows)
        {
        
                $DObject = New-Object PSObject
                $DObject | Add-Member -MemberType NoteProperty -Name "CollectionID" -Value $($Item.CollectionID)
                $DObject | Add-Member -MemberType NoteProperty -Name "Start Date" -Value (Get-Date ([System.Management.ManagementDateTimeConverter]::ToDateTime($MW.StartTime)) -Format "dd.MM.yyyy H:mm")
                $DObject | Add-Member -MemberType NoteProperty -Name "Duration in minutes" -Value ($MW.Duration) 
                $DObject | Add-Member -MemberType NoteProperty -Name $($MW.Name) -Value (Convert-ScheduleString -SiteCode $SiteCode -SiteServer $SiteServer -ScheduleString $MW.ServiceWindowSchedules)
                $DObject | Add-Member -MemberType NoteProperty -Name "Enabled" -Value $($MW.IsEnabled)
                $DObject | Add-Member -MemberType ScriptProperty -Name "Type" -Value `
                    {
                        Switch ($MW.ServiceWindowType)
                        {
                            1 {$Type = "General"}
                            5 {$Type = "OSD"}
                        }
                            Return $Type
                    }
                
                $DObject | ConvertTo-Html -Fragment |Out-File "$FileLocation\$FileName" -Append
        }
           
}  
