<#
    .SYNOPSIS
        Configure systems according to a CSV to be an MP, DP, or SUP
    .DESCRIPTION
        This script is used to setup a set of new MEMCM servers that are in the MP, DP, or SUP role. It requires
        a CSV file to be input with the headers specefied in the help for the EnvironmentCSV parameter.

        A Credential object is required because we need to create a scheduled task on remote machines, that will
        also be accessing network resources.
    .PARAMETER EnvironmentCSV
        CSV file containing the follow headers:

        ComputerName,Environment,SiteServer,MP,MP_SSL,DP,SUP,SUP_SSL,SUP_ContentSource,SUSDB,FSP,SQL,SSRS,SSRS_SQL,Datacenter
    .PARAMETER SiteCode
        The site code these changes are executed against
    .PARAMETER Role
        The role to configure for the servers, if they have it specified in the spreadsheet

        MP, DP, or SUP
    .PARAMETER Credential
        A Credential object used to create a scheduled task on remote machines that will also be accessing network resources.
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        After this script completes, further action will still be needed.

        * Force the relevent ConfigMgr* baselines to run on these machines AFTER role installation. This ensures that all
            configurations are consistent, and accurate.
        * Software Update Sync should be ran to get the SUPs ready for use (probably go to bed, not fun to watch)
        * Add servers to Distribution Point Groups, and Boundary Groups
#>
param (
    [parameter(Mandatory = $true)]
    [ValidateScript( { Test-Path -Path $_ -ErrorAction Stop } )]
    [ValidatePattern('.csv$')]
    [string]$EnvironmentCSV,
    [parameter(Mandatory = $true)]
    [ValidateSet('WP1', 'SP1', 'WQ1', 'SQ1', 'MT1')]
    [string]$SiteCode,
    [parameter(Mandatory = $true)]
    [ValidateSet('MP', 'DP', 'SUP')]
    [string[]]$Role,
    [parameter(Mandatory = $true)]
    [pscredential]$Credential
)
function Switch-ToSCCM {
    param (
        [Parameter(Mandatory = $false)]
        [ValidateSet('WP1', 'SP1', 'WQ1', 'SQ1', 'TST', 'MT1')]
        $SiteCode = 'WP1'
    )
    $ProviderMachineName = switch ($SiteCode) {
        'WP1' {
            'LOUAPPWPS1658.RSC.HUMAD.COM'
        }
        'SP1' {
            'LOUAPPWPS1825.RSC.HUMAD.COM'
        }
        'WQ1' {
            'LOUAPPWQS1151.RSC.HUMAD.COM'
        }
        'SQ1' {
            'LOUAPPWQS1150.RSC.HUMAD.COM'
        }
        'TST' {
            'LOUAPPWTS872.RSC.HUMAD.COM'
        }
        'MT1' {
            'LOUAPPWTS1441.RSC.HUMAD.COM'
        }
    }

    if ($null -eq (Get-Module ConfigurationManager)) {
        $null = Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
    }

    # Connect to the site's drive if it is not already present
    if ($null -eq (Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue)) {
        $Null = New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName
    }

    # Set the current location to be the site code.
    Set-Location -Path "$($SiteCode):\"
}
Push-Location
Set-Location -Path $env:SystemDrive

$EnvSum = Import-Csv -Path $EnvironmentCSV

$ServerInfo = foreach ($Server in $EnvSum) {
    if ($Server.Environment -eq $SiteCode) {
        [pscustomobject]@{
            ComputerName      = $Server.ComputerName
            SiteServer        = [bool]$Server.SiteServer
            MP                = [bool]$Server.MP
            MP_SSL            = [bool]$Server.MP_SSL
            DP                = [bool]$Server.DP
            SUP               = [bool]$Server.SUP
            SUP_SSL           = [bool]$Server.SUP_SSL
            SUP_ContentSource = $Server.SUP_ContentSource
            SUSDB             = $Server.SUSDB
            SQL               = [bool]$Server.SQL
            SSRS              = [bool]$Server.SSRS
            SSRS_SQL          = [bool]$Server.SSRS_SQL
            FSP               = [bool]$Server.FSP
        }
    }
}

