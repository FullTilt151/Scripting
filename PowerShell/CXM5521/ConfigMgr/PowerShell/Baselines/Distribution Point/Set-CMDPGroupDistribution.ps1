#region Identify packages not distributed to all DP detection/remediation
#region variables
# flip this boolean based on if this will be your detection or remediation script
$Remediate = $true

# Log related variables, boolean for enabling logs, filepath, and filename
$Logging = $true
$LogPath = "$env:SystemDrive\temp"
$LogFile = 'Set-CMDPGroupDistribution.log'

$sccmConnectionInfo = Get-CMNSCCMConnectionInfo -siteServer $env:COMPUTERNAME
$dbCon = Get-CMNConnectionString -DatabaseServer $sccmConnectionInfo.SCCMDBServer -Database $sccmConnectionInfo.SCCMDB
$SiteCode = $sccmConnectionInfo.SiteCode
#endregion variables

#region functions
Function Write-CMLogEntry {
    <#
    .DESCRIPTION
        Write CMTrace friendly log files with options for log rotation
    .EXAMPLE
        $Bias = Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias
        $FileName = "myscript_" + (Get-Date -Format 'yyyy-MM-dd_HH-mm-ss') + ".log"
        Write-CMLogEntry -Value "Writing text to log file" -Severity 1 -Component "Some component name" -FileName $FileName -Folder "C:\Windows\temp" -Bias $Bias -Enable -MaxLogFileSize 1MB -MaxNumOfRotatedLogs 3
    #>
    param (
        [parameter(Mandatory = $true, HelpMessage = 'Value added to the log file.')]
        [ValidateNotNullOrEmpty()]
        [string]$Value,
        [parameter(Mandatory = $false, HelpMessage = 'Severity for the log entry. 1 for Informational, 2 for Warning and 3 for Error.')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('1', '2', '3')]
        [string]$Severity = 1,
        [parameter(Mandatory = $false, HelpMessage = "Stage that the log entry is occuring in, log refers to as 'component'.")]
        [ValidateNotNullOrEmpty()]
        [string]$Component,
        [parameter(Mandatory = $true, HelpMessage = 'Name of the log file that the entry will written to.')]
        [ValidateNotNullOrEmpty()]
        [string]$FileName,
        [parameter(Mandatory = $true, HelpMessage = 'Path to the folder where the log will be stored.')]
        [ValidateNotNullOrEmpty()]
        [string]$Folder,
        [parameter(Mandatory = $false, HelpMessage = 'Set timezone Bias to ensure timestamps are accurate.')]
        [ValidateNotNullOrEmpty()]
        [int32]$Bias,
        [parameter(Mandatory = $false, HelpMessage = 'Maximum size of log file before it rolls over. Set to 0 to disable log rotation.')]
        [ValidateNotNullOrEmpty()]
        [int32]$MaxLogFileSize = 5MB,
        [parameter(Mandatory = $false, HelpMessage = 'Maximum number of rotated log files to keep. Set to 0 for unlimited rotated log files.')]
        [ValidateNotNullOrEmpty()]
        [int32]$MaxNumOfRotatedLogs = 0,
        [parameter(Mandatory = $false, HelpMessage = 'A switch that enables the use of this function.')]
        [ValidateNotNullOrEmpty()]
        [switch]$Enable
    )
    If ($Enable) {
        # Determine log file location
        $LogFilePath = Join-Path -Path $Folder -ChildPath $FileName

        If ((([System.IO.FileInfo]$LogFilePath).Exists) -And ($MaxLogFileSize -ne 0)) {

            # Get log size in bytes
            $LogFileSize = [System.IO.FileInfo]$LogFilePath | Select-Object -ExpandProperty Length

            If ($LogFileSize -ge $MaxLogFileSize) {

                # Get log file name without extension
                $LogFileNameWithoutExt = $FileName -replace ([System.IO.Path]::GetExtension($FileName))

                # Get already rolled over logs
                $AllLogs = Get-ChildItem -Path $Folder -Name "$($LogFileNameWithoutExt)_*" -File

                # Sort them numerically (so the oldest is first in the list)
                $AllLogs = $AllLogs | Sort-Object -Descending { $_ -replace '_\d+\.lo_$' }, { [Int]($_ -replace '^.+\d_|\.lo_$') } -ErrorAction Ignore
            
                ForEach ($Log in $AllLogs) {
                    # Get log number
                    $LogFileNumber = [int32][Regex]::Matches($Log, "_([0-9]+)\.lo_$").Groups[1].Value
                    switch (($LogFileNumber -eq $MaxNumOfRotatedLogs) -And ($MaxNumOfRotatedLogs -ne 0)) {
                        $true {
                            # Delete log if it breaches $MaxNumOfRotatedLogs parameter value
                            [System.IO.File]::Delete("$($Folder)\$($Log)")
                        }
                        $false {
                            # Rename log to +1
                            $NewFileName = $Log -replace "_([0-9]+)\.lo_$", "_$($LogFileNumber+1).lo_"
                            [System.IO.File]::Copy("$($Folder)\$($Log)", "$($Folder)\$($NewFileName)", $true)
                        }
                    }
                }

                # Copy main log to _1.lo_
                [System.IO.File]::Copy($LogFilePath, "$($Folder)\$($LogFileNameWithoutExt)_1.lo_", $true)

                # Blank the main log
                $StreamWriter = New-Object -TypeName System.IO.StreamWriter -ArgumentList $LogFilePath, $false
                $StreamWriter.Close()
            }
        }

        # Construct time stamp for log entry
        switch -regex ($Bias) {
            '-' {
                $Time = [string]::Concat($(Get-Date -Format 'HH:mm:ss.fff'), $Bias)
            }
            Default {
                $Time = [string]::Concat($(Get-Date -Format 'HH:mm:ss.fff'), '+', $Bias)
            }
        }
        # Construct date for log entry
        $Date = (Get-Date -Format 'MM-dd-yyyy')
    
        # Construct context for log entry
        $Context = $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
    
        # Construct final log entry
        $LogText = [string]::Format('<![LOG[{0}]LOG]!><time="{1}" date="{2}" component="{3}" context="{4}" type="{5}" thread="{6}" file="">', $Value, $Time, $Date, $Component, $Context, $Severity, $PID)
    
        # Add value to log file
        try {
            $StreamWriter = New-Object -TypeName System.IO.StreamWriter -ArgumentList $LogFilePath, 'Append'
            $StreamWriter.WriteLine($LogText)
            $StreamWriter.Close()
        }
        catch [System.Exception] {
            Write-Warning -Message "Unable to append log entry to $FileName file. Error message: $($_.Exception.Message)"
        }
    }
}
#endregion functions

