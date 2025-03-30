<#
.SYNOPSIS
1E Nomad Package Enablement - Version 1.2
Copyright © 1e Ltd 2021 - all rights reserved
http://www.1e.com
 
Author: John DeVito
 
Your use of this software is at your sole risk. All software is provided "as -is", without any warranty, whether express or implied, of accuracy, completeness,
fitness for a particular purpose, title or non-infringement, and none of the software is supported or guaranteed by 1E. 1E shall not be liable for any damages
you may sustain by using this software, whether direct, indirect, special, incidental or consequential, even if it has been advised of the possibility of such
damages.
 
This intellectual property script (“IP”) is the property of 1E, Inc. and its subsidiaries (the “Company”) and is strictly confidential. It contains information
intended only for the agents of, or person(s) representing the customer (the “Recipient”) to whom it is transmitted. With receipt of this IP, recipient
acknowledges and agrees that: (i) this IP is covered, in whole or in part, by the existing mutual non-disclosure agreement (“NDA”) between the company and recipient
(ii) this IP is not intended to be distributed, and if distributed inadvertently, will be returned to the Company as soon as possible; (iii) the recipient will not
copy, reproduce, divulge, or distribute this confidential information, in whole or in part, without the express written consent of the Company; (iiii) all of the
information herein will be treated as confidential material with no less care than that afforded to its own confidential material.
 
Use of this software implies agreement to these terms.
 
.DESCRIPTION
 
This script is used to set the ACP value of ConfigMgr packages to use Nomad.
 
.PARAMETER CachePriority
Optional parameter.  The value specifies the value of the Cache Priority setting in the Nomad properties dialog.  If this parameter is not specified it will set
the Cache Priority value to 1.  This value indicates the priority of downloaded content in cache and should not be confused with the Priority parameter.  A package
with a lower Cache Priority value will be removed from cache by the cache cleaner before packages with higher Cache Priority values.  Valid values are 0 - 4.
 
.PARAMETER DebugLevel
Optional parameter.  The value specifies the --debug value in the Additional Settings used by logging of the associated content transfer.  If this value is not set
the parameter is not added to Additional Settings and the default logging value of 9 will be used by Nomad during file transfer.  Valid values are:
 
1 - Minimal Logging
9 - Default Logging
25 - Detailed Logging
 
.PARAMETER FullLogPath
Optional parameter.  The value specifies the full path for the log file.  If this parameter is not specified it will use the tool name as
the root of the log file name and will write the log into a default location of C:\ProgramData.
 
.PARAMETER InputFile
Optional parameter.  The name of the input file which contains the list of packages to be Nomad enabled.  The file should be referenced using the full path and
appear with one package ID per line as follows:
 
LAB00009
LAB00007
LAB000BC
 
*********  IMPORTANT: Either the InputFile or ListPackage parameter must be specified or the script will exit before attempting to process any packages *********
 
.PARAMETER KeepCache
Optional parameter.  This parameter should not be used.  It is no longer documented and is retained for backwards compatibility.
 
.PARAMETER ListPackage
Optional parameter.  This parameter allows a test package or packages to be supplied at runtime.  You may also provide the value of ALL to process all packages.
If processing all packages you must specify ALL in all upper case letters or the script will exit.  When providing packages, a single package can be set with
-ListPackage LAB00009.  Multiple packages can be provided a a comma separated list and must be enclosed on quotes, as follows: -ListPackage "LAB00009,LAB0000F".
 
.PARAMETER MaxLogging
Optional parameter.  Specifies to use the maximum level of logging.
 
.PARAMETER MaxLogSizeKB
Optional parameter.  The value specifies the maximum size of the log file before it is rolled over to a backup log file and restarted. The
default value is 2048 (2MB).
 
.PARAMETER MaxLogRollovers
Optional parameter.  The value specifies the maximum number of rollover log files to create. They are purged in a FIFO type method when the
maximum number is exceeded.  The default value is 1.
 
.PARAMETER MobileConnections
Optional parameter.  This parameter should not be used.  It is no longer documented and is retained for backwards compatibility.
 
