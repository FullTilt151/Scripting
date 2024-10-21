#Add to Win10 20H2 IPU WP108457 - Win10 20H2 Targets Manual Add - Pull
$WKID = 'WKPC0WQQF9'
$LOC = Get-Location
$SiteCode = 'WP1'
If ($LOC.Path -ne "WP1:\") {
    $Drives = Get-PSDrive
        If ($Drives.Name -ne "WP1") {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -ErrorAction SilentlyContinue
            Set-Location "WP1:"
        }
        Set-Location "WP1:"
        $RESRC = Get-CMDevice -Name $WKID
        Add-CMDeviceCollectionDirectMembershipRule -CollectionId WP108457 -ResourceId $RESRC.ResourceID -Force
}
Invoke-WmiMethod -Path "ROOT\SMS\Site_$($SiteCode):SMS_Collection.CollectionId='WP108457'" -Name RequestRefresh -ComputerName CMWPPSS
Do {
    Start-Sleep -Seconds 60
    $InColl = Get-CMCollectionMember -CollectionId WP108457 | Where-Object -Property Name -EQ $WKID
} Until ($InColl -ne $null)
Write-Host "The computer resource has been added to the collection" -ForegroundColor Cyan
Invoke-WMIMethod -ComputerName $WKID -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}"
Write-Host "Triggered Machine Policy Retrieval & Evaluation" -ForegroundColor Green
Get-Date -Format HH:mm
Push-Location "C:"

#Get AD/AAD Info
$WKID = 'WKPF246BLR'
$MBR = Get-ADComputer -Identity $WKID -Properties MemberOf,OperatingSystemVersion
$MBR.MemberOf
$MBR.OperatingSystemVersion
$DistinguishedName = Get-ADComputer -Identity "$WKID"
Remove-ADGroupMember -Identity 'T_Azure_Intune_Compliance_Tier2' -Members $DistinguishedName
$Sndr = 'dchinnon@humana.com'
$Rcpt = Read-Host -Prompt "Enter the associates email address."
Connect-AzureAD
Do {
    Start-Sleep -Seconds 300
    $ObjID = Get-AzureADDevice -SearchString $WKID | Select-Object -ExpandProperty ObjectId
    $GrpMbr = Get-AzureADGroupMember -ObjectId "50b553dd-2c7d-44bc-b39f-8ac583bcf226" -Top 10000 | Where-Object -Property "ObjectId" -EQ $ObjID
} Until ($GrpMbr -eq $null)
Disconnect-AzureAD
Write-Host "T_Azure_Intune_Compliance_Tier2 has been removed from " -NoNewline -ForegroundColor Cyan
Write-Host "$WKID" -ForegroundColor Green
Send-MailMessage -From $Sndr -To $Rcpt -Subject 'REMOVED - This app has been blocked by your system administrator' -Body '
Perform the following:
In Search (Magnifying Glass) type "access work".
You should see auto suggestions.
Select "Access work or school".
Select Connected to HUMAD AD Domain.
Select Info.
Select Sync.
Logout (Sign Out) of Windows (CTRL + ALT + DEL / Sign out).
Login.
Verify "Blocking" has been removed.' -SmtpServer pobox.humana.com -Port 25

#CCMExec Service
Get-Service -Name CcmExec -ComputerName $WKID
Invoke-Command -ComputerName $WKID -ScriptBlock {
    $SRV = Get-Service -Name CCMExec
    $SRV.Status
    If ($SRV.Status -eq 'Stopped') {
        sc.exe config CCMExec start= delayed-auto
        Start-Service -Name CcmExec
    }
    $provmode = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\CCM\CcmExec -Name ProvisioningMode).ProvisioningMode
    If ($provmode -eq "true") {
        Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "SetClientProvisioningMode" $false
        Write-Output "Disabled provisioning, restarting CCMExec service..."
        Restart-Service -Name CcmExec -Force
    }
    else {
        Write-Output "Provisioning Mode is off!"
    }
}

#Get agent version
$WKID = 'WKPF26XKZW'
Invoke-Command -ComputerName $WKID -ScriptBlock {
    $BTVer = Get-Item -Path 'C:\Windows\System32\polmon.exe' -ErrorAction SilentlyContinue
    If ($BTVer.VersionInfo.FileVersion -lt '7.8.7.0') {
        Write-Host "Beyond Trust is not compliant" -ForegroundColor Red
    } Else {
        Write-Host "Beyond Trust version =" $BTVer.VersionInfo.FileVersion -ForegroundColor Green
    }
    $DGVer = Get-ItemProperty -Path 'HKLM:\SOFTWARE\VDG\' -Name 'Agent version' -ErrorAction SilentlyContinue
    If ($DGVer -ne $null) {
        Write-Host "Digital Guardian version =" $DGVer.'Agent version' -NoNewline -ForegroundColor Red
        Write-Host " Needs to be removed" -ForegroundColor Yellow
    }
    $FEVer = Get-Item -Path 'C:\Program Files (x86)\FireEye\xagt\xagt.exe' -ErrorAction SilentlyContinue
    If ($FEVer -ne $null) {
        Write-Host "FireEye version =" $FEVer.VersionInfo.FileVersion -NoNewline -ForegroundColor Red
        Write-Host " Needs to be removed" -ForegroundColor Yellow
    }
    $QVer = Get-Item -Path 'C:\Program Files\Qualys\QualysAgent\QualysAgent.exe' -ErrorAction SilentlyContinue
    If ($QVer.VersionInfo.FileVersion -lt  '4.2.0.8') {
        Write-Host "Qualys is not compliant" -ForegroundColor Red
    } Else {
        Write-Host "Qualys version =" $QVer.VersionInfo.FileVersion -ForegroundColor Green
    }
    $ZSVer = Get-Item -Path 'C:\Program Files (x86)\Zscaler\ZSATray\ZSATray.exe' -ErrorAction SilentlyContinue
    If ($ZSVer.VersionInfo.FileVersion -lt '3.4.0.124') {
        Write-Host "ZScaler is not compliant" -ForegroundColor Red
    } Else {
        Write-Host "ZScaler version =" $ZSVer.VersionInfo.FileVersion -ForegroundColor Green
    }
}