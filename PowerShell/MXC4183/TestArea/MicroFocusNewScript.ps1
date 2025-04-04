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
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
	
	69811 - Path too short pre-install, path was previously deleted/truncated
    69812 - Path too long pre-install, risk to additional PC issues
    69813 - Path too short POST-install, your install has deleted/truncated the path. Recover from the text file.

.LINK 
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$NoPathChk = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Micro Focus'
	[string]$appName = 'Unified Functional Testing'
	[string]$appVersion = '15.01'
	[string]$appArch = ''
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '08/27/2020'
	[string]$appScriptAuthor = 'Marty Barnett'
    [string]$CR = '67451'
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = ''
	[string]$installTitle = ''
	
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
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent
	
	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}
	
	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================

    ##*=========================
    ##* Add CR# to Name
    ##*=========================
    $installTitle = $installTitle + ' (CR# ' + $CR + ')'
		
	If ($deploymentType -ine 'Uninstall') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Path Check
        if ($NoPathChk -eq $false) {
            # Save the path
            $BackupFilename = $CR + 'backuppath.txt'
            $BackupPath = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
            Set-Content -Path "c:\temp\$BackupFilename" -Value $BackupPath -Force
            # Check path length and ensure it is less than 3000 characters or 2000 if unpatched by KB2685893.
            If ($envOSName -eq "Microsoft Windows 7 Enterprise") {
                $Hotfix = Get-WmiObject win32_quickfixengineering -Filter "HotFixID = 'KB2685893'"
                If ($Hotfix -ne $null) {$maxpathsize = 3500} else {$maxpathsize = 2000}
                }            Else {$maxpathsize = 4000}
            If ($BackupPath.length -lt 32) {Exit-Script -ExitCode 69811}
            If ($BackupPath.length -gt $maxpathsize) {Exit-Script -ExitCode 69812}  		}
		Show-InstallationWelcome -CloseApps 'UFT' -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt; Show-InstallationProgress
        Copy-Item "C:\Program Files (x86)\HP\Unified Functional Testing\Tests\*.*" "C:\temp\UFT" -Recurse -Force -ErrorAction SilentlyContinue ## Backup Tests
        Copy-Item "C:\Program Files (x86)\Micro Focus\Unified Functional Testing\Tests\*.*" "C:\temp\UFT" -Recurse -Force -ErrorAction SilentlyContinue ## Backup Tests
		##* INSTALLATION 		##*===============================================
		[string]$installPhase = 'Installation'
		Start-Process "$dirfiles\UFT_One_15.0.1_DVD\Unified Functional Testing\EN\setup.exe" -ArgumentList "/InstallOnlyPrerequisite /s" -NoNewWindow -PassThru -Wait
        Execute-MSI -Action Install -Path "$dirfiles\UFT_One_15.0.1_DVD\Unified Functional Testing\MSI\Unified_Functional_Testing_x64.msi" -Parameters "REBOOT=REALLYSUPPRESS ADDLOCAL=IDE,Core_Components,Samples,Test_Results_Viewer,ActiveX_Add_in,Add_ins,Visual_Basic_Add_in,Web_Add_in,Delphi_Add_in,Flex_Add_in,Java_Add_in,Silverlight_Add_in,_Net_Add_in,WPF_Add_in,Oracle_Add_in,PeopleSoft_Add_in,PowerBuilder_Add_in,Qt_Add_in,SAP_Solutions_Add_in,Stingray_Add_in,TE_Add_in,VisualAge_Add_in LICSVR=louappwps244 /qn"
		##* POST-INSTALLATION		##*===============================================
		[string]$installPhase = 'Post-Installation'
        if ($NoPathChk -eq $false) {$newPath = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
            If ($newPath.length -lt 10) {Exit-Script -ExitCode 69813}}
		Show-InstallationPrompt -Message "Installation of $installTitle is complete. You need to reboot to complete the install!" -ButtonRightText 'OK' -Icon Information -NoWait
	}	ElseIf ($deploymentType -ieq 'Uninstall')	{
		##* PRE-UNINSTALLATION		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		Show-InstallationWelcome -CloseApps 'UFT' -CloseAppsCountdown 60;Show-InstallationProgress
        Copy-Item "C:\Program Files (x86)\Micro Focus\Unified Functional Testing\Tests\*.*" "C:\temp\UFT" -Recurse -Force -ErrorAction SilentlyContinue ## Backup Tests
		##* UNINSTALLATION		##*===============================================
		[string]$installPhase = 'Uninstallation'
        Execute-MSI -Action Uninstall -Path "$dirfiles\UFT_One_15.0.1_DVD\Unified Functional Testing\MSI\Unified_Functional_Testing_x64.msi" -Parameters "REBOOT=REALLYSUPPRESS /qn"
		If (Test-Path "C:\Program Files (x86)\Micro Focus\Unified Functional Testing") {Remove-Item "C:\Program Files (x86)\Micro Focus\Unified Functional Testing" -Recurse -Force}
		##* POST-UNINSTALLATION		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'
		Show-InstallationPrompt -Message "Uninstallation of $installTitle is complete. You need to reboot to complete the uninstall!" -ButtonRightText 'OK' -Icon Information -NoWait
	}
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}