.PARAMETER Multicast
Optional parameter.  This parameter selects the Local Multicast checkbox in the Nomad Properties dialog.  It enables multicast distribution
after the content has already been downloaded.  Multicast is not supported in Nomad 7.1.  The value to enable multicast is "Yes".
 
.PARAMETER NomadEval
Optional switch.  When Selected, this switch specifies that you wish to create two output files, one of packages that are Nomad Enabled, one NomadEnabled.txt
for packages with Nomad enabled and the other NomadDisabled.txt for packages that do not have Nomad enabled.  No changes are made to packages when this
switch has been provided.
 
.PARAMETER Priority
Optional parameter.  This parameter should not be confused with Cache Priority.  It specifies the download priority of the package.  A package with a lower
priority will be downloaded before a package with a higher priority.  It specifies the ++pr value in the Additional Settings section of Nomad Properties.
Valid values are 0 - 4.
 
.PARAMETER StatusMessages
Optional parameter.  This parameter sets the ++sm value in the Addition Settings section of Nomad Properties.  It specifies the frequency of reporting to ConfigMgr
via the percentage of content downloaded.  Valid values are 1 - 99.
 
.PARAMETER ToolName
Optional parameter.  The value specifies the name of the tool which is used in the default Log file name and also appears in the Component
column of the log file.  The default tool name is Create-ManagementGroups.
 
.PARAMETER WhatIf
Optional switch.  When defined, packages will be logged, but no changes will be made.
 
.PARAMETER KeepCache
Optional parameter.  This parameter should not be used.  It is no longer documented and is retained for backwards compatibility.
 
.PARAMETER WorkRate
Optional parameter.  This parameter sets the Work Rate value in the Nomad Properties dialog.
 
.PARAMETER WorkRateOverride
Optional parameter.  This parameter selects the Override Intra-Day Work Rate checkbox in the Nomad Properties dialog.
 
.EXAMPLE
.\Create-ManagementGroups.ps1 -SQLServer LABSQL\TACH4 -InputFile Collections.txt -CMDBServer LABSQL -CMDBName CM_LAB -TachyonAPI tachyon.lab.int
 
A Tachyon 4.1 server is accessed using URL https://tachyon.lab.int/Tachyon.  The ConfigMgr database with the collection information we are using is named CM_LAB and
is on the server LABSQL.  The related Tachyon databases are on a server named LABSQL in an instance named TACH4.  The file containing the list of collections to
process is in the same directory as the script and is named Collections.txt.  The Tachyon API will run the Management Group Evaluation report against the Default
Inventory repository.  If a machine does not exist in the Tachyon device inventory it will not be added to the Management Group Rules.
#>
 
Param(
    [Parameter(Mandatory=$False)]
    [string]$CachePriority,
    [Parameter(Mandatory=$False)]
    [string]$DebugLevel,
    [Parameter(Mandatory=$False)]
    [string]$FullLogPath,
    [Parameter(Mandatory=$False)]
    [string]$InputFile,
    [Parameter(Mandatory=$False)]
    [string]$KeepCache,
    [Parameter(Mandatory=$False)]
    [string]$ListPackage,
    [Parameter(Mandatory=$False)]
    [switch]$MaxLogging,
    [Parameter(Mandatory=$False)]
    [int]$MaxLogRollovers,
    [Parameter(Mandatory=$False)]
    [int]$MaxLogSizeKB,
    [Parameter(Mandatory=$False)]
    [string]$MobileConnections,
    [Parameter(Mandatory=$False)]
    [string]$Multicast,
    [Parameter(Mandatory=$False)]
    [switch]$NomadEval,
    [Parameter(Mandatory=$False)]
    [string]$Priority,
    [Parameter(Mandatory=$False)]
    [int]$StatusMessages,
    [Parameter(Mandatory=$False)]
    [string]$ToolName,
    [Parameter(Mandatory=$False)]
    [switch]$WhatIf,
    [Parameter(Mandatory=$False)]
    [string]$WorkRate,
    [Parameter(Mandatory=$False)]
    [string]$WorkRateOverride
    )
# End Parameter section
 
