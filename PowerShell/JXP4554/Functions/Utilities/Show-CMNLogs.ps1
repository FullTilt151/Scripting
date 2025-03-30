Function Show-CMNLogs {
    <#
	    .SYNOPSIS
		    Opens logfiles using CMTrace for particular activity

	    .DESCRIPTION
		    You specify what activity you want to view logs for, this will open CMtrace showing those log files.
            This script assumes you have CMTrace in the directory you are in or in your path

	    .PARAMETER computerName
            Name of computer you want to view the logs for, defaults to localhost

        .PARAMETER activity
            Activity you are interested in, default is Default. Available values are:
                Default
                ClientDeployment
                ClientInventory
                Updates

	    .EXAMPLE
            Show-CMNLogs -computerName Computer1 -logs ClientDeployment
	    .LINK
		    http://configman-notes.com

	    .NOTES
		    Author:	Jim Parris
		    Email:	Jim@ConfigMan-Notes
		    Date:	2/1/2017
		    PSVer:	2.0/3.0
    #>

    [cmdletbinding()]
    PARAM
    (
        [Parameter(Mandatory = $false,
            HelpMessage = 'Computer name')]
        [ValidateScript( {Test-Connection -ComputerName $_ -Count 1 -Quiet})]
        [String]$computerName = 'localHost',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Logs to look at')]
        [ValidateSet('Default', 'Application', 'ClientDeployment', 'ClientInventory', 'Updates', 'DCM', 'Schedule')]
        [String]$activity = 'Default'
    )
    #Hash table for log lists
    $sccmLogs = @{
        Default = ('CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
        Application = ('AppDiscovery.log', 'AppEnforce.log', 'CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
        ClientDeployment = ('ContentTransferManager.log', 'DataTransferService.log', 'LocationServices.log', 'ClientLocation.log', 'NomadBranch.log', 'ClientIDManagerStartup.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        ClientInventory = ('InventoryProvider.log', 'InventoryAgent.log', 'NomadBranch.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        Updates = ('CIDownloader.log', 'DataTransferService.log', 'ContentTransferManager.log', 'CAS.log', 'Scheduler.log', 'ServiceWindowManager.log', 'WUAhandler.log', 'UpdatesDeployment.log', 'ScanAgent.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        DCM = ('CIAgent.log', 'DCMWMIProvider.log', 'DCMAgent.log', 'DCMReporting.log', 'PolicyAgent.log', 'CCMExec.log', 'ExecMgr.log');
        Schedule = ('ServiceWindowManager.log', 'Scheduler.log', 'CAS.log', 'NomadBranch.log', 'PolicyAgent.log', 'ccmexec.log', 'execmgr.log');
    }

    $nonSCCMLogs = @{
        ClientDeployment = ('\\ComputerName\C$\Windows\CCMSetup\Logs\CCMSetup.log', '\\ComputerName\C$\temp\Software_Install_Logs\System Center Configuration Manager (SCCM) Client_PSAppDeployToolkit_Install.log', '\\ComputerName\C$\temp\Software_Install_Logs\System Center Configuration Manager (SCCM) Client_PSAppDeployToolkit_Uninstall.log');
        Updates = ('\\ComputerName\C$\Windows\WindowsUpdate.log');
    }

    #Make sure we have a good computername
    if ($computerName -eq 'localhost') {$computerName = $env:COMPUTERNAME}

    #get log base directory from registry
    $key = 'SOFTWARE\\Microsoft\\CCM\\Logging\\@Global'
    $Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computerName)
    $RegKey = $Reg.OpenSubKey($key)
    $ccmLogDir = $RegKey.GetValue("LogDirectory")
    #"(?<pre>.*)st",'${pre}ar'
    $ccmLogDir -match '(.):\\(.*)' | Out-Null
    $ccmLogDir = "\\$computerName\$($Matches[1])$\$($Matches[2])"

    #Time to build the command
    $command = 'CMTrace'

    #Add the Non-SCCM logs first
    foreach ($log in $nonSCCMLogs[$activity]) {
        $line = $log -replace 'ComputerName', $computerName
        $command = "$command ""$line"""
    }

    foreach ($log in $sccmLogs[$activity]) {
        $command = "$command ""$ccmLogDir\$log"""
    }

    Invoke-Expression -Command $command
} # End Show-CMNLogs
