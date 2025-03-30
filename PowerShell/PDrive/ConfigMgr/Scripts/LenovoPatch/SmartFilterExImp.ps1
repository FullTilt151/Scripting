#Requires -RunAsAdministrator


###########################################
##                                       ##
##                                       ##
##        Title: SmartFilterExImp.ps1    ##
##    Publisher: Lenovo                  ##
##      Version: 1.0                     ##
##         Date: 2019-05-28              ##
##                                       ##
##                                       ##
###########################################


<#
.SYNOPSIS
    
    Export and Import Shared SmartFilters and Shared CompositeFilters to move between
    Configuraton Manager environments.

.DESCRIPTION
    
    This script will export, to .XML, one, multiple, or all shared SmartFilters and
    shared CompositeFilters from Lenovo Patch for SCCM.  Additionally this script will
    import, from .XML, all SmartFilters and CompositeFilter stored in the file.  The
    import process requires a confirmation on updating current SmartFilters and
    CompositeFilters from the .XML file to prevent accidental overwrite.  New SmartFilters
    and CompositeFilters do not require confirmation for creation.  See the parameters
    section and examples section for their correct usage.

.PARAMETER Exp
    
    Call this switch to run the script to Export SmartFilters and Composite Filters to an
    .XML file.  Cannot be used with the -Imp switch.

.PARAMETER Imp
    
    Call this switch to run the script to Import SmartFilters and Composite Filters from
    an .XML file.  Cannot be used with the -Exp switch.

.PARAMETER SiteCode
    
    Three (3) character alphanumeric site code used by SCCM.  Ex. PS1

.PARAMETER SFNamed

    Call this parameter with the -Exp switch when exporting one or multiple SmartFilters or
    CompositeFilters.  When exporting multiple Filters, use semicolon(;) delimited list of
    names.  If using the semicolon(;) in the name of a SmartFilter or CompositeFilter, use
    the -SplitChar parameter to change the character to split the list of names.

.PARAMETER SplitChar
    
    Character to split the list of SmartFilter or CompositeFilter names.  Default is a
    semicolon(;).  If this parameter is defined, it must be used part of the -SFNamed list
    as the separator between SmartFilter and/or CompositeFilter names.

.PARAMETER SFAll
    
    Call this switch with -Exp to export all Shared SmartFilters and Shared CompositeFilters.

.PARAMETER LogLocation
    
    Location of the CMTrace formatted log (.log) file.

.PARAMETER ExImpFile
    
    Location of output/input .XML file for SmartFilter and CompositeFilter data.
     
.EXAMPLE
    
    Export All SmartFilters and CompositeFilters for the PS1 site to the default file
    location.

    .\SmartFilterExImp.ps1 -SiteCode 'PS1' -Exp -SFAll

.EXAMPLE
    
    Export a SmartFilter or CompositeFilter named ThinkPad T460 for the PS1 site to the
    default file location.

    .\SmartFilterExImp.ps1 -SiteCode 'PS1' -Exp -SFNamed 'ThinkPad T460'

.EXAMPLE
    
    Export multiple SmartFilters or CompositeFilters named T460, T460 Current Not Published,
    and All Lenovo Models by MT code for the PS1 site to the default file location.

    .\SmartFilterExImp.ps1 -SiteCode 'PS1' -Exp -SFNamed 'T460;T460 Current Not Published;All Lenovo Models by MT code'

.EXAMPLE
    
    Export All SmartFilters and CompositeFilters for the PS1 site to the C:\Temp\MySharedFiltersToShare.XML file.

    .\SmartFilterExImp.ps1 -SiteCode 'PS1' -Exp -SFAll -ExImpFile 'C:\Temp\MySharedFiltersToShare.XML'

.EXAMPLE
    
    Import the filters from the default file and location for the PS1 site.

    .\SmartFilterExImp.ps1 -SiteCode 'PS1' -Imp