# This Function writes the log and is to be added to the code.  No need to change.
Function Add-LogEntry($LogFile, $LogEntry, $LogBasePath, $LogFileName, $LogRootName){
    $LogSizeKB = (Get-ChildItem -Path $LogBasePath -Filter $LogFileName | Select-Object -expandProperty Length) / 1024
    If ($LogSizeKB -gt $MaxLogSizeKB){
        # Check number of logs
        $LogFiles = Get-ChildItem -Path "$LogBasePath" -Filter "$LogRootName.*"
        $LogBakCount = ($LogFiles.Count) -1
        Write-Host -ForegroundColor Green "Log Backup File Count: $LogBakCount"
 
        If ($LogBakCount -ge ($MaxLogRollovers)){
            $LogIndex = $LogBakCount
            For ($LogIndex; $LogIndex -ge $MaxLogRollovers; $LogIndex--){
                Write-Host -ForegroundColor Green "Removing backup file: $LogBasePath\$LogFileName.$LogIndex."
                Remove-Item -Path "$LogBasePath\$LogFileName.$LogIndex"
                }
            }
 
        $LogIndex = $LogBakCount
        Write-Host -ForegroundColor Green "Log Index: $LogIndex"
 
        For ($LogIndex; $LogIndex -ge 0; $LogIndex--){
            Write-Host -ForegroundColor Green "Processing Log at index $LogIndex"
            $IncrementedLog = $LogIndex + 1
            If ($LogIndex -gt 0){
                If (Test-Path -Path $LogBasePath\$LogFileName.$LogIndex){
                    Write-Host -ForegroundColor Green "Renaming rollover log $LogBasePath\$LogFileName.$LogIndex as $LogBasePath\$LogFileName.$IncrementedLog"
                    Start-Sleep -Seconds 1
                    Rename-Item -Path "$LogBasePath\$LogFileName.$LogIndex" -NewName "$LogBasePath\$LogFileName.$IncrementedLog" -Force
                    }Else{
                    Write-Host -ForegroundColor Green "Rollover log $LogBasePath\$LogFileName.$LogIndex does not exist"
                    }
                }Else{
                If (Test-Path -Path $LogBasePath\$LogFileName){
                    Write-Host -ForegroundColor Green "Renaming base log $LogBasePath\$LogFileName as $LogBasePath\$LogFileName.$IncrementedLog"
                    Start-Sleep -Seconds 1
                    Rename-Item -Path "$LogBasePath\$LogFileName" -NewName "$LogBasePath\$LogFileName.1" -Force
                    }Else{
                    Write-Host -ForegroundColor Green "Rollover log $LogBasePath\$LogFileName does not exist"
                    }
                }
            }
        $NewLogHeader = "Log rolled over, starting new log..."
        $NewLogHeader | Out-File -FilePath $LogFile -Append -Encoding ascii
        Write-Host -ForegroundColor Green "Started new log file."
        $ScriptHash = Get-FileHash -Path "$PSCommandPath" | Select-Object -expandProperty Hash
        $Content = "[MAIN] Script Hash: " + $ScriptHash
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        }
    $Now = Get-Date -Format "ddd MMM dd HH:mm:ss.fff yyyy"
    If ($LogEntry -eq ""){
        $FullLogEntry = " "
        }Else{
        $FullLogEntry = $LogEntry + '  $$<' + $ToolName + '><' + $Now + '><0>'
        }
    Out-File -FilePath $LogFile -InputObject "$FullLogEntry" -Append -Encoding ascii
    }
# End the Log writing and rollover section
 
# ******************************************************* MAIN *************************************************************
# Here are the default values for the parameters shown above.
If (!$ToolName){
    $ToolName = "NomadEnable"
    }
If (!$FullLogPath){
    $FullLogPath = "C:\ProgramData\$ToolName.log"
    }
If (!$MaxLogSizeKB){
    [int]$MaxLogSizeKB = 2048
    }
If (!$MaxLogRollovers){
    [int]$MaxLogRollovers = 1
    }
If (!$CachePriority){
    $CachePriority = "1"
    }
If (!$DebugLevel){
    $DebugLevel = ""
    }
If (!$KeepCache){
    $KeepCache = ""
    }
If (!$MobileConnections){
    $MobileConnections = ""
    }
If (!$Multicast){
    $Multicast = ""
    }
If (!$Priority){
    $Priority = ""
    }
If (!$StatusMessages){
    $StatusMessages = "25"
    }
