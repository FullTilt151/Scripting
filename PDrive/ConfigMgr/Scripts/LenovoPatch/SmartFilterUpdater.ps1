#Requires -RunAsAdministrator


#############################################
##                                         ##
##                                         ##
##        Title: SmartFilterUpdater.ps1    ##
##    Publisher: Lenovo                    ##
##      Version: 1.1                       ##
##         Date: 2019-05-28                ##
##                                         ##
##                                         ##
#############################################


<#
.SYNOPSIS
    
    Create or update the listed Lenovo Patch for SCCM SmartFilter with all Lenovo models
    using information from the Configuration Manager database.

.DESCRIPTION
    
    Create or update the listed Lenovo Patch for SCCM SmartFilter with all Lenovo models,
    using either the BIOS or Machine Type codes, by searching the Configuration Manager
    database for content and comparing against a Lenovo provided web based XML.

.PARAMETER BIOS
    
    Call this switch to create the list of models based off the BIOS code.  Cannot be
    used with the -MT switch.

.PARAMETER MT
    
    Call this switch to create the list of models based off the Machine Type code.
    Cannot be used with the -BIOS switch.
    
.PARAMETER SiteCode
    
    Three (3) character alphanumeric site code used by SCCM.  Ex. PS1
    
.PARAMETER SmartFilterName
    
    Name of the SmartFilter to be updated.
    
.PARAMETER CreateNew
    
    Call this switch with the SmartFilterName parameter to create a new SmartFilter with
    the name defined in the SmartFilterName parameter.  If the SmartFilter to create is
    already there, you will be prompted to overwrite it.
    
.PARAMETER LogLocation
    
    Location of the CMTrace formatted log (.log) file.

.EXAMPLE
    
    Update the SmartFilter "My Lenovo Models" using BIOS codes.

    .\SmartFilterUpdater.ps1 -BIOS -SmartFilterName 'My Lenovo Models' -SiteCode 'PS1'

.EXAMPLE
    
    Update the SmartFilter "My Lenovo Models" using Machine Type codes.

    .\SmartFilterUpdater.ps1 -MT -SmartFilterName 'My Lenovo Models' -SiteCode 'PS1'

.EXAMPLE
    
    Create a new SmartFilter "My Lenovo Models" using BIOS codes.

    .\SmartFilterUpdater.ps1 -BIOS -SmartFilterName 'My Lenovo Models' -CreateNew -SiteCode 'PS1'

.EXAMPLE
    
    Update the SmartFilter My Lenovo Models by BIOS codes and log to the C:\Windows\Temp\LenovoPatchSmartFilterUpdater.log file.

    .\SmartFilterUpdater.ps1 -BIOS -SmartFilterName 'My Lenovo Models' -SiteCode 'PS1' -LogLocation 'C:\Windows\Temp\LenovoPatchSmartFilterUpdater.log'

.NOTES
    
    - Customer must have shared settings enabled for atleast one user and created atleast one
      Shared SmartFilter to create all necessary WMI infrastructure required for SmartFilter
      storage.

    - After the script completes execution, all consoles where users have Shared Settings
      enabled will need to be closed and reopened to view/use the changes made to the Shared
      SmartFilters chosen to be created or updated.

    - This script cannot be used to create or update CompositeFilters.

    - In the SmartFilter, the there are two entries for each model. We have added two lines for the following reasons:
        - When searching for a ThinkPad P52, for example, using the 'Contains' operator, we would actually return data for the ThinkPad P52 and the ThinkPad P52s.
          We do not want to return any unecessary updates, which may not apply to a customers estate.  In the first entry, we utilize the comma in the Notes field
          to terminate the string for searching.
        - By adding the comma, we then cannot search for models that may be the last or only in the list.  We add the second entry using the 'EndsWith' operator to determine
          if ThinkPad P52 is the only one in the Notes field or if it is the last item in the Notes field.


#>


