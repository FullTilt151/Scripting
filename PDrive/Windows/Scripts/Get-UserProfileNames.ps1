#$wkids = Get-Content C:\temp\wkids.txt

foreach ($wkid in $wkids) {
    if (Test-Connection $wkid -count 1 -Quiet) {
        
        $users = Get-childitem \\$wkid\c$\users | 
        where {$_.name -notin ('Public','Administrator','CAW6893','AXV0200','btservice.humad','k2srvact','BTServerAcct','ecmadmin','SQL_Server_Service') -and $_.Name -notlike '*s' -and $_.Name -notlike '*a' -and $_.Name -notlike '*temp*'
        } | select -ExpandProperty Name
        if ($users -ne $null) {
            foreach ($user in $users) {
                $lastlogon = Get-ItemProperty \\$wkid\c$\users\$user\ntuser.dat -ErrorAction SilentlyContinue | select -ExpandProperty LastWriteTime
                $wkid + " " + $user + " " + $lastlogon # | out-file c:\temp\users.txt -Append
            }
        } else {
            $wkid + " NONE" #| out-file c:\users.txt -Append
        }

        Get-WmiObject -ComputerName $wkid win32_userprofile | where-object {
            $_.LocalPath -notin ('C:\Windows\system32\config\systemprofile','C:\Windows\ServiceProfiles\LocalService','C:\Windows\ServiceProfiles\NetworkService','C:\Users\btservice.humad','C:\Users\Administrator',
            'C:\Users\k2srvact','C:\Users\BTServerAcct','C:\Users\SQL_Server_Service','C:\Users\ecmadmin') -and
            $_.LocalPath -notlike '*s' -and $_.LocalPath -notlike '*a' -and $_.LastUseTime -ne $null
        } | ForEach-Object {
            "$name $($($_.LocalPath).Replace("C:\users\",'')) $($_.LastUseTime)"
        }
        Get-WmiObject -ComputerName $wkid win32_networkloginprofile | Format-Table Caption, LastLogon -AutoSize


    } else {
        "$wkid Offline" | out-file C:\Users.txt -Append
    }
}

#https://www.reddit.com/r/PowerShell/comments/46lypq/question_about_lastusetime_in_win32_userprofile/
#https://social.technet.microsoft.com/Forums/scriptcenter/en-US/b1917b2d-1100-47ab-a949-c61f0335e62e/win32userprofile-lastusetime-doesnt-appear-accurate?forum=ITCG
#http://howtocode.net/2016/06/win32_userprofile-lastusetime-tends-to-be-empty/