#region set function defaults
$Component = switch ($Remediate) {
    $true {
        'Remediation'
    }
    $false {
        'Detection'
    }
}

$Bias = Get-WmiObject -Class Win32_TimeZone | Select-Object -ExpandProperty Bias
$PSDefaultParameterValues["Write-CMLogEntry:Bias"] = $Bias
$PSDefaultParameterValues["Write-CMLogEntry:Component"] = $Component
$PSDefaultParameterValues["Write-CMLogEntry:FileName"] = $LogFile
$PSDefaultParameterValues["Write-CMLogEntry:Folder"] = $LogPath
$PSDefaultParameterValues["Write-CMLogEntry:MaxLogFileSize"] = 1MB
$PSDefaultParameterValues["Write-CMLogEntry:MaxNumOfRotatedLogs"] = 2
$PSDefaultParameterValues["Write-CMLogEntry:Enable"] = $Logging
#endregion set function defaults

#region Identify packages not distributed to all DP
Write-CMLogEntry -Value $('-' * 50)
Write-CMLogEntry -Value "Configuration Manager Package Distribution Validation to DP Group $Component started"

$FindAllDPsGroup_Query = @"
SELECT TOP 1 Name
    , GroupID
    , MemberCount
FROM v_SMS_DistributionPointGroup 
ORDER BY MemberCount DESC
"@
$AllDPsGroup = Get-CMNDatabaseData -connectionString $dbCon -query $FindAllDPsGroup_Query -isSQLServer
Write-CMLogEntry "Identified the All DPs group [Name = '$($AllDPsGroup.Name)'] [MemberCount = '$($AllDPsGroup.MemberCount)'] [GroupID = '$($AllDPsGroup.GroupID)']"

