param(
[Parameter(Mandatory=$true)]
[String]$WKID
)

function Get-AADStatus {
    if ($null -eq $(Get-Module -Name AzureAD)) {
        Install-Module AzureAD -Force
    }
    Connect-AzureAD -TenantId 56c62bbe-8598-4b85-9e51-1ca753fa50f2 | Out-Null # inspirewellness.onmicrosoft.com
    Get-AzureADDevice -All $true -Filter "DisplayName eq '$WKID'" -ErrorAction SilentlyContinue | Select-Object DisplayName, AccountEnabled, 
    @{Name='DeviceTrustType'; Expression={switch ($_.DeviceTrustType) {'ServerAD' {'HAADJ'} 'Workplace' {'AAD Registered'}}}}, 
    @{Name='IntuneCoManaged'; Expression={$_.IsManaged}}, 
    @{Name='IntuneCompliant'; Expression={$_.IsCompliant}},
    ApproximateLastLogonTimeStamp
}

function Get-IntuneStatus {
    if ($null -eq $(Get-Module -Name Microsoft.Graph.Intune -ErrorAction SilentlyContinue)) {
        Install-Module Microsoft.Graph.Intune -Force
    }
    Connect-MSGraph | Out-Null
    Get-IntuneManagedDevice -Filter "DeviceName eq '$WKID'" | Select-Object DeviceName, ComplianceState, DeviceEnrollmentType, UserDisplayName, UserPrincipalName, lastsyncdatetime
}

$AADStatus = Get-AADStatus
$IntuneStatus = Get-IntuneStatus
$AADStatus | Format-Table -AutoSize
$IntuneStatus | Format-Table -AutoSize

if (Test-Connection -ComputerName $WKID -Count 1 -ErrorAction SilentlyContinue) {
    "$WKID is online, validating settings..."
    Invoke-Command -ComputerName $WKID -ScriptBlock {
        if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin -Name autoWorkplaceJoin -ErrorAction SilentlyContinue).autoWorkplaceJoin -eq 1) {
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin - autoWorkplaceJoin = 1 [CORRECT]"
        } else {
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin - autoWorkplaceJoin != 1 [NOT CORRECT]"
            "Fixing..."
            Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin -Name autoWorkplaceJoin -Value 1 -Force -Verbose
        }

        if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM -Name DisableRegistration -ErrorAction SilentlyContinue).DisableRegistration -eq 0) {
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM - DisableRegistration = 0 [CORRECT]"
        } else {
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM - DisableRegistration != 0 [NOT CORRECT]"
            "Fixing..."
            Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\MDM -Name DisableRegistration -Value 0 -Force -Verbose
        }
        if (!(Test-Path -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -ErrorAction SilentlyContinue)) {
            New-Item -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -Force
        }

        if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -Name TenantName -ErrorAction SilentlyContinue).TenantName -eq 'inspirewellness.onmicrosoft.com') {
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD - TenantName = inspirewellness.onmicrosoft.com [CORRECT]"
        } else {
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD - TenantName != inspirewellness.onmicrosoft.com [NOT CORRECT]"
            "Fixing..."
            Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -Name TenantName -Value 'inspirewellness.onmicrosoft.com' -Force
        }

        if ((Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -Name TenantID -ErrorAction SilentlyContinue).TenantID -eq '56c62bbe-8598-4b85-9e51-1ca753fa50f2') {
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD - TenantID = 56c62bbe-8598-4b85-9e51-1ca753fa50f2 [CORRECT]"
        } else {
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD - TenantID != 56c62bbe-8598-4b85-9e51-1ca753fa50f2 [NOT CORRECT]"
            "Fixing..."
            Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CDJ\AAD -Name TenantID -Value '56c62bbe-8598-4b85-9e51-1ca753fa50f2' -Force
        }

        $BaselineCM = 'CoMgmtSettingsProd'
        $BaselineCMCP = 'CoMgmtSettingsPilotCP'

        $Baselines = Get-CimInstance -Namespace root\ccm\dcm -ClassName SMS_DesiredConfiguration -Filter "DisplayName = '$BaselineCM' or DisplayName = '$BaselineCMCP'"
        $Baselines | Select-Object DisplayName, 
        @{Name='LastComplianceStatus'; Expression={
        switch ($_.LastComplianceStatus){
            0 {'NonCompliant'}
            1 {'Compliant'}
            2 {'NotApplicable'}
            3 {'Unknown'}
            4 {'Error'}
            5 {'NotEvaluated'}
        }
        }},LastEvalTime | Format-Table -AutoSize

        $Baselines.Where({$_.LastComplianceStatus -ne 1}) | ForEach-Object {
            "$($_.Name) is NOT COMPLIANT, fixing..."
            $arguments = @{
                Name = $_.Name
                Version = $_.Version
            }
            Invoke-CimMethod -Namespace root\ccm\dcm -ClassName SMS_DesiredConfiguration -MethodName TriggerEvaluation -Arguments $arguments
        }
    }
    if ($($AADStatus).DeviceTrustType -ne 'HAADJ') {
        "$WKID is not HAADJ, attempting to join..."
        if ($null -eq $(Get-Module -Name Invoke-CommandAs -ErrorAction SilentlyContinue)) {
            Install-Module Invoke-CommandAs -Force -ErrorAction SilentlyContinue
        }
        Invoke-CommandAs -ComputerName $WKID -AsSystem -ScriptBlock { & dsregcmd /join }
    } else {
        "$WKID is HAADJ!"
    }
    if ($($AADStatus).IntuneComanaged -ne $true -or $($AADStatus).IntuneCompliant -ne $true) {
        "$WKID is not Intune enrolled or compliant, attempting to sync..."
        Invoke-Command -ComputerName $WKID -ScriptBlock { Get-ScheduledTask | Where-Object {$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask }
    } else {
        "$WKID is Intune enrolled and compliant!"
    }
} else {
    "$WKID is offline, unable to validate settings."
}