#region ensure WSUS shares are created and permissions are set
$ContentHosts = $ServerInfo.where( { $_.SUP }).SUP_ContentSource | Select-Object -Unique
foreach ($ContentHost in $ContentHosts) {
    $SUPS = $ServerInfo.where( { $_.SUP -and $_.SUP_ContentSource -eq $ContentHost }).ComputerName
    $ContentHostFQDN = [SYSTEM.NET.DNS]::GetHostByName($ContentHost).HostName
    Write-Host "Identified $ContentHostFQDN as the WSUS content host - checking for WSUS SMB Share" -ForegroundColor Green
    Invoke-Command -ComputerName $ContentHostFQDN -ScriptBlock {
        $Share = Get-SmbShare -Name WSUS -ErrorAction SilentlyContinue

        switch ($null -eq $Share) {
            $true {
                Write-Host "SMB Share not found, will create and assign access" -ForegroundColor Yellow
                $ComputerADName = foreach ($SUP in $using:SUPS) {
                    [string]::Format('{0}$', $SUP)
                }
                New-Item -Path 'D:\WSUS' -ItemType Directory -Force -ErrorAction SilentlyContinue
                $Folder = 'D:\WSUS'
                $EmptyACL = New-Object System.Security.AccessControl.DirectorySecurity
                $EmptyACL.SetAccessRuleProtection($true, $true)
                $EmptyACL.SetAuditRuleProtection($true, $true)
                foreach ($Server in $ComputerADName) {
                    Write-Host "Adding FullControl access to $Folder on $env:COMPUTERNAME for $Server" -ForegroundColor Yellow
                    $AccessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($Server, [System.Security.AccessControl.FileSystemRights]::FullControl, "ContainerInherit,Objectinherit", "none", [System.Security.AccessControl.AccessControlType]::Allow)
                    $EmptyACL.AddAccessRule($AccessRule)
                }
                foreach ($User in @('SYSTEM', 'NETWORK SERVICE', 'ADMINISTRATORS')) {
                    Write-Host "Adding FullControl access to $Folder on $env:COMPUTERNAME for $User" -ForegroundColor Yellow
                    $AccessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($User, [System.Security.AccessControl.FileSystemRights]::FullControl, "ContainerInherit,Objectinherit", "none", [System.Security.AccessControl.AccessControlType]::Allow)
                    $EmptyACL.AddAccessRule($AccessRule)

                }
                $EmptyACL | Set-Acl -Path $Folder
                New-SmbShare -Path 'D:\WSUS' -FullAccess 'EVERYONE' -Name WSUS
            }
            $false {
                Write-Host "SMB Share found, will validate access" -ForegroundColor Green
                $Folder = $Share.Path
                $EmptyACL = New-Object System.Security.AccessControl.DirectorySecurity
                $EmptyACL.SetAccessRuleProtection($true, $true)
                $EmptyACL.SetAuditRuleProtection($true, $true)
                foreach ($Server in $ComputerADName) {
                    Write-Host "Adding FullControl access to $Folder on $env:COMPUTERNAME for $Server" -ForegroundColor Yellow
                    $AccessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($Server, [System.Security.AccessControl.FileSystemRights]::FullControl, "ContainerInherit,Objectinherit", "none", [System.Security.AccessControl.AccessControlType]::Allow)
                    $EmptyACL.AddAccessRule($AccessRule)
                }
                foreach ($User in @('SYSTEM', 'NETWORK SERVICE', 'ADMINISTRATORS')) {
                    Write-Host "Adding FullControl access to $Folder on $env:COMPUTERNAME for $User" -ForegroundColor Yellow
                    $AccessRule = [System.Security.AccessControl.FileSystemAccessRule]::new($User, [System.Security.AccessControl.FileSystemRights]::FullControl, "ContainerInherit,Objectinherit", "none", [System.Security.AccessControl.AccessControlType]::Allow)
                    $EmptyACL.AddAccessRule($AccessRule)

                }
                $EmptyACL | Set-Acl -Path $Folder
            }
        }
    }
}
#endregion ensure WSUS shares are created and permissions are set

