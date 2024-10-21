<#
.SYNOPSIS
 
.DESCRIPTION
    This script opens the SCCM install logs on servers.

.PARAMETER 
    -ServerName

.Example
    Openlog.ps1 -ServerName <server>
#>

[CmdletBinding()]	
PARAM 
(
    [Parameter(Mandatory=$True)]
	[String]$Server

)

# Open appropriate logs.
cmtrace "\\$Server\c$\windows\ccmsetup\logs\ccmsetup.log" , "\\$server\c$\temp\Software_Install_Logs\System Center Configuration Manager (SCCM) Client_PSAppDeployToolkit_Install.log" , "\\$server\c$\windows\ccm\logs\policyagent.log" , "\\$server\c$\windows\ccm\logs\ccmexec.log"
