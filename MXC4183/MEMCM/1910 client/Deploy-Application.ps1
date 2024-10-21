<#
    .SYNOPSIS
        This script performs the installation or uninstallation of an application(s).
        # LICENSE #
        PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows. 
        Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
        This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
        You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
    .DESCRIPTION
        The script is provided as a template to perform an install or uninstall of an application(s).
        The script either performs an "Install" deployment type or an "Uninstall" deployment type.
        The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
        The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
    .PARAMETER DeploymentType
        The type of deployment to perform. Default is: Install.
    .PARAMETER DeployMode
        Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
    .PARAMETER AllowRebootPassThru
        Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
    .PARAMETER TerminalServerMode
        Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
    .PARAMETER DisableLogging
        Disables logging to file for the script. Default is: $false.  
    .EXAMPLE
        powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
    .EXAMPLE
        powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
    .EXAMPLE
        powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
    .EXAMPLE
        Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
    .NOTES
        Toolkit Exit Code Ranges:
        60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
        69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
        69001 = Changing sites, please uninstall and reinstall. 
        70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
        
        69811 - Path too short pre-install, path was previously deleted/truncated
        69812 - Path too long pre-install, risk to additional PC issues.
        69813 - Path too short POST-install, your install has deleted/truncated the path. Recover from the text file.

    .LINK 
        http://psappdeploytoolkit.com
#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall')]
    [string]$DeploymentType = 'Install',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [string]$DeployMode = 'Silent',

    [Parameter(Mandatory = $false)]
    [switch]$AllowRebootPassThru = $false,

    [Parameter(Mandatory = $false)]
    [switch]$TerminalServerMode = $false,

    [Parameter(Mandatory = $false)]
    [switch]$NoPathChk,

    [Parameter(Mandatory = $false)]
    [switch]$DisableLogging = $false,

    #Parameters for site and if we're doing a site system
    [Parameter(Mandatory = $false, HelpMessage = "Specifies client site, MT1 - Test, WP1 - Production")]
    [ValidateSet('MT1', 'SP1', 'SQ1', 'WP1', 'WQ1')]
    [string]$Site = 'WP1',

    [Parameter(Mandatory = $false, HelpMessage = 'Clean old client install')]
    [Switch]$CleanOldClient,

    [Parameter(Mandatory = $false, HelpMessage = 'Install on site system, only to be used by SCCM Admins')]
    [Switch]$isSiteSystemInstall
)

