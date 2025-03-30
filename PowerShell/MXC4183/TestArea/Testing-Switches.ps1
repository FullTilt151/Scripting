[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall','Repair')]
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
	[switch]$DisableLogging = $false,
	[Parameter(Mandatory=$true)]
	[ValidateSet('VS2017Ent','VS2017Pro','VS2019Ent','VS2019Pro','Nuke')]
	[string]$Version = $Version
)

if($version -eq 'VS2017Ent'){
    Write-Host $Version
}
elseif($version -eq 'VS2017Pro'){
    Write-host "This is the Else if $version"
}
elseif($version -eq 'VS2019Ent'){
    Write-host "This is the 2nd Else if $version"
}
elseif($version -eq 'VS2019Pro'){
    Write-host "This is the 3rd Else if $version"
}
elseif($version -eq 'Nuke'){
    Write-host "Nuke it from orbit!"
}