If (!$WorkRate){
    $WorkRate = ""
    }
If (!$WorkRateOverride){
    $WorkRateOverride = ""
    }
# End Default parameter values section
 
# Split the log path and the log name.  Place below the defaults.
$LogPath = $FullLogPath
$LogFileNameIn = ($FullLogPath.Split("\"))[-1]
$LogRootNameIn = ($LogFileNameIn.Split("."))[0]
$LogBasePathIn = $FullLogPath.Replace("\$LogFileNameIn", "")
# End of splits.
 
# Start the Log
If (Test-Path -Path $LogPath){
    $StartLog = " "
    $StartLog | Out-File -FilePath $LogPath -Append -Encoding ascii
    }
$StartLog = "Starting Nomad Enablement Log File..."
$StartLog | Out-File -FilePath $LogPath -Append -Encoding ascii
 
$ScriptVersion = "1.2" # ********************************************** Update the script version here
$Content = "Running Script Version: " + $ScriptVersion
Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
 
# To add the script hash to the logs.
$ScriptHash = Get-FileHash -Path "$PSCommandPath" | Select-Object -expandProperty Hash
$Content = "[MAIN] Script Hash: " + $ScriptHash
Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
 
# Build the AlternateContentProviders setting
$NomadSettings = "<AlternateDownloadSettings SchemaVersion=""1.0""><Provider Name=""NomadBranch""><Data>"
If ($WorkRate -ne ""){
    $NomadSettings = $NomadSettings + "<wr>" + $WorkRate + "</wr>"
    }
If ($WorkRateOverride -eq "Yes"){
    $NomadSettings = $NomadSettings + "<wro/>"
    }
If ($CachePriority -ne ""){
    $NomadSettings = $NomadSettings + "<pc>" + $CachePriority + "</pc>"
    }
If ($Multicast -eq "Yes"){
    $NomadSettings = $NomadSettings + "<mc/>"
    }
If ($DebugLevel -ne ""){
    $NomadSettings = $NomadSettings + "<debug>" + $DebugLevel + "</debug>"
    }
If ($MobileConnections -eq "Yes"){
    $NomadSettings = $NomadSettings + "<mobok/>"
    }
$NomadSettings = $NomadSettings + "<ProviderSettings>"
If ($StatusMessages -ne ""){
    $NomadSettings = $NomadSettings + "<sm>" + $StatusMessages + "</sm>"
    }
If ($Priority -ne ""){
    $NomadSettings = $NomadSettings + "<pr>" + $Priority + "</pr>"
    }
$NomadSettings = $NomadSettings + "</ProviderSettings></Data></Provider></AlternateDownloadSettings>"
$Content = "Nomad ACP Settings constructed as: " + $NomadSettings
Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
 
# Get Machine information
$ServerFQDN = Get-CimInstance -Namespace root\cimv2 -ClassName Win32_ComputerSystem
$ServerFQDN = $ServerFQDN.Name + "." + $ServerFQDN.Domain
 
# Get Site Information
$SiteWMI = Get-CimInstance -Namespace root\sms -ClassName SMS_ProviderLocation | Where-Object {$_.Machine -eq $ServerFQDN -AND $_.ProviderForLocalSite -eq $True}
If ($SiteWMI){
    $SiteCode = $SiteWMI.SiteCode
    $Content = "The local server is an SMS Provider and can be used in running this script.  The retrieved site code is " + $SiteCode
    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
    }Else{
    $Content = "ERROR: The local server is not an SMS Provider and therefore cannot be used for execution of this script."
    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
    Write-Host -ForegroundColor Red $Content
    Exit 1
    }
 
# Get Packages from the local site
$SiteNamespace = "root\sms\site_" + $SiteCode
$PackageFullInfo = Get-WMIObject -Namespace $SiteNamespace -Class SMS_Package | Where-Object {$_.SourceSite -eq $SiteCode}
$PackageList = ($PackageFullInfo | Select-Object -expandProperty PackageID).Split(" ")
$Content = "Retrieved list of packages from " + $SiteNamespace
Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
$Content = $PackageList
Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
 
# Checking Input Package ID Lists
If (!$ListPackage){
    $Content = "No package List was provided on the command line.  Checking for input file."
    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
    If (!$InputFile){
        $Content = "No package List was provided via input file."
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        $Content = "ERROR: No input was provided for package listing control and the script will exit."
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        Write-Host -ForegroundColor Red $Content
        Exit 1
        }Else{
        If (Test-Path -Path $InputFile){
            $Content = "The presence of the input file has been verified: " + $InputFile
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            $ListPackage = Get-Content -Path $InputFile
            $ToProcess = $ListPackage.Split(" ")
            }Else{
            $Content = "ERROR: The provided input file (" + $InputFile + ") could not be verified and the script will exit."
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            Write-Host -ForegroundColor Red $Content
            Exit 1
            }
        }
    }Else{
    If ($ListPackage -ceq "ALL"){
        $Content = "All packages are specified to be processed."
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        $ToProcess = $PackageList
        }Else{
        If ($ListPackage -eq "ALL"){
            Write-Host -ForegroundColor Red "When specifying all you must use all upper case letters.  This is by design.  The script will exit."
            $Content = "ERROR: When specifying all you must use all upper case letters.  This is by design.  The script will exit."
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            Exit 1
            }
        $ToProcess = $ListPackage.Split(",")
        }
    $Content = "A Package List was provided on the command line: " + $ListPackage
    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
    }
 
# Validate packages to be processed in input list
$ValidPackageList = ""
ForEach ($PkgID IN $ToProcess){
    If ($PkgID -IN $PackageList){
        $Content = "Package " + $PkgID + " was verified to be a ConfigMgr package."
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        If ($ValidPackageList -eq ""){
            $ValidPackageList = $PkgID
            }Else{
            $ValidPackageList = $ValidPackageList + "," + $PkgID
            }
        }Else{
        $Content = "ERROR: Package " + $PkgID + " could not be verified to be a ConfigMgr package."
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        }
    }
 
If (Test-Path -Path "NomadEnabled.txt"){
    $Content = "Deleting NomadEnabled.txt"
    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
    Write-Host $Content
    Remove-Item -Path "NomadEnabled.txt"
    }
If (Test-Path -Path "NomadDisabled.txt"){
    $Content = "Deleting NomadDisabled.txt"
    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
    Write-Host $Content
    Remove-Item -Path "NomadDisabled.txt"
    }
 
$ValidPackageList = $ValidPackageList.Split(",")
$Content = "Valid Package List: " + $ValidPackageList
Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
ForEach ($PkgID IN $ValidPackageList){
    $PackageConfig = $PackageFullInfo | Where-Object {$_.PackageId -eq $PkgID}
    $PackageName = $PackageConfig.Name
    If ($PackageConfig.IsPredefinedPackage -eq $True){
        $Content = "WARN: Package " + $PackageName + " (" + $PkgID + ") is a Predefined Package."
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        Write-Host -ForegroundColor Yellow -BackgroundColor DarkRed $Content
        Write-Host ""
        }Else{
        $Content = ""
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        $Content = "Package " + $PackageName + " (" + $PkgID + ") is not a Predefined Package and will be processed."
        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
        Write-Host -ForegroundColor Blue -BackgroundColor Cyan $Content
        If ($PackageName -eq "Configuration Manager Client Piloting Package"){
            $Content = "WARN: Package " + $PackageName + " (" + $PkgID + ") is known to have issues with changes to package properties and may not be set as expected."
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            Write-Host ""
            Write-Host -ForegroundColor Black -BackgroundColor Yellow $Content
            Write-Host ""
            }Else{
            # Get Lazy Properties
            $LazyProps = [wmi]"$($PackageConfig.__PATH)"
            $AlternateContentProviders = $LazyProps.AlternateContentProviders
            $ExtendedData = $LazyProps.ExtendedData
            $ExtendedDataSize = $LazyProps.ExtendedDataSize
            $IconSize = $LazyProps.IconSize
            $ISVData = $LazyProps.ISVData
            $ISVDataSize = $LazyProps.ISVDataSize
            $RefreshPkgSourceFlag = $LazyProps.RefreshPkgSourceFlag
            $RefreshSchedule = $LazyProps.RefreshSchedule
            $Content = "Package " + $PkgID + " Lazy Properties:"
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    AlternateContentProviders: " + $AlternateContentProviders
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ExtendedData: " + $ExtendedData
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ExtendedDataSize: " + $ExtendedDataSize
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    IconSize: " + $IconSize
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ISVData: " + $ISVData
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ISVDataSize: " + $ISVDataSize
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    RefreshPkgSourceFlag: " + $RefreshPkgSourceFlag
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    RefreshSchedule: " + $RefreshSchedule
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = ""
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            $Content = "*******************************************************************"
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            $Content = "Package " + $PkgID + " configuration, before:"
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            If ($AlternateContentProviders -eq "" -OR $AlternateContentProviders -eq " "){
                $ACPList = "<NONE>"
                }Else{
                $ACPList = $AlternateContentProviders
                }
            $Content = "Package " + $PkgID + " configured value AlternateContentProviders: " + $ACPList
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            $Content = ""
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            $LazyProps.AlternateContentProviders = $NomadSettings
            # ************ Set the ACP Value *****************
            If ($WhatIf -OR $NomadEval){
                $Content = "WARN: WhatIf or NomadEval is selected and no changes will actually be made."
                Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
                Write-Host -ForegroundColor Yellow $Content
                If ($ACPList -eq "<NONE>"){
                    $Content = "No ACP Detected.  Package added to NomadDisabled list."
                    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
                    Add-Content -Path "NomadDisabled.txt" -Value $PkgID
                    }Else{
                    $Content = "Evaluating detected ACP."
                    Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
                    If ($ACPList -match "NomadBranch"){
                        $Content = "ACP Status: 1.  Adding to NomadEnabled list."
                        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
                        Add-Content -Path "NomadEnabled.txt" -Value $PkgID
                        }Else{
                        $Content = "ACP Status: 0.  Adding to NomadEnabled list."
                        Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
                        Add-Content -Path "NomadDisabled.txt" -Value $PkgID
                        }
                    }
                }Else{
                $Content = "Setting the Value for AlternateContentProviders on package " + $PkgID
                Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
                Set-WMIInstance -InputObject $LazyProps
                }
            $PackageRecheck = Get-WMIObject -Namespace $SiteNamespace -Class SMS_Package | Where-Object {$_.SourceSite -eq $SiteCode -AND $_.PackageID -eq $PkgID}
            $PackageRecheck = [wmi]"$($PackageRecheck.__PATH)"
            $Content = "Package " + $PkgID + " configuration, after:"
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            # Get Lazy Properties
            $AlternateContentProviders = $PackageRecheck.AlternateContentProviders
            $ExtendedData = $PackageRecheck.ExtendedData
            $ExtendedDataSize = $PackageRecheck.ExtendedDataSize
            $IconSize = $PackageRecheck.IconSize
            $ISVData = $PackageRecheck.ISVData
            $ISVDataSize = $PackageRecheck.ISVDataSize
            $RefreshPkgSourceFlag = $PackageRecheck.RefreshPkgSourceFlag
            $RefreshSchedule = $PackageRecheck.RefreshSchedule
            $Content = "Package " + $PkgID + " Lazy Properties:"
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    AlternateContentProviders: " + $AlternateContentProviders
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ExtendedData: " + $ExtendedData
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ExtendedDataSize: " + $ExtendedDataSize
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    IconSize: " + $IconSize
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ISVData: " + $ISVData
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    ISVDataSize: " + $ISVDataSize
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    RefreshPkgSourceFlag: " + $RefreshPkgSourceFlag
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            $Content = "    RefreshSchedule: " + $RefreshSchedule
            If ($MaxLogging){Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn}
            If ($PackageRecheck.AlternateContentProviders -eq "" -OR $PackageRecheck.AlternateContentProviders -eq " "){
                $ACPList = "<NONE>"
                }Else{
                $ACPList = $PackageRecheck.AlternateContentProviders
                }
            $Content = "Package " + $PkgID + " configured value AlternateContentProviders: " + $ACPList
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            $Content = "*******************************************************************"
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            $Content = ""
            Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
            }
        }
    }
 
$Content = "Nomad Package Configuration has been completed."
Add-LogEntry $LogPath $Content $LogBasePathIn $LogFileNameIn $LogRootNameIn