Try {
    ## Set the script execution policy for this process
    Try {
        Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' 
    }
    Catch {
    }
	
    ##*===============================================
    ##* VARIABLE DECLARATION
    ##*===============================================
    ## Variables: Application
    [string]$appVendor = 'Microsoft'
    [string]$appName = 'EM Configuration Manager (MEMCM) Client (1910)'
    [string]$appVersion = '5.00.8913.1012'
    [string]$appArch = 'x86/x64'
    [string]$appLang = 'EN'
    [string]$appRevision = '01'
    [string]$appScriptVersion = '1.0.3'
    [string]$appScriptDate = '02/19/2020'
    [string]$appScriptAuthor = 'Mike Cook'
    [string]$nomadBranchBuild = '6.3.201'
    [string]$SCCMBuild = '5.00.8913.1012'
    [string]$shoppingAgentBuild = '1.0.300'
    [string]$CR = '66475'
    ##*===============================================
    ## Variables: Install Titles (Only set here to override defaults set by the toolkit)
    [string]$installName = 'System_Center_Configuration_Manager_(SCCM)_Client'
    [string]$installTitle = 'System_Center_Configuration_Manager_(SCCM)_Client'
	
    ##* Do not modify section below
    #region DoNotModify
	
    ## Variables: Exit Code
    [int32]$mainExitCode = 0
	
    ## Variables: Script
    [string]$deployAppScriptFriendlyName = 'Deploy Application'
    [version]$deployAppScriptVersion = [version]'3.7.0'
    [string]$deployAppScriptDate = '02/13/2018'
    [hashtable]$deployAppScriptParameters = $psBoundParameters
	
    ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation 
    }
    Else {
        $InvocationInfo = $MyInvocation 
    }
    [string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
    ## Dot source the required App Deploy Toolkit Functions
    Try {
        [string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
        If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) {
            Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." 
        }
        If ($DisableLogging) {
            . $moduleAppDeployToolkitMain -DisableLogging 
        }
        Else {
            . $moduleAppDeployToolkitMain 
        }
    }
    Catch {
        If ($mainExitCode -eq 0) {
            [int32]$mainExitCode = 60008 
        }
        Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
        ## Exit the script, returning the exit code to SCCM
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit 
        }
        Else {
            Exit $mainExitCode 
        }
    }
	
    #endregion
    ##* Do not modify section above
    ##*===============================================
    ##* END VARIABLE DECLARATION
    ##*===============================================

    try {
        [String]$moduleDir = "$scriptDirectory\AppDeployToolkit\Modules\"
        Write-Log -Message "Loading modules from $moduleDir"
        if (Test-Path -LiteralPath $moduleDir -PathType 'Container') {
            [Array]$modules = Get-ChildItem -LiteralPath $moduleDir -Filter '*.ps1'
            foreach ($module in $modules) {
                Write-Log -Message "Loading module $($module.FullName)"
                . $($module.FullName) 
            }
        }
    }
    catch {
        Write-Error -Message "Unable to load module $($module.FullName)"
        If (Test-Path -LiteralPath 'variable:HostInvocation') {
            $script:ExitCode = $mainExitCode; Exit 
        }
        Else {
            Exit $mainExitCode 
        }
    }
		
    If ($deploymentType -ine 'Uninstall') {
        ##*===============================================
        ##* PRE-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Pre-Installation'
		
        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
        Show-InstallationWelcome -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt # replace 'xyz123' with the app you're installing.  Weird bug that requires this or the script will crash.
		
        ## Show Progress Message (with the default message)
        Show-InstallationProgress
		
        ## <Perform Pre-Installation tasks here>
        $client = Get-CmClientInfo -Site $Site
        $doChangeSite = $false

        ## Check for common issues
        ## Access to HKLM:SOFTWARE\Microsoft\SMS\Mobile Client\
        # if (Test-Path -Path 'HKLM:\SOFTWARE\Microsoft\SMS\Mobile Client' -ErrorAction SilentlyContinue) {
        #     Remove-RegKey -hive 'HKLM' -key 'SOFTWARE\Microsoft\SMS\Mobile Client'
        # }

        ## Make sure Cache and Log directories exist
        
        ##*===============================================
        ##* INSTALLATION 
        ##*===============================================
        [string]$installPhase = 'Installation'
		
        ## Handle Zero-Config MSI Installations
        If ($useDefaultMsi) {
            [hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) 
            }
            Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) {
                $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } 
            }
        }
		<#
        if ($client.doInstallShopping) {
            Write-Log -Message 'Installing 1E Shopping Agent'
            Execute-MSI -Path "$dirFiles\Shopping\ShoppingAgent-1.0.100.msi" -Action Uninstall -ContinueOnError:$true
            Execute-MSI -Path "$dirFiles\Shopping\ShoppingAgent-1.0.200.msi" -Action Uninstall -ContinueOnError:$true
            Execute-MSI -Path "$dirFiles\Shopping\ShoppingAgent.msi" -Action Install
        }

        If ($client.doInstallNomad) {
            Write-Log -Message "Installing NomadBranch Client 6.0. using the parameters $($client.nomadParams)"
            Execute-MSI -Action Install -Path "$dirfiles\NomadBranch\NomadBranch-x64.msi" -Parameters $client.nomadParams
            
        }
        else {
            if (!$client.doInstallNomad -and $client.isNomadInstalled) {
                Write-Log -Message 'Nomad needs to be uninstalled'
                Remove-MSIApplications '1E NomadBranch'
            }
        }
        #>

        if ($client.isCcmClientInstalled) {
            if ($psBoundParameters['CleanOldClient']) {
                Write-Log -Message 'CleanOldClient was selected, Removing old client'
                Remove-CmClient
            }
            elseif ($client.assignedSiteCode -ne $Site) {
                Write-Log -Message 'Changing sites, please uninstall the client first' -Severity 3
                $mainExitCode = 69001
                $mainErrorMessage = 'Changing sites, please uninstall and reinstall'
                Exit $mainExitCode
            }
            else {
                Write-Log -Message 'Not changing sites, no cleanup necessary'
            }
        }

        if ($client.isSiteServer -and !($psBoundParameters['isSiteSystemInstall'])) {
            Write-Log -Message 'This is a site system, do not modify the client here'
            throw 'This is a site system, do not modify the client here'
        }

        Write-Log -Message 'Creating Arguments for install'
        $Arguments = "/NoCRLCheck /SkipPrereq:silverlight.exe /source:$dirfiles\SCCMClient DNSSUFFIX=rsc.humad.com SMSSITECODE=$Site "

        #Are we changing sites? If so, let's reset info
        if ($doChangeSite) {
            $Arguments = "$($Arguments)RESETKEYINFORMATION=True "
        }


        ## Add MSI Switches
        foreach ($SiteServer in $client.siteServers) {
            $Arguments = "$($Arguments)SMSMP=$SiteServer "
        }

        $Arguments = "$($Arguments)SMSCACHEDIR=""$($client.ccmCacheDir)"" SMSCACHESIZE=$($client.ccmCacheSize)"

        Write-Log -Message "Beginning installation. Client will be installed using the $Site sitecode."
        Write-Log -Message "Checking Windows Firewall Service is not disabled"
        if((Get-Service -Name MpsSvc).StartType -eq 'Disabled'){
            Write-Log -Message "Windows Firewall service is disabled, setting to Manual"
            Set-Service -Name MpsSvc -StartupType Manual
        }
        Write-Log -Message "Checking that Windows Firewall Service is started:"
        if((Get-Service -Name MpsSvc).Status -ne 'Running'){
            Write-Log -Message "Starting Windows Firewall Service"
            Start-Service -Name MpsSvc
        }
        Write-Log -Message "Using the arguments: $Arguments"
        Execute-Process -FilePath "$dirfiles\SCCMClient\ccmsetup.exe" -Arguments $Arguments -ContinueOnError:$true
        While ((Get-Process -name ccmsetup -ErrorAction SilentlyContinue | Measure-Object).count -gt 0) {
            Write-log "Waiting for ccmsetup to finish"
            Start-Sleep -Seconds 30
        }
        Set-CmCacheDir -ccmCacheDir $client.ccmCacheDir
        Write-Log -Message 'CCMSetup has finished, checking the log to see if we are good to go'
        $isCCMSetup = $false
        $log = Get-Content C:\windows\ccmsetup\logs\ccmsetup.log
        for ($x = $log.Count - 10 ; $x -lt $log.Count ; $x++) {
            if ($log[$x] -match 'CcmSetup is exiting with return code [07]') {
                $isCCMSetup = $true
            }
        }
        If ($isCCMSetup) {
            Write-log -Message "CcmSetup successful."
        }
        else {
            Write-Log -Message 'CcmSetup has failed, check the C:\Windows\CCMSetup\logs\CCMSetup.log to find out why' -Severity 3
            throw 'CcmSetup has failed, check the C:\Windows\CCMSetup\logs\CCMSetup.log to find out why'
        }

        #Do we need to move the log directory?
        if ($client.ccmLogDir -ne 'C:\Windows\CCM\Logs') {
            Set-CmLogDirectory -ccmLogDir $client.ccmLogDir
        }

        ##*===============================================
        ##* POST-INSTALLATION
        ##*===============================================
        [string]$installPhase = 'Post-Installation'

        # Purge the policies if PowerShell version supports it
        # if ($PSVersionTable.PSVersion.Major -ge 3) {
        #     Write-Log -Message 'Purging CCM Policies'
        #     Reset-CmPolicies
        # }ShowBalloonNotifications

        Set-CmCacheSize -cachesize $client.ccmCacheSize

        Write-Log -Message 'Sleeping for 90 seconds before confirming site assignment'
        Start-Sleep -Seconds 90

        $currentClient = Get-CmSiteAndMP
        while ($currentClient.SiteCode -ne $Site) {
            Write-Log -Message "Site assignemnt is currently $($currentClient.SiteCode) instead of $site, resetting"
            Set-CmSiteAndMP -siteCode $site
            Write-Log -Message 'Sleeping for another 90 seconds before confirming site assignment'
            $currentClient = Get-CmSiteAndMP
        }
        Write-Log -Message 'Sleeping 300 seconds so client can get discovered'
        Start-Sleep -Seconds 300
        Write-Log -Message 'Forcing cliet to rescan policy and update deployments'
        Invoke-ClientScans
        Write-Log -Message 'All is well! Enjoy your new SCCM client!'

        ## Display a message at the end of the install
        If (-not $useDefaultMsi) {
            Show-InstallationPrompt -Message "Installation of $installTitle is complete you may need to reboot to finalize the install." -ButtonRightText 'OK' -Icon Information -NoWait 
        }
    }
    ElseIf ($deploymentType -ieq 'Uninstall') {
        ##*===============================================
        ##* PRE-UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Pre-Uninstallation'
		
        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
        Show-InstallationWelcome -CloseApps 'ccmsetup' -CloseAppsCountdown 60 # replace 'xyz123' with the app you're installing.  Weird bug that requires this or the script will crash.
		
        ## Show Progress Message (with the default message)
        Show-InstallationProgress
        
        $client = Get-CmClientInfo -Site $Site
        ## Verify this is not a Site System
        if ($client.isSiteServer -and !($psBoundParameters['isSiteSystemInstall'])) {
            Write-Log -Message 'This is a site system, do not modify the client here'
            throw 'This is a site system, do not modify the client here'
        }
		
        ##*===============================================
        ##* UNINSTALLATION
        ##*===============================================
        [string]$installPhase = 'Uninstallation'
		
        ## Handle Zero-Config MSI Uninstallations
        If ($useDefaultMsi) {
            [hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) {
                $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) 
            }
            Execute-MSI @ExecuteDefaultMSISplat
        }
        
        <#
        Write-Log -Message 'Beginning uninstallation. uninstalling NomadBranch'
        Remove-MSIApplications -Name '1E NomadBranch' -LogName 'C:\temp\Software_Install_Logs\NomadBranch-x64.log'
        Execute-MSI -Action Uninstall -Path "$dirFiles\NomadBranch\NomadBranch-x64.msi"
        Write-Log -Message 'Uninstalled NomadBranch'
        Write-Log -Message 'Uninstalling Shopping'
        Execute-MSI -Action Uninstall -Path "$dirFiles\Shopping\ShoppingAgent.msi"
        Write-Log -Message 'Uninstalled Shopping'
        #>
        
        Write-Log -Message 'Client will be uninstalled'
        Execute-Process -FilePath "$dirfiles\SCCMClient\ccmsetup.exe" -Arguments "/Uninstall"
        While ((Get-Process -name ccmsetup -ErrorAction SilentlyContinue | Measure-Object).count -gt 0) {
            Write-log -Message 'Waiting for ccmsetup to finish'
            Start-Sleep -Seconds 15
        }
        Write-Log -Message 'CCMSetup has finished uninstalling, checking the log to see if we are good to go'
        $isCCMSetup = $false
        $log = Get-Content C:\windows\ccmsetup\logs\ccmsetup.log
        for ($x = $log.Count - 10 ; $x -lt $log.Count ; $x++) {
            if ($log[$x] -match 'CcmSetup is exiting with return code [07]') {
                $isCCMSetup = $true
            }
        }
        If ($isCCMSetup) {
            Write-log -Message 'CcmSetup uninstalled successfully, cleaning up.'
            ## Delete WMI classes
            Write-Log -Message 'Removing WMI information'
            Get-WmiObject -Namespace root\ccm -List -ErrorAction SilentlyContinue | ForEach-Object { Get-WmiObject -Namespace root\ccm -Class $_.Name -ErrorAction SilentlyContinue | Remove-WmiObject -WarningAction SilentlyContinue }
            Get-WmiObject -query "Select * From __Namespace Where Name='CCM'" -Namespace root -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue
            Get-WmiObject -query "Select * From __Namespace Where Name='SMSDM'" -Namespace root -ErrorAction SilentlyContinue | Remove-WmiObject -ErrorAction SilentlyContinue

            ## Delete Registry
            Write-Log -Message 'Removing registry information'
            Remove-Item -Path HKLM:\SOFTWARE\Microsoft\CCMSetup -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path HKLM:\SOFTWARE\Microsoft\CCM -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path HKLM:\SOFTWARE\Microsoft\SMS -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\CCMSetup -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\CCM -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\SMS -Recurse -Force -ErrorAction SilentlyContinue

            ## Delete SMSConfig.ini
            Write-Log -Message 'Deleting C:\Windows\SMSCFG.ini'
            if (Test-Path 'C:\Windows\SMSCFG.ini') {
                Remove-Item -Path 'C:\Windows\SMSCFG.ini' -Force -ErrorAction SilentlyContinue
            }

            ## Delete CCM and CCMSetup Directories
            Write-Log -Message 'Deleting C:Windows\CCMSetup and C:\Windows\CCM directories'
            ('C:\Windows\CCM', 'C:\Windows\CCMSetup') | ForEach-Object { if (Test-Path $_) {
                    Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
                } }

            ## Delete CCMCacheDir
            if ($null -ne $ccmCacheDir -and $ccmCacheDir -ne '') {
                Write-Log -Message "Deleting $ccmCacheDir"
                if (Test-Path $ccmCacheDir) {
                    Remove-Item -Path $ccmCacheDir -Recurse -Force -ErrorAction SilentlyContinue
                }
            }

            ## Delete Certs
            Write-Log -Message 'Deleting SMS Certificates'
            Get-ChildItem Cert:\LocalMachine\SMS | Where-Object { $_.Subject -match "^CN=SMS, CN=$($env:COMPUTERNAME)" } | Remove-Item -ErrorAction SilentlyContinue
		
		
            ##*===============================================
            ##* POST-UNINSTALLATION
            ##*===============================================
            [string]$installPhase = 'Post-Uninstallation'
		
            ## <Perform Post-Uninstallation tasks here>
		
		
        }
	
        ##*===============================================
        ##* END SCRIPT BODY
        ##*===============================================
	
        ## Call the Exit-Script function to perform final cleanup operations
        Exit-Script -ExitCode $mainExitCode
    }
}
Catch {
    [int32]$mainExitCode = 60001
    [string]$mainErrorMessage = "$(Resolve-Error)"
    Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
    Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
    Exit-Script -ExitCode $mainExitCode
}