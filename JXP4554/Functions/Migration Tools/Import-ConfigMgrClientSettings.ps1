<#
.SYNOPSIS
    Import client setting files created with Export-ConfigMgrClientSettings.ps1.
.DESCRIPTION
    Reads the information out of the XML export file and creates a new SMS_ClientSettings instance with all embedded objects specified in the XML.
.PARAMETER FileName
    The path to the exported XML file that contains the SMS_ClientSettings information.
.EXAMPLE
    Import-ConfigMgrClientSettings.ps1 c:\temp\mysettings.xml

    Imports the settings previously exported to c:\temp\mysettings.xml
.EXAMPLE
    Import-ConfigMgrClientSettings.ps1 -FileName c:\temp\mysettings.xml

    Imports the settings previously exported to c:\temp\mysettings.xml
.NOTES
    file name: Import-ConfigMgrClientSettings.ps1
    author:    Schlee, Kevin
    contact:   kevin.schlee@dataport.de
    requires:  PowerShell 2.0
#>

PARAM([Parameter(Mandatory=$true, Position=0)][string]$FileName)

# * * *  G L O B A L  S E T T I N G S  * * *
[string]$CONFIGMGR_SERVER_NAME = 'MyConfigMgrServerName'
[string]$CONFIGMGR_SITECODE = 'FOO'

# * * *  H E L P E R  F U N C T I O N S  * * *
function Read-XmlFile(){
    $retVal = New-Object System.Object
    [System.Xml.XmlDocument]$xmlDoc = New-Object System.Xml.XmlDocument

    Write-Debug "Attempting to load $FileName into a XMLDocument."
    $xmlDoc.Load($FileName)

    Write-Debug "Attempting to get attribute name from /ConfigMgrClientSettings via XPath"
    $retVal | Add-Member -MemberType NoteProperty -Name Name -Value ($xmlDoc.SelectSingleNode("/ConfigMgrClientSettings").Attributes.GetNamedItem("name").Value)
    
    Write-Debug "Attempting to get attribute description from /ConfigMgrClientSettings via XPath"
    $retVal | Add-Member -MemberType NoteProperty -Name Description -Value ($xmlDoc.SelectSingleNode("/ConfigMgrClientSettings").Attributes.GetNamedItem("description").Value)

    Write-Debug "Cycling through every node in /ConfigMgrClientSettings/SubSettings"
    foreach($setting in ($xmlDoc.SelectSingleNode("/ConfigMgrClientSettings/SubSettings").ChildNodes)){
        $subSetting = New-Object System.Object
        $subSetting | Add-Member -MemberType NoteProperty -Name ClassName -Value $setting.ToString()
        $className = $setting.ToString()
        
        foreach($name in ($setting | Get-Member -MemberType Property)){
            $propName = $name.Name
            $propVal = $setting.($propName).InnerText
            if($propVal -ne $null){
                $cimType = $setting.$propName.Attributes.GetNamedItem("cimtype").Value
                $propertyObject = New-Object System.Object
                $propertyObject | Add-Member -MemberType NoteProperty -Name 'Name' -Value $propName
                $propertyObject | Add-Member -MemberType NoteProperty -Name 'Value' -Value $propval
                $propertyObject | Add-Member -MemberType NoteProperty -Name 'CIMType' -Value $cimType

                $subSetting | Add-Member -MemberType NoteProperty -Name $propName -Value $propertyObject
            }
        }
        $retVal | Add-Member -MemberType NoteProperty -Name $className -Value $subSetting
    }
    return $retVal
}
function Test-ClientSetting(){
    PARAM([Parameter(Mandatory=$true)][string]$settingName)
    $allSettings = Get-WmiObject -Class SMS_ClientSettings -ComputerName $CONFIGMGR_SERVER_NAME -Namespace "root\sms\site_$CONFIGMGR_SITECODE"
    foreach($setting in $allSettings){
        if(($setting.Name) -eq $settingName){
            return $true
        }
    }
    return $false
}
function Get-ClientAgentConfigNames(){
    PARAM([Parameter(Mandatory=$true,Position=0)]$settings)

    $retVal = @()

    foreach($property in ($settings | Get-Member -MemberType NoteProperty)){
        if(($property.Name -ne 'Name') -and ($property.Name -ne 'Description')){
            $retVal += $property.Name
        }
    }
    return $retVal
}
function Get-ClientAgentConfigValues(){
    PARAM([Parameter(Mandatory=$true,Position=0)]$config)

    $retVal = @()

    foreach($property in ($config | Get-Member -MemberType NoteProperty)){
        if($property.Name -ne 'ClassName'){$retVal += $property.Name}
    }
    return $retVal
}
function Create-SettingObject(){
    PARAM([Parameter(Mandatory=$true,Position=0)]$settings)

    $wmiPathClientSettings = "\\$CONFIGMGR_SERVER_NAME\root\sms\site_$($CONFIGMGR_SITECODE):SMS_ClientSettings"
    #$clientAgentConfigNames = Get-ClientAgentConfigNames -settings $settings
    $SMS_ClientSettings = ([wmiclass]$wmiPathClientSettings).CreateInstance()

    $SMS_ClientSettings.Name = $settings.Name
    $SMS_ClientSettings.Description = $settings.Description

    foreach($clientAgentConfigName in (Get-ClientAgentConfigNames -settings $settings)){
        $agentConfig = $settings.($clientAgentConfigName)
        $wmiPathClientAgentConfig = "\\$CONFIGMGR_SERVER_NAME\root\sms\site_$($CONFIGMGR_SITECODE):$($agentConfig.ClassName)"
        $SMS_ClientAgentConfig = ([wmiclass]$wmiPathClientAgentConfig).CreateInstance()
        foreach($clientAgentConfigPropertyName in (Get-ClientAgentConfigValues -config $agentConfig)){
            $propertyDescriptor = $agentConfig.($clientAgentConfigPropertyName)
            switch(($propertyDescriptor.CIMType).ToUpper()){
                'BOOLEAN'{
                    [bool]$val = [System.Convert]::ToBoolean($propertyDescriptor.Value)
                    $SMS_ClientAgentConfig.($propertyDescriptor.Name) = $val
                }
                'STRING'{
                    [string]$val = [System.Convert]::ToString($propertyDescriptor.Value)
                    $SMS_ClientAgentConfig.($propertyDescriptor.Name) = $val
                }
                'INT32'{
                    [int32]$val = [System.Convert]::ToInt32($propertyDescriptor.Value)
                    $SMS_ClientAgentConfig.($propertyDescriptor.Name) = $val
                }
                'UINT32'{
                    [uint32]$val = [System.Convert]::ToUInt32($propertyDescriptor.Value)
                    $SMS_ClientAgentConfig.($propertyDescriptor.Name) = $val
                }
                default{Write-Warning "Cannot identify type $($propertyDescriptor.CIMType)"}
            }
        }
        $SMS_ClientSettings.AgentConfigurations += $SMS_ClientAgentConfig
    }
    $SMS_ClientSettings.Put() | Out-Null
}