.EXAMPLE
    
    Import the filters from the C:\Temp\Filters.xml file for the PS1 site.

    .\SmartFilterExImp.ps1 -SiteCode 'PS1' -Imp -ExImpFile 'C:\Temp\Filters.xml'

.NOTES
    
    - User must have shared settings enabled for atleast one user and created atleast one 
      Shared SmartFilter to create all necessary WMI infrastructure required for SmartFilter
      storage.

    - After the script completes execution, all consoles where users have Shared Settings
      enabled will need to be closed and reopened to view/use the changes made to the Shared
      SmartFilters and/or Composite Filters.

    - If a Composite Filter name is included as the filter or one of the filters to export
      or import, all Shared Smart Filters included as rules will be exported or imported as
      part of the process.

    - When using the -Imp switch, existing SmartFilters or CompositeFilters will require the
      user to confirm or reject the changes prior to the continuing.

#>


#####################
# Script Parameters #
#####################
Param
(
    [switch]$Exp,
    [switch]$Imp,
    [string]$SiteCode,
    [string]$SFNamed,
    [char]$SplitChar,
    [switch]$SFAll,
    [string]$LogLocation,
    [string]$ExImpFile
)
#############
# Functions #
#############
Function LogCMTrace
{
    Param
    (
        [Parameter(Mandatory=$true)]
        $Message,
        [Parameter(Mandatory=$true)]
        $Type
    )
    $DateTime = (Get-Date -Format "HH:mm:ss.ffffff")
    $Date = (Get-Date -Format "MM-dd-yyyy")
    $ToLog = "<![LOG[$Message]LOG]!><time=`"$DateTime`" date=`"$Date`" component=`"SmartFilterUpdater`" context=`"`" type=`"$Type`" thread=`"$Pid`" file=`"SmartFilterUpdater`">"
    $ToLog | Out-File -Append -Encoding UTF8 -FilePath $LogLocation
}
Function UpdateFilter
{
    Param
    (
        [Parameter(Mandatory=$true)]
        $XMLSFIN,
        [Parameter(Mandatory=$true)]
        $XMLSFRev,
        [Parameter(Mandatory=$true)]
        $XMLSFGS
    )
    $SmartFilterNamedInstance = GWMI -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Query "SELECT * FROM SmartFilter WHERE InstanceName=`"$XMLSFIN`""
    If ($SmartFilterNamedInstance -eq $Null)
    {
        LogCMTrace -Type 1 -Message "Attempting to create new Shared SmartFilter or CompositeFilter: $XMLSFIN."
        $NewSmartFilterNamedInstance = Set-WMIInstance -ComputerName $SiteServer -Namespace Root\SMS\Site_$SiteCode\ST_Ivanti -Class SmartFilter -Arguments @{InstanceName=$XMLSFIN;Name="SmartFilter";LastModifiedAt=(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ");LastModifiedByMachine=$env:COMPUTERNAME+"."+(Get-WmiObject Win32_ComputerSystem).Domain;LastModifiedByUser=$env:USERDOMAIN+"\"+$env:USERNAME;Revision=$XMLSFRev;SmartFilterGroupSerialized=$XMLSFGS}
        If (!($NewSmartFilterNamedInstance))
        {
            LogCMTrace -Type 3 -Message "Shared SmartFilter or CompositeFilter $XMLSFIN not created."
            Return -20
        }
        LogCMTrace -Type 1 -Message "Shared SmartFilter or CompositeFilter $XMLSFIN created."
    }
    Else
    {
        LogCMTrace -Type 1 -Message "Existing Shared SmartFilter or CompositeFilter found.  Prompting to overwrite: $XMLSFIN."
        Write-Host "Confirmation to overwrite SmartFilter `"$XMLSFIN`": Y or Yes to overwrite this SmartFilter. N or No to skip overwriting this SmartFilter." -ForegroundColor White -BackgroundColor Red
        $OVWConfirm = Read-Host
        LogCMTrace -Type 1 -Message "Reponse from prompt: $OVWConfirm."
        If(($OVWConfirm.ToUpper() -eq "YES") -or ($OVWConfirm.toUpper() -eq "Y"))
        {
            LogCMTrace -Type 1 -Message "Attempting to overwrite Shared SmartFilter or CompositeFilter: $XMLSFIN"
            $SmartFilterNamedInstance.LastModifiedAt=(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
            $SmartFilterNamedInstance.LastModifiedByMachine=$env:COMPUTERNAME+"."+(Get-WmiObject Win32_ComputerSystem).Domain
            $SmartFilterNamedInstance.LastModifiedByUser=$env:USERDOMAIN+"\"+$env:USERNAME
            $SmartFilterNamedInstance.Revision=$XMLSFRev
            $SmartFilterNamedInstance.SmartFilterGroupSerialized=$XMLSFGS
            $SmartFilterNamedInstance.Put() | Out-Null
            $CheckSmartFilterNamedInstance = GWMI -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Query "SELECT * FROM SmartFilter WHERE InstanceName=`"$XMLSFIN`""
            If ($XMLSFRev -ne  $CheckSmartFilterNamedInstance.Revision)
            {
                LogCMTrace -Type 3 -Message "Shared SmartFilter or CompositeFilter $XMLSFIN was not overwritten."
                Return -21
            }
            LogCMTrace -Type 1 -Message "Shared SmartFilter or CompositeFilter $XMLSFIN was overwritten."
        }
    }
}
Function doImport
{
    Try
    {
        $XMLImpReader = New-Object System.Xml.XmlDocument
        $XMLImpReader.Load($ExImpFile)
    }
    Catch [System.Xml.XmlException]
    {
        LogCMTrace -Type 3 -Message "Unknown error in XML."
        Return -22
    }
    LogCMtrace -Type -1 -Message "Beginning to import Shared SmartFilters."
    $XML_SmartFilters = $XMLImpReader.SelectNodes("/ExportedSmartFilters/ExportedSmartFilter")
    If($XML_SmartFilters -ne $null)
    {
        ForEach ($XML_SmartFilter in $XML_SmartFilters)
        {
            UpdateFilter -XMLSFIN $XML_SmartFilter.InstanceName -XMLSFRev $XML_SmartFilter.Revision -XMLSFGS $XML_SmartFilter.SmartFilterGroupSerialized
        }
    }
    LogCMtrace -Type -1 -Message "Import Shared SmartFilters complete."
    LogCMtrace -Type -1 -Message "Beginning to import Shared CompositeFilters."
    $XML_CompositeFilters = $XMLImpReader.SelectNodes("/ExportedSmartFilters/ExportedCompositeFilter")
    If($XML_CompositeFilters -ne $null)
    {
        ForEach ($XML_CompositeFilter in $XML_CompositeFilters)
        {
            UpdateFilter -XMLSFIN $XML_CompositeFilter.InstanceName -XMLSFRev $XML_CompositeFilter.Revision -XMLSFGS $XML_CompositeFilter.SmartFilterGroupSerialized
        }
    }
    LogCMtrace -Type -1 -Message "Import Shared CompositeFilters complete."
}
Function doExport
{
    Param
    (
        [Parameter(Mandatory=$true)]
        [string]$SmartFilterName
    )
    $SmartFilterNamedInstance = GWMI -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Query "SELECT * FROM SmartFilter WHERE InstanceName=`"$SmartFilterName`""
    If ($SmartFilterNamedInstance.SmartFilterGroupSerialized -match "groupType=`"PackageComposite`"")
    {
        $BuiltinSmartFilterIgnoreList = @("*All","*Bundles","Detectoids","Included","*Latest not published","*Not-Published","*Published","*Revised metadata")
        Try
        {
            $XMLExReader = [XML]$SmartFilterNamedInstance.SmartFilterGroupSerialized
            $RuleNodes = $XMLExReader.SelectNodes("/SmartFilter/Rules/Rule")
        }
        Catch [System.Xml.XmlException]
        {
            LogCMTrace -Type 3 -Message "Unknown error in XML."
            Return -19
        }
        LogCMTrace -Type 1 -Message "Beginning export of CompositeFilter $SmartFilterName."
        ForEach($Rule in $RuleNodes)
        {
            If($BuiltinSmartFilterIgnoreList -notcontains $Rule.field)
            {
                doExport -SmartFilterName $Rule.field
            }
        }
        $FilterType = "CompositeFilter"
        If($alExportedSFNs -notcontains $SmartFilterName)
        {
            $SFGS = ((($SmartFilterNamedInstance.SmartFilterGroupSerialized).Replace("`r`n","").Replace(">  <","><")).Replace(">    <","><"))
            $XmlWriter.WriteStartElement("Exported$FilterType")
            $XmlWriter.WriteElementString("InstanceName",$SmartFilterNamedInstance.InstanceName)
            $XmlWriter.WriteElementString("Revision",$SmartFilterNamedInstance.Revision)
            $XmlWriter.WriteElementString("SmartFilterGroupSerialized",$SFGS)
            $XmlWriter.WriteEndElement() # <-- End <ExportedSmartFilter>
            $XmlWriter.Flush()
            $alExportedSFNs.add($SmartFilterName) | Out-Null
            LogCMTrace -Type 1 -Message "Export of CompositeFilter $SmartFilterName complete."
        }
    }
    Else
    {        
        $FilterType = "SmartFilter"
        If($alExportedSFNs -notcontains $SmartFilterName)
        {
            LogCMTrace -Type 1 -Message "Beginning export of SmartFilter $SmartFilterName."
            $SFGS = ((($SmartFilterNamedInstance.SmartFilterGroupSerialized).Replace("`r`n","").Replace(">  <","><")).Replace(">    <","><"))
            $XmlWriter.WriteStartElement("Exported$FilterType")
            $XmlWriter.WriteElementString("InstanceName",$SmartFilterNamedInstance.InstanceName)
            $XmlWriter.WriteElementString("Revision",$SmartFilterNamedInstance.Revision)
            $XmlWriter.WriteElementString("SmartFilterGroupSerialized",$SFGS)
            $XmlWriter.WriteEndElement() # <-- End <ExportedSmartFilter>
            $XmlWriter.Flush()
            $alExportedSFNs.add($SmartFilterName) | Out-Null
            LogCMTrace -Type 1 -Message "Export of SmartFilter $SmartFilterName complete."
        }
    }
}
#############
# PreFlight #
#############
#####
# Logfile checking
#####
If(!($LogLocation))
{
    $Location = $env:USERPROFILE +'\Lenovo\Lenovo Patch\'
    If(!(Test-Path $Location))
    {
        $LogLocation = $env:USERPROFILE+'\LenovoPatchSmartFilterUpdater.log'
    }
    Else
    {
        $LogLocation = $env:USERPROFILE+'\Lenovo\Lenovo Patch\LenovoPatchSmartFilterUpdater.log'
    }
}
Else
{
    If((($LogLocation.Substring($LogLocation.Length-4,4).ToUpper() -ne ".LOG") -or ($LogLocation.Substring($LogLocation.Length-5,1) -eq '\')))
    {
        $Location = $env:USERPROFILE +'\Lenovo\Lenovo Patch\'
        If(!(Test-Path $Location))
        {
            $LogLocation = $env:USERPROFILE+'\LenovoPatchSmartFilterUpdater.log'
        }
        Else
        {
            $LogLocation = $env:USERPROFILE+'\Lenovo\Lenovo Patch\LenovoPatchSmartFilterUpdater.log'
        }
    }
}
Write-Host "Logs can be found at: $LogLocation."
LogCMTrace -Type 1 -Message "-----------------------------------"
LogCMTrace -Type 1 -Message "Begin SmartFilterExImp script."
LogCMTrace -Type 1 -Message "Executing Preflight Checks."
LogCMTrace -Type 1 -Message "Logging location set."
#####
# Operating System Requirements
#####
$OS = GWMI -Query "SELECT * FROM Win32_OperatingSystem"
If(!((($OS.ProductType -eq "1"<#WorkStation#>) -and (($OS.Version -eq "6.1.7601"<#Windows 7 SP1#>) -or ($OS.Version -eq "6.3.9200"<#Windows 8.1#>) -or ($OS.Version -ge "10.0.10240"<#Windows 10#>))) -or (($OS.ProductType -eq "3"<#Server#>) -and (($OS.Version -eq "6.1.7601"<#Windows 2008 R2#>) -or ($OS.Version -eq "6.2.9200"<#Windows 2012#>) -or ($OS.Version -eq "6.3.9600"<#Windows 2012 R2#>) -or ($OS.Version -ge "10.0.14393"<#Windows 2016 or newer#>)))))
{
    LogCMTrace -Type 3 -Message "Invalid Operating System information.  Please reference the Lenovo Patch for SCCM User Guide for the list of valid operating systems."
    Return -1
}
If($OS.ProductType -eq "1")
{
    $OSProductType = "Client"
}
If($OS.ProductType -eq "3")
{
    $OSProductType = "Server"
}
$OSVers=$OS.Version
If($OS.OSArchitecture.ToUpper() -ne "64-BIT")
{
    LogCMTrace -Type 3 -Message "Must be on a 64-bit Operating System."
    Return -2
}
LogCMTrace -Type 1 -Message "64-Bit $OSProductType OS."
LogCMTrace -Type 1 -Message "Version: $OSVers"
#####
# Console installed and Lenovo Patch Installed
#####
$ConsoleInstalled = $false
$LenovoPatchInstalled = $false
$UninstallKeyPath=”SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall”
Try
{
    $regLM=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$env:COMPUTERNAME)
    $UninstallKey=$regLM.OpenSubKey($UninstallKeyPath)  
    $ListOfKeys=$UninstallKey.GetSubKeyNames()
    ForEach($Key in $ListOfKeys)
    {
        $ProgramGUID=$UninstallKeyPath+"\\"+$Key
        $ProgramInfo=$regLM.OpenSubKey($ProgramGUID)
        $DisplayName=[string]$ProgramInfo.GetValue("Displayname")
        $DisplayVersion = [string]$ProgramInfo.GetValue("DisplayVersion")
        If($DisplayName.ToUpper() -match "CONFIGURATION MANAGER CONSOLE")
        {
            $ConsoleInstalled = $true
            $CMCDN = $DisplayName
        }
        If(($DisplayName.ToUpper() -match "LENOVO PATCH FOR SCCM") -and ($DisplayVersion -ge "2.4"))
        {
            $LenovoPatchInstalled = $true
            $LPDN = $DisplayName
            $LPDV = $DisplayVersion
        }
    }
}
Catch
{
    LogCMTrace -Type 3 -Message "Registry Access Failed."
    Return -3
}
If(!($ConsoleInstalled))
{
    LogCMTrace -Type 3 -Message "Configuration Manager Console not installed."
    Return -4
}
LogCMTrace -Type 1 -Message "$CMCDN installed."
If(!($LenovoPatchInstalled))
{
    LogCMTrace -Type 3 -Message "Lenovo Patch for SCCM not installed."
    Return -5
}
LogCMTrace -Type 1 -Message "$LPDN version $LPDV installed."
#####
# Check if Shared Settings are enabled
#####
$LPCFG = "$env:USERPROFILE\Lenovo\Lenovo Patch\Lenovo Patch.config"
If(!(Test-Path $LPCFG))
{
    LogCMTrace -Type 3 -Message "Could not find $LPCFG."
    Return -6
}
Try
{
    $XMLContent = [XML](Get-Content $LPCFG)
    If(!($XMLContent.Settings.IsSharedSettingsEnabled.ToUpper() = "TRUE"))
    {
        LogCMTrace -Type 3 -Message "Shared Settings is not enabled for this user.  Please enable Shared Settings in the Lenovo Patch Settings Interface in the Configuration Manager Console."
        Return -7
    }
}
Catch [System.Xml.XmlException]
{
    LogCMTrace -Type 3 -Message "Unknown error in XML."
    Return -8
}
Catch
{
    LogCMTrace -Type 3 -Message "Unhandled error occured: $_"
    Return -9
}
LogCMTrace -Type 1 -Message "Shared Settings are enabled for this user on this device."
#####
# Checking command line parameters
#####
If(!($Exp -xor $Imp))
{
    LogCMTrace -Type 3 -Message "Either both -Exp and -Imp were used or neither -Exp or -Imp were used at the command line.  Please use just one when running this script."
    Return -10
}
If(!($SiteCode))
{
    LogCMTrace -Type 3 -Message "-SiteCode parameter is not defined."
    Return -11
}
If(!($Imp))
{
    If(!($SFNamed -xor $SFAll))
    {
        LogCMTrace -Type 3 -Message "Set -SFNamed to a the name or names of the Shared SmartFilters and/or Composite Filters to export.  Use -SFAll to export all Shared SmartFilters and Composite Filters.  Do not use -SFNamed and -SFAll at the same time."
        Return -12
    }
}
Try
{
    $QKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
    $QSubKey =  $QKey.OpenSubKey("SOFTWARE\WOW6432Node\Microsoft\ConfigMgr10\AdminUI\Connection")
    [string]$SiteServer = $QSubKey.GetValue("Server")
}
Catch
{
    LogCMTrace -Type 3 -Message "Registry Access Failed."
    Return -13
}
Try
{
    If(($env:COMPUTERNAME+"."+(GWMI Win32_ComputerSystem).Domain).ToUpper() -eq $SiteServer.ToUpper())
    { 
        $MainKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
        $SiteServer = "localhost"
    }
    Else
    {
        $MainKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $SiteServer, [Microsoft.Win32.RegistryView]::Registry64)
    } 
    $SubKey =  $MainKey.OpenSubKey("SOFTWARE\Microsoft\SMS\Identification")
    [string]$Root = $SubKey.GetValue("Site Code")
    If($SiteCode.ToUpper() -ne $Root.ToUpper())
    {
        LogCMTrace -Type 3 -Message "Defined sitecode, $SiteCode, not found."
        Return -14
    }
}
Catch
{
    LogCMTrace -Type 3 -Message "Registry Access Failed."
    Return -15
}
LogCMTrace -Type 1 -Message "Site code: $SiteCode."
If($SiteServer -eq "localhost")
{
    LogCMTrace -Type 1 -Message "Currently running on the site server."
}
Else
{
    LogCMTrace -Type 1 -Message "Using a connection to site server: $SiteServer."
}
#####
# Check Import/Export file
#####
If(!($ExImpFile))
{
    $ExImpFileLoc = $env:USERPROFILE +'\Lenovo\Lenovo Patch\'
    If(!(Test-Path $ExImpFileLoc))
    {
        $ExImpFile = $env:USERPROFILE+'\LenovoPatchSharedSmartFilterExImp.xml'
    }
    Else
    {
        $ExImpFile = $env:USERPROFILE+'\Lenovo\Lenovo Patch\LenovoPatchSharedSmartFilterExImp.xml'
    }
}
Else
{
    If((($ExImpFile.Substring($ExImpFile.Length-4,4).ToUpper() -ne ".XML") -or ($ExImpFile.Substring($ExImpFile.Length-5,1) -eq '\')))
    {
        $ExImpFileLoc = $env:USERPROFILE +'\Lenovo\Lenovo Patch\'
        If(!(Test-Path $ExImpFile))
        {
            $ExImpFile = $env:USERPROFILE+'\LenovoPatchSmartFilterUpdater.xml'
        }
        Else
        {
            $ExImpFile = $env:USERPROFILE+'\Lenovo\Lenovo Patch\LenovoPatchSmartFilterUpdater.xml'
        }
    }
}
Write-Host "Export/Import file can be found at: $ExImpFile."
LogCMTrace -Type 1 -Message "Export/Import file and location set."
LogCMTrace -Type 1 -Message "Export/Import file can be found at: $ExImpFile."
#####
# Check WMI for namespace and class
#####
$LPNS = GWMI -ComputerName $SiteServer -Class __Namespace -Namespace "Root\SMS\Site_$SiteCode" | ? {$_.Name -eq "ST_Ivanti"}
If(!($LPNS))
{
    LogCMTrace -Type 3 -Message "Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti was not found."
    Return -16
}
LogCMTrace -Type 1 -Message "Found WMI Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti"
$SFCS = GWMI -ComputerName $SiteServer -List -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" | ? {$_.Name -eq "SmartFilter"}
If(!($SFCS))
{
    LogCMTrace -Type 3 -Message "Class: SmartFilters in Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti was not found."
    Return -17
}
LogCMTrace -Type 1 -Message "Found Class: SmartFilters in Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti."
LogCMTrace -Type 1 -Message "Completed Preflight Checks."
LogCMTrace -Type 1 -Message "Executing Import/Export."
########
# Main #
########
If($Imp)
{
    LogCMTrace -Type 1 -Message "-Imp parameter set from the command line.  Beginning Import process."
    doImport
}
Else
{
    LogCMTrace -Type 1 -Message "-Exp parameter set from the command line. Beginning Export process."
    If((GWMI -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Query "SELECT * FROM SmartFilter") -eq $null)
    {
        LogCMTrace -Type 3 -Message "No Shared SmartFilters found."
        Return -18
    }
    LogCMTrace -Type 1 -Message "Atleast one Shared SmartFilter or CompositeFilter was found to export."
    # XmlWriter Settings
    $XmlSettings = New-Object System.Xml.XmlWriterSettings
    $XmlSettings.Indent = $true
    $XmlSettings.IndentChars = "`t"
    # XmlWriter Starting to Do Work 
    $XmlWriter = [System.XML.XmlWriter]::Create($ExImpFile, $XmlSettings)
    $XmlWriter.WriteStartDocument()
    $XmlWriter.WriteStartElement("ExportedSmartFilters") # <-- Creating the root <ExportedSmartFilters>
    [System.Collections.ArrayList]$alSFN = @()
    If($SFAll)
    {
        LogCMTrace -Type 1 -Message "-SFAll parameter found in the command line.  Beginning to export all Shared SmartFilters and/or CompositeFilters."
        $SFINs = GWMI -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Query "SELECT * FROM SmartFilter" | Select-Object InstanceName
        ForEach($SFIN in $SFINs)
        {
            $alSFN.Add($SFIN.InstanceName) | Out-Null
        }
    }
    Else
    {
        LogCMTrace -Type 1 -Message "Beginning to export list of Shared SmartFilters and/or CompositeFilters: $SFNamed."
        If(!($SplitChar))
        {
            $SplitChar = ";"
        }
        $alSFN = $SFNamed -split $SplitChar
    }
    [System.Collections.ArrayList]$alExportedSFNs = @()
    ForEach($SFName in $alSFN)
    {
        If((GWMI -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Query "SELECT * FROM SmartFilter WHERE InstanceName=`"$SFName`"") -ne $null)
        {
            doExport -SmartFilterName $SFName
        }
    }
    $XmlWriter.WriteEndElement() # <-- End <ExportedSmartFilters> 
    # XMLWriter Ending, Flushing, and Closing the XML Document.
    $XmlWriter.WriteEndDocument()
    $XmlWriter.Flush()
    $XmlWriter.Close()
    LogCMTrace -Type 1 -Message "Export of Shared SmartFilters and/or CompositeFilters complete." 
}
LogCMTrace -Type 1 -Message "Completed Import/Export."
LogCMTrace -Type 1 -Message "SmartFilterExImp Complete."