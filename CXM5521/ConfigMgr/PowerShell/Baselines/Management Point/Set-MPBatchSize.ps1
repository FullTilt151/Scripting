#Set this variable to true for the remediation script, false for the detection script
$Remediate = $false

# SVF file count threshold. When count exceeds this, we will temporarily up the batch size
$SVF_threshold = 10000

# standard operation batch size. When the file count is below the threshold, we will set the batch size to the below value
$StandardBatchSize = 2333

# backlog operation batch size. When the file count is above the threshold, we will set the batch size to the below value
$BacklogTempBatchSize = 200000

$Client = New-Object -ComObject Microsoft.SMS.Client
$Site = $Client.GetAssignedSite()

$dirToMonitor = 'D:\SMS\MP\OUTBOXES\Stat.box'
$fileCount = ([System.IO.Directory]::EnumerateFiles($dirToMonitor, '*.SVF') | Measure-Object).Count
$SMTPServer = "pobox.humana.com"
$SMTPSender = "ConfigMgrSupport@humana.com"
$eMailRecipent = 'ConfigMgrSupport@humana.com'
$eMailMessage = "The directory $dirToMonitor currently has $fileCount messages in it."

function Set-MPBatchSize {
    param(
        [Parameter(Mandatory = $true)]
        [int]$BatchSize
    )
    Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\MPFDM -Name 'State Message Batch Size' -Value $BatchSize
}

function Get-MPBatchSize {
    (Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\SMS\MPFDM -ErrorAction SilentlyContinue).'State Message Batch Size'
}

switch ($fileCount -lt $SVF_threshold) {
    #region if the filecount is below our threshold we set batch size to $StandardBatchSize as needed
    $true {
        $CurrentBatchSize = Get-MPBatchSize
        if ($CurrentBatchSize -ne $StandardBatchSize) {
            switch ($Remediate) {
                $true {
                    Set-MPBatchSize -BatchSize $StandardBatchSize
                    Restart-Service 'SMS_Executive'
                    $Subject = "$Site Stat.box under $SVF_threshold messages on $($env:COMPUTERNAME)"
                    $eMailMessage = "$eMailMessage`r`nThis is below the threshold of $SVF_threshold. State Message Batch Size has been set back to to $StandardBatchSize and SMS Executive has been restarted"
                    Send-MailMessage -To $eMailRecipent -From $SMTPSender -SmtpServer $SMTPServer -Subject $Subject -Body $eMailMessage -BodyAsHtml
                }
                $false {
                    Write-Output $false
                }
            }
        }
        else {
            Write-Output $true
        }
    }
    #endregion if the filecount is below our threshold we set batch size to $StandardBatchSize as needed

    #region if the filecount is above our threshold we set batch size to $BacklogTempBatchSize as needed
    $false {
        $CurrentBatchSize = Get-MPBatchSize
        if ($CurrentBatchSize -ne $BacklogTempBatchSize) {
            switch ($remediate) {
                $true {
                    Set-MPBatchSize -BatchSize $BacklogTempBatchSize
                    Restart-Service 'SMS_Executive'
                    $Subject = "$Site Stat.box over $SVF_threshold messages on $($env:COMPUTERNAME)"
                    $eMailMessage = "$eMailMessage`r`nThis is above the threshold of $SVF_threshold. State Message Batch Size has been upped to $BacklogTempBatchSize and SMS Executive has been restarted."
                    Send-MailMessage -To $eMailRecipent -From $SMTPSender -SmtpServer $SMTPServer -Subject $Subject -Body $eMailMessage -BodyAsHtml
                }
                $false {
                    Write-Output $false
                }
            }
        }
        else {
            Write-Output $true
        }
    }
    #endregion if the filecount is above our threshold we set batch size to $BacklogTempBatchSize as needed
}
