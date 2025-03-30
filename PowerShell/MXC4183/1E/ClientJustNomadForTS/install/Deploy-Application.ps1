<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows. 
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details. 
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	This script only installs the Nomad piece. This is for the TS step.
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
	[Parameter(Mandatory = $false)]
	[ValidateSet('Install', 'Uninstall')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory = $false)]
	[ValidateSet('Interactive', 'Silent', 'NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory = $false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory = $false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory = $false)]
	[switch]$NoPathChk = $false,
	[Parameter(Mandatory = $false)]
	[switch]$DisableLogging = $false,
	[Parameter(Mandatory = $false)]
	[ValidateSet('phys', 'vm', 'pxe', 'dp', 'ts')]
	[string]$InstallType
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch { }
	
	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = '1E'
	[string]$appName = 'Client'
	[string]$appVersion = '5.0'
	[string]$appArch = 'x64'
	[string]$appLang = 'EN'
	[string]$appRevision = '01'
	[string]$appScriptVersion = '1.0.0'
	[string]$appScriptDate = '7/2/2020'
	[string]$appScriptAuthor = 'Mike Cook'
	[string]$CR = 'na'
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
		If ($mainExitCode -eq 0) { [int32]$mainExitCode = 60008 }
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
				If ($Hotfix -ne $null) { $maxpathsize = 3500 } else { $maxpathsize = 2000 }
			}
			Else { $maxpathsize = 4000 }
			If ($BackupPath.length -lt 32) { Exit-Script -ExitCode 69811 }
			If ($BackupPath.length -gt $maxpathsize) { Exit-Script -ExitCode 69812 }   
		}

		
		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		#Show-InstallationWelcome -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt # replace 'xyz123' with the app you're installing.  Weird bug that requires this or the script will crash.
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Installation tasks here>
		#Common parameters used by all installs.
		$params = @(
			"/qn",
			"Switch=none",
			"BackgroundChannelUrl=none",
			"MODULE.INVENTORY.ENABLED=false",
			"MODULE.WAKEUP.ENABLED=false"
		)

		$InstallParams = switch ($InstallType) {
			'phys'{
				"$params",
				"MODULE.NOMAD.ENABLED=true",
				"MODULE.SHOPPING.ENABLED=true",
				"MODULE.SHOPPING.SHOPPINGCENTRALURL=http://appshop.humana.com/Shopping/",
				"MODULE.SHOPPING.LOOPBACKEXEMPTIONENABLED=true",
				"MODULE.NOMAD.CONTENTREGISTRATION=1",
				"MODULE.NOMAD.LOGPATH=C:\Windows\CCM\Logs",
				"MODULE.NOMAD.MAXALLOCREQUEST=61440",
				"MODULE.NOMAD.MAXIMUMMEGABYTE=61440",
				"MODULE.NOMAD.MULTICASTSUPPORT=0",
				"MODULE.NOMAD.PERCENTAVAILABLEDISK=3",
				"MODULE.NOMAD.SPECIALNETSHARE=8256",
				"MODULE.NOMAD.SSDENABLED=3",
				"MODULE.NOMAD.CACHEPATH=C:\ProgramData\1E\NomadBranch\",
				"MODULE.NOMAD.SSPBAENABLED=0"
                "MODULE.NOMAD.CACHECLEANCYCLEHRS=168",
			    "MODULE.NOMAD.COMPATIBILITYFLAGS=1572864",
			    "MODULE.NOMAD.MAXCACHEDAYS=60",
			    "MODULE.NOMAD.MAXPRECACHEDAYS=0",
			    "MODULE.NOMAD.MAXSUCACHEDAYS=60",
			    "MODULE.NOMAD.MAXLOGSIZE=5242880",
			    "MODULE.NOMAD.NOMADINHIBITEDSUBNETS=`"133.17.0.0/16,10.94.0.0/16,133.200.0.0/16,133.201.0.0/16,193.65.240.0/23,193.65.242.0/23,193.201.14.0/23,193.201.16.0/23,193.201.18.0/23,193.201.20.0/23,193.201.22.0/23,193.201.24.0/23,193.201.10.0/23,193.201.12.0/23,193.193.2.0/23,193.193.1.0/23,10.52.0.0/14,10.60.0.0/14`"",
			    "MODULE.NOMAD.P2PENABLED=9",
			    "MODULE.NOMAD.PLATFORMURL=http://ActiveEfficiency.humana.com/ActiveEfficiency",
			    "MODULE.NOMAD.SUCCESSCODES=0x206b,0x2077,0x103,0xffffffff,0x1,0x70,0x2050,0x2051,0x2052,0x2053,0x2054,0x2055,0x2056,0x2057,0x2058,0x205a,0x205b,0x205c,0x205d,0x205e,0x2060,0x2061,0x2062,0x2063,0x2064,0x2065,0x2066,0x2067,0x2068,0x2069,0x9999"         
			}

			'vm'{
				"$params",
				"MODULE.NOMAD.ENABLED=false",
				"MODULE.SHOPPING.ENABLED=true",
				"MODULE.SHOPPING.SHOPPINGCENTRALURL=http://appshop.humana.com/Shopping/",
				"MODULE.SHOPPING.LOOPBACKEXEMPTIONENABLED=true"
			}

			'pxe'{
				"$params",
				"Module.Nomad.Enabled=true",
				"MODULE.SHOPPING.ENABLED=true",
				"MODULE.SHOPPING.SHOPPINGCENTRALURL=http://appshop.humana.com/Shopping/",
				"MODULE.SHOPPING.LOOPBACKEXEMPTIONENABLED=true",
				"MODULE.NOMAD.CONTENTREGISTRATION=1",
				"MODULE.NOMAD.LOGPATH=C:\Windows\CCM\Logs",
				"MODULE.NOMAD.MAXALLOCREQUEST=61440",
				"MODULE.NOMAD.MAXIMUMMEGABYTE=61440",
				"MODULE.NOMAD.MULTICASTSUPPORT=0",
				"MODULE.NOMAD.PERCENTAVAILABLEDISK=3",
				"MODULE.NOMAD.SPECIALNETSHARE=8256",
				"MODULE.NOMAD.SSDENABLED=3",
				"MODULE.NOMAD.CACHEPATH=F:\NomadCache",
				"MODULE.NOMAD.SSPBAENABLED=0"			
			}

			'dp'{
				"$params",
				"Module.Nomad.Enabled=true",
				"MODULE.NOMAD.INSTALLDIR=""D:\Program Files\1E\NomadBranch""",
				"MODULE.NOMAD.LOGPATH=D:\SMS_CCM\Logs",
				"MODULE.NOMAD.CACHEPATH=C:\ProgramData\1E\NomadBranch\",
				"MODULE.NOMAD.MULTICASTSUPPORT=0"
			}

			'ts'{
				"$params",
				"MODULE.NOMAD.ENABLED=true",
				"MODULE.SHOPPING.ENABLED=false",
				"MODULE.NOMAD.LOGPATH=C:\Windows\CCM\Logs",
				"MODULE.NOMAD.MAXLOGSIZE=5242880",
				"MODULE.NOMAD.MULTICASTSUPPORT=0",
				"MODULE.NOMAD.SSDENABLED=3",
				"MODULE.NOMAD.COMPATIBILITYFLAGS=1572866"
			}
		}                

		##*===============================================
		##* INSTALLATION 
		##*===============================================
		[string]$installPhase = 'Installation'
		
		## Handle Zero-Config MSI Installations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
		}
		
		## <Perform Installation tasks here>
		Execute-MSI -action 'Install' -path "1E.Client-x64.msi" -parameters ($InstallParams -join ' ')
		
		
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'

		## Path Check Pt2
		if ($NoPathChk -eq $false) {
			## Did your install nuke the path?
			$newPath = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment' -Name path).path
			If ($newPath.length -lt 10) { Exit-Script -ExitCode 69813 }
		}
		
		## <Perform Post-Installation tasks here>
		   Execute-MSI -Action Patch -path "Q21021-1e.client-x64.v5.0.0.745.msp" -parameters "/qn REINSTALLMODE=os REBOOT=REALLYSUPPRESS"

		# Additional settings from the 'Set NomadBranch configuration' step in the TS.
		& {New-Item "c:\ProgramData\1e\NomadBranch\SKPSWI.DAT" -type File -Force}
		& {(get-item c:\programdata\1e\NomadBranch\SKPSWI.DAT).attributes='Hidden'}
		netsh advfirewall firewall set rule name="NomadBranch.exe" new profile=any
		netsh advfirewall firewall set rule name="NomadPackageLocator.exe" new profile=any
		netsh advfirewall firewall set rule name="PackageStatusRequest.exe" new profile=any

		   
		
		## Display a message at the end of the install
		If (-not $useDefaultMsi) { Show-InstallationPrompt -Message "Installation of $installTitle is complete you may need to reboot to finalize the install." -ButtonRightText 'OK' -Icon Information -NoWait }
	}
	ElseIf ($deploymentType -ieq 'Uninstall') {
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'
		
		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'xyz123' -CloseAppsCountdown 60 # replace 'xyz123' with the app you're installing.  Weird bug that requires this or the script will crash.
		
		## Show Progress Message (with the default message)
		Show-InstallationProgress
		
		## <Perform Pre-Uninstallation tasks here>
		
		
		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'
		
		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat = @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}
		
		# <Perform Uninstallation tasks here>
        Execute-MSI -Action Uninstall -Path '{A0F543C5-E9DD-4345-9B74-D133A207833E}'
    
        <# Stop Nomad service before uninstalling and reinstalling (to fix PXE boxes)
        $NB = Get-Service -name "NomadBranch"
			If($NB.Status -eq 'Running'){
				Stop-Process -Name NomadBranch -Force -ErrorAction Continue
				Stop-Service -Name NomadBranch -Force -ErrorAction Continue
				Execute-MSI -Action Uninstall -Path '{BF6F5FA9-64C8-4B72-A6B6-14A582BF96B8}'
        }
			elseif
				($nb.Status -eq 'Stopped'){
				Execute-MSI -Action Uninstall -Path '{BF6F5FA9-64C8-4B72-A6B6-14A582BF96B8}'
        }
        #>
		
	

		
		
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
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}