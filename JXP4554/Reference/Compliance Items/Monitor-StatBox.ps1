#Set this variable to true for the remediation script, false for the detection script
$remediate = $false

$dirToMonitor = 'D:\SMS\MP\OUTBOXES\Stat.box'
$msgCount = (Measure-Object -InputObject (Get-ChildItem -Path $dirToMonitor)).Count
$limit = 10000
$fileCount = ([System.IO.Directory]::EnumerateFiles($dirToMonitor, '*.SVF') | Measure-Object).Count
$SMTPServer = "pobox.humana.com"
$SMTPSender = "ConfigMgrSupport@humana.com"
$Subject = "WP1 Stat.box over $limit messages on $($env:COMPUTERNAME)"
$eMailRecipent = 'ConfigMgrSupport@humana.com'
$eMailMessage = "The directory $dirToMonitor currently had $fileCount messages in it which is over the $limit limit."

if ($fileCount -lt $limit) {
    Write-Output $true
}
else {
    Write-Output $false
    if ($remediate) {
        if (((Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\MPFDM -ErrorAction SilentlyContinue).'State Message Batch Size') -ne 200000) {
            Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\MPFDM -Name 'State Message Batch Size' -Value 200000
            Restart-Service 'SMS_Executive'
            $eMailMessage = "$eMailMessage`r`nState Message Batch Size has been set to 200,000 and SMS Executive has been restarted."
        }
        else {
            $eMailMessage = "$eMailMessage`r`nState Message Batch Size has already been set."
        }
    }
    Send-MailMessage -To $eMailRecipent -From $SMTPSender -SmtpServer $SMTPServer -Subject $Subject -Body $eMailMessage -BodyAsHtml
}