Switch-ToSCCM -SiteCode $SiteCode

foreach ($Server in $ServerInfo) {
    if ($Server.DP -or $Server.MP -or $Server.SUP) {
        $FQDN = [SYSTEM.NET.DNS]::GetHostByName($Server.ComputerName).hostname
        Write-Host "Beginning processing of $FQDN - REBOOTING FIRST!!!" -ForegroundColor Green
        Restart-Computer -ComputerName $FQDN -Force -Wait -For PowerShell
        Write-Host "Server should be up again... waiting for 2 minutes just in case" -ForegroundColor Green
        Start-Sleep -Seconds 120
        if (-not (Get-CMSiteSystemServer -SiteCode $SiteCode -SiteSystemServerName $FQDN)) {
            Write-Host "Found that $FQDN is not a Site System Server yet - adding" -ForegroundColor Yellow
            New-CMSiteSystemServer -Servername $FQDN -AccountName $null -SiteCode $SiteCode
            do {
                Start-Sleep -Seconds 15
            }
            until (Get-CMSiteSystemServer -SiteCode $SiteCode -SiteSystemServerName $FQDN)
            Write-Host "$FQDN added as Site System Server sleeping 120 seconds" -ForegroundColor Green
            Start-Sleep -Seconds 120
        }
        if ($Server.DP -and (-not (Get-CMDistributionPoint -SiteCode $SiteCode -SiteSystemServerName $FQDN)) -and $Role -contains 'DP') {
            Write-Host "Found that $FQDN is not a Distribution Point yet - adding" -ForegroundColor Yellow
            $addCMDistributionPointSplat = @{
                SiteSystemServerName         = $FQDN
                EnableLedbat                 = $true
                ClientConnectionType         = 'Intranet'
                EnableContentValidation      = $true
                SiteCode                     = $SiteCode
                ContentValidationSchedule    = (New-CMSchedule -DayOfWeek Saturday)
                CertificateExpirationTimeUtc = (Get-Date -Date '08-26-2118')
                MinimumFreeSpaceMB           = 2048
            }
            Add-CMDistributionPoint @addCMDistributionPointSplat
            Write-Host "$FQDN added as a Distribution Point" -ForegroundColor Green
            do {
                Write-Host "Sleeping 15 seconds and checking if $FQDN shows as a DP in MEMCM" -ForegroundColor Green
                Start-Sleep -Seconds 15
            }
            until (Get-CMDistributionPoint -SiteCode $SiteCode -SiteSystemServerName $FQDN)
            Write-Host "$FQDN is now showing as a DP in MEMCM" -ForegroundColor Green
        }
        if ($Server.MP -and (-not (Get-CMManagementPoint -SiteCode $SiteCode -SiteSystemServerName $FQDN)) -and $Role -contains 'MP') {
            Write-Host "Found that $FQDN is not a Management Point yet - adding" -ForegroundColor Yellow
            $addCMManagementPointSplat = @{
                SiteSystemServerName = $FQDN
                ClientConnectionType = 'Intranet'
                SiteCode             = $SiteCode
                CommunicationType    = 'Http'
            }

            #region if this is an SSL MP, set the CommunicationType and EnableSSL
            switch ($Server.MP_SSL) {
                $true {
                    Write-Host "$FQDN marked for MP_SSL" -ForegroundColor Yellow
                    $addCMManagementPointSplat['CommunicationType'] = 'HTTPS'
                    $addCMManagementPointSplat['EnableSSL'] = $true
                }
            }
            #endregion if this is an SSL MP, set the CommunicationType and EnableSSL
            Add-CMManagementPoint @addCMManagementPointSplat
            Write-Host "$FQDN added as a Management Point" -ForegroundColor Green
            do {
                Write-Host "Sleeping 15 seconds and checking if $FQDN shows as an MP in MEMCM" -ForegroundColor Green
                Start-Sleep -Seconds 15
            }
            until (Get-CMManagementPoint -SiteCode $SiteCode -SiteSystemServerName $FQDN)
            Write-Host "$FQDN is now showing as an MP in MEMCM" -ForegroundColor Green
        }
        if ($Server.SUP -and (-not (Get-CMSoftwareUpdatePoint -SiteCode $SiteCode -SiteSystemServerName $FQDN)) -and $Role -contains 'SUP') {
            Write-Host "Found that $FQDN is not a Software Update Point yet - adding" -ForegroundColor Yellow
            $ContentHost = [SYSTEM.NET.DNS]::GetHostByName($($Server.SUP_ContentSource)).hostname
            $ContentHostPath = [string]::Format("\\{0}\WSUS", $ContentHost)
            $SUSDB_SQL = [SYSTEM.NET.DNS]::GetHostByName($($Server.SUSDB)).hostname
            $ContentPathCMD = [string]::Format("CONTENT_DIR={0}", $ContentHostPath)
            $SQLInstance = [string]::Format("SQL_INSTANCE_NAME={0}", $SUSDB_SQL)
            $PostInstallCMD = [string]::Format("postinstall {0} {1}", $ContentPathCMD, $SQLInstance)

            Write-Host "Invoking WsusUtil Post Install with [Arguments='$PostInstallCMD']" -ForegroundColor Yellow
            $ScriptBlockString = [string]::Format('Start-Process -FilePath "c:\Program Files\Update Services\tools\WsusUtil.exe" -ArgumentList "{0}" -Wait -NoNewWindow', $PostInstallCMD)
            $ScriptBlock = [ScriptBlock]::Create($ScriptBlockString)
            Invoke-CommandAs -ComputerName $FQDN -AsUser $Credential -RunElevated -ScriptBlock $ScriptBlock
            Write-Host "PostInstall invoked - waiting 180 seconds to let the dust settle" -ForegroundColor Yellow
            Start-Sleep -Seconds 180
            #region if this is an SSL SUP, run configuressl - note, the baseline will run later to 'fix' things regarding SSL. This will just end up setting the ServerCertificateName value in the registry
            switch ($Server.SUP_SSL) {
                $true {
                    Write-Host "$FQDN marked for SUP_SSL - will invoke WsusUtil.exe configuressl" -ForegroundColor Yellow
                    Invoke-Command -ComputerName $FQDN -ScriptBlock {
                        Start-Process -FilePath "c:\Program Files\Update Services\tools\WsusUtil.exe" -ArgumentList 'configuressl', $using:FQDN -NoNewWindow -Wait
                    }
                }
            }
            #endregion if this is an SSL SUP, run configuressl - note, the baseline will run later to 'fix' things regarding SSL. This will just end up setting the ServerCertificateName value in the registry

            $addCMSoftwareUpdatePointSplat = @{
                SiteSystemServerName = $FQDN
                ClientConnectionType = 'Intranet'
                SiteCode             = $SiteCode
                WsusIisSslPort       = 8531
                WsusIisPort          = 8530
                WsusSsl              = $($Server.SUP_SSL)
            }
            Add-CMSoftwareUpdatePoint @addCMSoftwareUpdatePointSplat
            Write-Host "$FQDN added as a Software Update Point" -ForegroundColor Green
            do {
                Write-Host "Sleeping 15 seconds and checking if $FQDN shows as a SUP" -ForegroundColor Green
                Start-Sleep -Seconds 15
            }
            until (Get-CMSoftwareUpdatePoint -SiteCode $SiteCode -SiteSystemServerName $FQDN)
            Write-Host "$FQDN is now showing as a SUP in MEMCM" -ForegroundColor Green
        }

        Get-CCMBaseline -ComputerName $Server.ComputerName | Where-Object { $_.BaselineName -match '^ConfigMgr' } | Invoke-CCMBaseline
    }
}
Write-Host "Script Complete"
Pop-Location