$DP_PackageCountQuery = @"
SELECT DISTINCT p.PackageID
	, p.packagetype
FROM v_package p
    LEFT JOIN v_DPGroupPackages dpgp ON dpgp.PkgID = p.packageid
    LEFT JOIN v_ContDistStatSummary cdss ON cdss.PkgID = p.PackageID
WHERE 
    (p.PackageID NOT IN (
	SELECT DISTINCT PkgID
    FROM v_DPGroupPackages
    WHERE groupid = '$($AllDPsGroup.GroupID)') 
    AND cdss.TargeteddDPCount != 0
    AND p.Name NOT LIKE 'Configuration Manager Client%Package'
)
"@
try {
    $PackageToProcess = Get-CMNDatabaseData -connectionString $dbCon -query $DP_PackageCountQuery -isSQLServer | Select-Object -Property PackageID, PackageType
    $DP_PackageCount = $PackageToProcess | Measure-Object | Select-Object -ExpandProperty Count
}
catch {
}

Write-CMLogEntry "Identified [PackageCount = '$DP_PackageCount'] that are not distributed to All DPs"

switch ($DP_PackageCount) {
    0 {
        $Compliant = $true
    }
    default {
        switch ($Remediate) {
            $true {
                $initParams = @{ }
                if ((Get-Module ConfigurationManager) -eq $null) {
                    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
                }
                
                # Connect to the site's drive if it is not already present
                if ((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
                    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $env:COMPUTERNAME @initParams
                }
                
                # Set the current location to be the site code.
                Set-Location "$($SiteCode):\" @initParams
                
                $FailedToDistribute = 0
                foreach ($Package in $PackageToProcess) {
                    $PackageType = $Package | Select-Object -ExpandProperty PackageType
                    $PackageID = $Package | Select-Object -ExpandProperty PackageID
                    $ContentTypes = @{
                        0   = 'PackageId'
                        3   = 'DriverPackageId'
                        4   = 'TaskSequenceId'
                        5   = 'DeploymentPackageId'
                        8   = 'ApplicationId'
                        257 = 'OperatingSystemImageId'
                        258 = 'BootImageID'
                        259 = 'OperatingSystemInstallerId'
                    }
                    $ContentDistributionParams = @{
                        DistributionPointGroupName     = $($AllDPsGroup.Name)
                        $ContentTypes[$($PackageType)] = $PackageID
                        ErrorAction                    = 'Stop'
                    }
                    try {
                        Write-CMLogEntry "Distributing [PackageID = '$PackageID'] to [DPGroup = '$($AllDPsGroup.Name)']"
                        Start-CMContentDistribution @ContentDistributionParams
                    }
                    catch {
                        $FailedToDistribute++
                        Write-CMLogEntry "Failed to distribute [PackageID = '$PackageID'] to [DPGroup = '$($AllDPsGroup.Name)']" -Severity 3
                    }
                }
                switch ($FailedToDistribute) {
                    0 {
                        $Compliant = $true
                    }
                    default {
                        $Compliant = $false
                    }
                }
            }
            $false {
                $Compliant = $false
            }
        }
    }
}
Write-CMLogEntry -Value "Script finished with [Compliant = '$Compliant']"
Write-CMLogEntry -Value $('-' * 50)
#endregion Identify packages not distributed to all DP

return $Compliant
#endregion Identify packages not distributed to all DP detection/remediation