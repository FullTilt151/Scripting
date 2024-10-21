do { 
    function distro {
        # Find all content with State = 1, State = 2 or State = 3, see http://msdn.microsoft.com/en-us/library/cc143014.aspx
        $global:distro = Get-WmiObject -Namespace root\sms\site_cas -computername louappwps875 -Query "SELECT * FROM SMS_PackageStatusDistPointsSummarizer WHERE PackageID = 'CAS00802' or PackageID = 'CAS00805' or PackageID = 'CAS00806' or PackageID = 'CAS00B28'" | Where-Object {$_.state -ne 0}
    }
    
    distro
    $count = $global:distro.count
    
    if ($count -eq 0) {
        $count
        Send-MailMessage -Body "All done!" -Subject "ConfigMgr Alert: Content distribution is complete!" -to dratliff@humana.com -from no-reply@humana.com -smtpserver pobox.humana.com
    } else {
        write-warning $count
        #start-sleep -Seconds 60
        distro
        $count = $global:distro.count
    }
}
while ($count -ne 0)



Get-WmiObject -Namespace root\sms\site_cas -computername louappwps875 -Query "SELECT * FROM SMS_PackageStatusDistPointsSummarizer WHERE `
PackageID = 'CAS0038E' or`
PackageID = 'CAS000DF' or`
PackageID = 'CAS0067A' or`
PackageID = 'CAS000CA' or`
PackageID = 'CAS007A8' or`
PackageID = 'CAS002FC' or`
PackageID = 'CAS00336' or`
PackageID = 'CAS003B5' or`
PackageID = 'CAS00411' or`
PackageID = 'CAS0028C' or`
PackageID = 'CAS005C1' or`
PackageID = 'HUM003AB' or`
PackageID = 'CAS005EC' or`
PackageID = 'CAS005EB' or`
PackageID = 'CAS0032C' or`
PackageID = 'CAS00929' or`
PackageID = 'CAS000025'" | 
Where-Object {$_.state -ne 0} | sort PackageID | ft PackageID,State, ServerNALPath -AutoSize