# * * *  M A I N  R O U T I N E  * * *
if((Test-Path -Path $FileName) -ne $true){Write-Error "Cannot find or access FileName path.";exit}
$exportInfo = $null

Write-Host "Reading export file..." -NoNewline
try{
    $exportInfo = Read-XmlFile
}catch [System.Exception]{
    Write-Host "FAILED" -ForegroundColor Red
    Write-Error -Exception $_.Exception -Message "Unable to read import file $FileName."
    exit
}
Write-Debug "weiter"
Write-Host "DONE" -ForegroundColor Green
Write-Host "Found a setting named " -NoNewline;Write-Host $exportInfo.Name -NoNewline -ForegroundColor Cyan; Write-Host " with following settings:"

foreach($class in ($exportInfo | Get-Member -MemberType NoteProperty)){
    if((($class.Name) -ne 'Name') -and (($class.Name) -ne 'Description')){
        Write-Host "    * " -NoNewline;Write-Host $class.Name -ForegroundColor Cyan
    }
}

if((Test-ClientSetting -settingName $exportInfo.Name) -eq $true){
    Write-Warning "A client setting with the exact name already exists on site $CONFIGMGR_SITECODE."
    exit
}

Write-Host "Trying to import client settings..." -NoNewline
try{
    Create-SettingObject -settings $exportInfo
}catch [System.Exception]{
    Write-Host "FAILED" -ForegroundColor Red
    Write-Error -Exception $_.Exception -Message "Unable to create settings $($exportInfo.Name) from file."
    exit
}
Write-Host "DONE" -ForegroundColor Green
Write-Host "All done - lay back and relax ;)"