#####################
# Script Parameters #
#####################
Param
(
    [switch]$BIOS,
    [switch]$MT,
    [string]$SiteCode,
    [switch]$CreateNew,
    [string]$SmartFilterName,
    [string]$LogLocation
)
#############
# Functions #
#############
Function LogCMTrace {
    param (
        [Parameter(Mandatory = $true)]
        $Message,
        [Parameter(Mandatory = $true)]
        $Type )

    $DateTime = (Get-Date -Format "HH:mm:ss.ffffff")
    $Date = (Get-Date -Format "MM-dd-yyyy")
    $ToLog = "<![LOG[$Message]LOG]!><time=`"$DateTime`" date=`"$Date`" component=`"SmartFilterUpdater`" context=`"`" type=`"$Type`" thread=`"$Pid`" file=`"SmartFilterUpdater`">"
    $ToLog | Out-File -Append -Encoding UTF8 -FilePath $LogLocation
}
Function SearchCMDB {
    Param
    (
        [Parameter(Mandatory = $true)]
        $SearchQuery,
        [Parameter(Mandatory = $true)]
        $SearchProperty,
        [Parameter(Mandatory = $true)]
        $SearchXMLNodePath
    )
    #
    # Get unique versions of needed information from the CM DB.
    #
    If ((Get-WmiObject -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode" -Query $SearchQuery | Select-Object -Property $SearchProperty).count -lt 1) {
        LogCMTrace -Message "No Lenovo products found by BIOS / Machine Type identifiers in the Configuration Manager database." -Type 3
        Return -17
    }
    LogCMTrace -Type 1 -Message "Found one or more Lenovo product BIOS / Machine Type identifiers in the Configuration Manager database."
    #
    # Finding SmartFilter and making sure its not a CompositeFilter
    #
    $SmartFilterNamedInstance = Get-WmiObject -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Query "SELECT * FROM SmartFilter WHERE InstanceName=`"$SmartFilterName`""
    If (!($SmartFilterNamedInstance)) {
        If (!($CreateNew)) {
            LogCMTrace -Type 3 -Message "Cannot find a SmartFilter named $SmartFilterName to update.  Not set to create a new SmartFilter."
            Return -18
        }
    }
    If (($SmartFilter) -and ($SmartFilterNamedInstance.SmartFilterGroupSerialized.ToUpper() -contains "GROUPTYPE=`"PACKAGECOMPOSITE`"")) {
        LogCMTrace -Type 3 -Message "Found a CompositeFilter with the name `"$SmartFilterName`".  No SmartFilter with that name found."
        Return -19
    }
    LogCMTrace -Type 1 -Message "SmartFilter: $SmartFilterName found."
    $colUnique = Get-WmiObject -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode" -Query $SearchQuery | Select-Object -Property @{l = "gProp"; e = { $_.$SearchProperty.substring(0, 4) } } | Sort-Object gProp -Unique
    #
    # Read XML model list from Web
    #
    Try {
        $XMLWebReader = New-Object System.Xml.XmlDocument
        $XMLWebReader.Load("https://download.lenovo.com/cdrt/catalog/models.xml")
    }
    Catch [System.Net.WebException] {
        LogCMTrace -Type 3 -Message "Error: https://download.lenovo.com/cdrt/catalog/models.xml not found."
        Return -20
    }
    Catch [System.Xml.XmlException] {
        LogCMTrace -Type 3 -Message "Unknown error in XML."
        Return -21
    }
    LogCMTrace -Type 1 -Message "Loaded Lenovo XML to be searched."
    #   
    # Dynamically build the SmartFilter query using the XML model list pulled from web with data from the Configuration Manager Database.
    #
    $RuleXML = ""
    $ArrayNames = @()
    ForEach ($oUnique in $colUnique) {
        LogCMTrace -Type 1 -Message "Searching the Lenovo XML for: $($oUnique.gProp)"
        $XML_Models = $XMLWebReader.SelectNodes("/ModelList/Model/$SearchXMLNodePath[text()='" + $oUnique.gProp + "']/../..")
        ForEach ($Model in $XML_Models) {
            Write-Host $Model.Name
            If ($ArrayNames -contains $Model.Name) {
                LogCMTrace -Type 1 -Message "$($Model.Name) already exists in the present SmartFilter, skipping."
                Continue
            }
            LogCMTrace -Type 1 -Message "Adding $($Model.Name) to the SmartFilter."
            $ArrayNames += $Model.Name
            $RuleXML += "<Rule field=`"CustomData1`" operator=`"Contains`" text=`"" + $Model.Name + ",`" /><Rule field=`"CustomData1`" operator=`"EndsWith`" text=`"" + $Model.Name + "`" />"
        }
    }
    If ($RuleXML -eq "") {
        LogCMTrace -Type 3 -Message "Queried models from the Configuration Manager Database did not match any models from the web catalog."
        Return -22
    }
    LogCMTrace -Type 1 "Dynamically built SmartFilter from comparing the downloaded Lenovo XML data to the BIOS / Machine Type data from the Configuration Manager Database."
    #
    # Updating the named SmartFilter.
    #
    If ($SmartFilterNamedInstance) {
        $ConfirmCreation = $true
        If ($CreateNew) {
            LogCMTrace -Type 1 -Message "-CreateNew command line parameter set.  When attempting to create a new SmartFilter, one was already found.  Prompting to overwrite an existing SmartFilter"
            Write-Host "You have chosen to create a SmartFilter named: `"$SmartFilterName`".  A SmartFilter with this name already exists." -BackgroundColor Red -ForegroundColor White # Confirm creation prompt
            Write-Host "Confirmation to overwrite SmartFilter `"$SmartFilterName`": Y or Yes to overwrite this SmartFilter. N or No to skip overwriting this SmartFilter." -BackgroundColor Red -ForegroundColor White # Confirm creation prompt
            $OVWConfirm = Read-Host
            LogCMTrace -Type 1 -Message "Reponse from prompt: $OVWConfirm."
            If (($OVWConfirm.ToUpper() -ne "YES") -and ($OVWConfirm.toUpper() -ne "Y")) {
                $ConfirmCreation = $false
                LogCMTrace -Type 1 -Message "Not performing overwrite.  Exiting script."
                Return 0
            }
        }
        Try {
            If ($ConfirmCreation) {
                $XMLSmartFilter = New-Object -TypeName System.Xml.XmlDocument
                $XMLSmartFilter.LoadXml($SmartFilterNamedInstance.SmartFilterGroupSerialized)
                If ($XMLSmartFilter.SmartFilter.Rules -is [Xml.XmlElement]) {
                    $XMLSmartFilter.SmartFilter.Rules.Rule | ForEach-Object { $_.ParentNode.RemoveChild($_) | Out-Null }
                }
                $SmartFilterNamedInstance.SmartFilterGroupSerialized = $XMLSmartFilter.OuterXml.Replace("<Rules></Rules>", "<Rules>$RuleXML</Rules>")
                $SmartFilterNamedInstance.LastModifiedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
                $SmartFilterNamedInstance.LastModifiedByMachine = $env:COMPUTERNAME + "." + (Get-WmiObject win32_computersystem).Domain
                $SmartFilterNamedInstance.LastModifiedByUser = $env:USERDOMAIN + "\" + $env:USERNAME
                $SmartFilterNamedInstance.Revision = $([guid]::NewGuid().Guid.ToString())
                $SmartFilterNamedInstance.Put() | Out-Null
            }
        }
        Catch [System.Xml.XmlException] {
            LogCMTrace -Type 3 -Message "XML Exception: XML could not be parsed."
            Return -24
        }
        Catch {
            LogCMTrace -Type 3 -Message "Unknown error."
            Return -25
        }
        LogCMTrace -Type 1 -Message "SmartFilter: $SmartFilterName Successfully updated."
    }
    Else {
        $RuleXML = "<?xml version=`"1.0`" encoding=`"utf-16`"?><SmartFilter xmlns:xsi=`"http://www.w3.org/2001/XMLSchema-instance`" xmlns:xsd=`"http://www.w3.org/2001/XMLSchema`" default=`"false`" groupType=`"Package`" matchType=`"Any`" name=`"$SmartFilterName`" scope=`"Shared`"><Rules>$RuleXML</Rules></SmartFilter>"
        $NewSmartFilterNamedInstance = Set-WmiInstance -ComputerName $SiteServer -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" -Class "SmartFilter" -Arguments @{InstanceName = $SmartFilterName; Name = "SmartFilter"; LastModifiedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"); LastModifiedByMachine = $env:COMPUTERNAME + "." + (Get-WmiObject Win32_ComputerSystem).Domain; LastModifiedByUser = $env:USERDOMAIN + "\" + $env:USERNAME; Revision = $([guid]::NewGuid().Guid.ToString()); SmartFilterGroupSerialized = $RuleXML }
        If (!($NewSmartFilterNamedInstance)) {
            LogCMTrace -Type 3 -Message "SmartFilter: $SmartFilterName not created."
            Return -23
        }
        LogCMTrace -Type 1 -Message "SmartFilter: $SmartFilterName created."
    }
}
#############
# PreFlight #
#############
#####
# Logfile checking
#####
If (!($LogLocation)) {
    $Location = $env:USERPROFILE + '\Lenovo\Lenovo Patch\'
    If (!(Test-Path $Location)) {
        $LogLocation = $env:USERPROFILE + '\LenovoPatchSmartFilterUpdater.log'
    }
    Else {
        $LogLocation = $env:USERPROFILE + '\Lenovo\Lenovo Patch\LenovoPatchSmartFilterUpdater.log'
    }
}
Else {
    If ((($LogLocation.Substring($LogLocation.Length - 4, 4).ToUpper() -ne ".LOG") -or ($LogLocation.Substring($LogLocation.Length - 5, 1) -eq '\'))) {
        $Location = $env:USERPROFILE + '\Lenovo\Lenovo Patch\'
        If (!(Test-Path $Location)) {
            $LogLocation = $env:USERPROFILE + '\LenovoPatchSmartFilterUpdater.log'
        }
        Else {
            $LogLocation = $env:USERPROFILE + '\Lenovo\Lenovo Patch\LenovoPatchSmartFilterUpdater.log'
        }
    }
}
Write-Host "Logs can be found at: $LogLocation."
LogCMTrace -Type 1 -Message "-----------------------------------"
LogCMTrace -Type 1 -Message "Begin SmartFilterUpdater script."
LogCMTrace -Type 1 -Message "Executing Preflight Checks."
LogCMTrace -Type 1 -Message "Logging location set."
#####
# Operating System Requirements
#####
$OS = Get-WmiObject -Query "SELECT * FROM Win32_OperatingSystem"
If (!((($OS.ProductType -eq "1"<#WorkStation#>) -and (($OS.Version -eq "6.1.7601"<#Windows 7 SP1#>) -or ($OS.Version -eq "6.3.9200"<#Windows 8.1#>) -or ($OS.Version -ge "10.0.10240"<#Windows 10#>))) -or (($OS.ProductType -eq "3"<#Server#>) -and (($OS.Version -eq "6.1.7601"<#Windows 2008 R2#>) -or ($OS.Version -eq "6.2.9200"<#Windows 2012#>) -or ($OS.Version -eq "6.3.9600"<#Windows 2012 R2#>) -or ($OS.Version -ge "10.0.14393"<#Windows 2016 or newer#>))))) {
    LogCMTrace -Type 3 -Message "Invalid Operating System information.  Please reference the Lenovo Patch for SCCM User Guide for the list of valid operating systems."
    Return -1
}
If ($OS.ProductType -eq "1") {
    $OSProductType = "Client"
}
If ($OS.ProductType -eq "3") {
    $OSProductType = "Server"
}
$OSVers = $OS.Version
If ($OS.OSArchitecture.ToUpper() -ne "64-BIT") {
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
$UninstallKeyPath = ”SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall”
Try {
    $regLM = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $env:COMPUTERNAME)
    $UninstallKey = $regLM.OpenSubKey($UninstallKeyPath)  
    $ListOfKeys = $UninstallKey.GetSubKeyNames()
    ForEach ($Key in $ListOfKeys) {
        $ProgramGUID = $UninstallKeyPath + "\\" + $Key
        $ProgramInfo = $regLM.OpenSubKey($ProgramGUID)
        $DisplayName = [string]$ProgramInfo.GetValue("Displayname")
        $DisplayVersion = [string]$ProgramInfo.GetValue("DisplayVersion")
        If ($DisplayName.ToUpper() -match "CONFIGURATION MANAGER CONSOLE") {
            $ConsoleInstalled = $true
            $CMCDN = $DisplayName
        }
        If (($DisplayName.ToUpper() -match "LENOVO PATCH FOR SCCM") -and ($DisplayVersion -ge "2.4")) {
            $LenovoPatchInstalled = $true
            $LPDN = $DisplayName
            $LPDV = $DisplayVersion
        }
    }
}
Catch {
    LogCMTrace -Type 3 -Message "Registry Access Failed."
    Return -3
}
If (!($ConsoleInstalled)) {
    LogCMTrace -Type 3 -Message "Configuration Manager Console not installed."
    Return -4
}
LogCMTrace -Type 1 -Message "$CMCDN installed."
If (!($LenovoPatchInstalled)) {
    LogCMTrace -Type 3 -Message "Lenovo Patch for SCCM not installed."
    Return -5
}
LogCMTrace -Type 1 -Message "$LPDN version $LPDV installed."
#####
# Check if Shared Settings are enabled
#####
$LPCFG = "$env:USERPROFILE\Lenovo\Lenovo Patch\Lenovo Patch.config"
If (!(Test-Path $LPCFG)) {
    LogCMTrace -Type 3 -Message "Could not find $LPCFG."
    Return -6
}
Try {
    $XMLContent = [XML](Get-Content $LPCFG)
    If (!($XMLContent.Settings.IsSharedSettingsEnabled.ToUpper() = "TRUE")) {
        LogCMTrace -Type 3 -Message "Shared Settings is not enabled for this user.  Please enable Shared Settings in the Lenovo Patch Settings Interface in the Configuration Manager Console."
        Return -7
    }
}
Catch [System.Xml.XmlException] {
    LogCMTrace -Type 3 -Message "Unknown error in XML."
    Return -8
}
Catch {
    LogCMTrace -Type 3 -Message "Unhandled error occured: $_"
    Return -9
}
LogCMTrace -Type 1 -Message "Shared Settings are enabled for this user on this device."
#####
# Checking command line parameters.
#####
If (!($BIOS -xor $MT)) {
    LogCMTrace -Type 3 -Message "Either both -BIOS and -MT were used or neither -BIOS or -MT were used at the command line.  Please use just one when running this script."
    Return -10
}
If (!($SiteCode)) {
    LogCMTrace -Type 3 -Message "-SiteCode parameter is not defined."
    Return -11
}
Try {
    $QKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
    $QSubKey = $QKey.OpenSubKey("SOFTWARE\WOW6432Node\Microsoft\ConfigMgr10\AdminUI\Connection")
    [string]$SiteServer = $QSubKey.GetValue("Server")
}
Catch {
    LogCMTrace -Type 3 -Message "Registry Access Failed."
    Return -12
}
Try {
    If (($env:COMPUTERNAME + "." + (Get-WmiObject Win32_ComputerSystem).Domain).ToUpper() -eq $SiteServer.ToUpper()) { 
        $MainKey = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, [Microsoft.Win32.RegistryView]::Registry64)
        $SiteServer = "localhost"
    }
    Else {
        $MainKey = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $SiteServer, [Microsoft.Win32.RegistryView]::Registry64)
    } 
    $SubKey = $MainKey.OpenSubKey("SOFTWARE\Microsoft\SMS\Identification")
    [string]$Root = $SubKey.GetValue("Site Code")
    If ($SiteCode.ToUpper() -ne $Root.ToUpper()) {
        LogCMTrace -Type 3 -Message "Defined sitecode, $SiteCode, not found."
        Return -13
    }
}
Catch {
    LogCMTrace -Type 3 -Message "Registry Access Failed."
    Return -14
}
LogCMTrace -Type 1 -Message "Site code: $SiteCode."
If ($SiteServer -eq "localhost") {
    LogCMTrace -Type 1 -Message "Currently running on the site server."
}
Else {
    LogCMTrace -Type 1 -Message "Using a connection to site server: $SiteServer."
}
#####
# Check WMI for namespace and class
#####
$LPNS = Get-WmiObject -ComputerName $SiteServer -Class __Namespace -Namespace "Root\SMS\Site_$SiteCode" | Where-Object { $_.Name -eq "ST_Ivanti" }
If (!($LPNS)) {
    LogCMTrace -Type 3 -Message "Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti was not found."
    Return -15
}
LogCMTrace -Type 1 -Message "Found WMI Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti"
$SFCS = Get-WmiObject -ComputerName $SiteServer -List -Namespace "Root\SMS\Site_$SiteCode\ST_Ivanti" | Where-Object { $_.Name -eq "SmartFilter" }
If (!($SFCS)) {
    LogCMTrace -Type 3 -Message "Class: SmartFilters in Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti was not found."
    Return -16
}
LogCMTrace -Type 1 -Message "Found Class: SmartFilters in Namespace: Root\SMS\Site_$SiteCode\ST_Ivanti."
LogCMTrace -Type 1 -Message "Completed Preflight Checks."
LogCMTrace -Type 1 -Message "Executing SmartFilter and CompositeFilter Updates."
########
# Main #
########
If ($BIOS) {
    LogCMTrace -Type 1 -Message "-BIOS parameter set from command line.  Searching the Configuration Manager database for Lenovo BIOS Codes."
    SearchCMDB -SearchQuery "Select * from SMS_G_System_PC_BIOS WHERE Manufacturer='Lenovo'" -SearchProperty "SMBIOSBIOSVersion" -SearchXMLNodePath "Bios/Code"
}
Else {
    LogCMTrace -Type 1 -Message "-MT parameter set from command line.  Searching the Configuration Manager database for Lenovo Machine Types."
    SearchCMDB -SearchQuery "Select * from SMS_G_System_COMPUTER_SYSTEM_PRODUCT WHERE Vendor='Lenovo'" -SearchProperty "Name" -SearchXMLNodePath "Types/Type"
}
LogCMTrace -Type 1 -Message "Completed SmartFilter Updates."
LogCMTrace -Type 1 -Message "SmartFilterUpdater Complete."