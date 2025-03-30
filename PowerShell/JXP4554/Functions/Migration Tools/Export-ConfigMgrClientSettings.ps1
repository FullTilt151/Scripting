<#
.SYNOPSIS
    Exports a client setting or parts of it to a XML for later reimport
.DESCRIPTION
    Exports a client setting or parts of it to a XML file for later (re-)import on another site
.PARAMETER ClientSettingName
    The name of the client setting that shall be exported
.PARAMETER Components
    A list of the (sub-)components that shall be exported during process. If not set or set to * all settings will be exported.
.PARAMETER ListSettings
    Presents a list of available client setting names for the server.
.PARAMETER ExportFilePath
    The filepath of the file that will contain the exported information for later reimport.
.EXAMPLE
    Export-ConfigMgrClientSettings -ListSettings

    Returns a list of available client settings
.EXAMPLE
    Export-ConfigMgrClientSettings 'MySettings' 'c:\temp\mysettings.export'

    Exports the client setting named MySettings with all its subsettings into the file c:\temp\mysettings.export
.NOTES
    file name: Export-ConfigMgrClientSettings.ps1
    author:    Schlee, Kevin
    contact:   kevin.schlee@dataport.de
    requires:  PowerShell 2.0
#>

PARAM(
    [parameter(ParameterSetName="Export", Mandatory=$true, Position=0)][string]$ClientSettingName,
    [parameter(ParameterSetName="Export", Mandatory=$true, Position=1)][string]$ExportFilePath,
    [parameter(ParameterSetName="Export", Mandatory=$false)][string[]]$Components,
    [parameter(ParameterSetName="Gather", Mandatory=$true)][switch]$ListSettings
)

# * * *  G L O B A L  S E T T I N G S  * * *
[string]$CONFIGMGR_SERVER_NAME = 'MyConfigMgrServerName'
[string]$CONFIGMGR_SITECODE = 'FOO'

# * * *  H E L P E R  F U N C T I O N S  * * *
function Get-ClientSettingNames(){
    $settingObjects = Get-WmiObject -Class 'SMS_ClientSettings' -ComputerName $CONFIGMGR_SERVER_NAME -Namespace "root\sms\site_$CONFIGMGR_SITECODE"
    $retVal = @()
    foreach($instance in $settingObjects){
        $retVal += $instance.Name
    }
    return $retVal
}
function Get-SettingObject(){
    PARAM([Parameter(Mandatory=$true)][string]$settingName)
    $retVal = $null
    foreach($result in (Get-WmiObject -Query "SELECT * FROM SMS_ClientSettings WHERE Name='$settingName'" -ComputerName $CONFIGMGR_SERVER_NAME -Namespace "root\sms\site_$CONFIGMGR_SITECODE")){
        $retVal = $result
    }
    if($retVal -eq $null){
        Write-Error -Message "Cannot find a client setting named $settingName."
        exit
    }
    return $retVal
}
function Get-NextLowestPriority(){
    $prio = 0
    foreach($setting in (Get-WmiObject -Class SMS_ClientSettings -ComputerName $CONFIGMGR_SERVER_NAME -Namespace "root\sms\site_$CONFIGMGR_SITECODE")){
        [int]$currentPrio = $setting.Priority
        if($currentPrio -gt $prio){
            $prio = $currentPrio
        }
    }
    $prio++
    return $prio
}
function Save-ObjectXml(){
    PARAM([Parameter(Mandatory=$true)]$settingObject)
    $settingObject.Get()
    $xmlFile = New-Object xml
    [System.Xml.XmlDeclaration]$declaration = $xmlFile.CreateXmlDeclaration("1.0","UTF-8",$null)
    $rootElement = $xmlFile.CreateElement("ConfigMgrClientSettings")
    $rootElement.SetAttribute("name", $settingObject.Name)
    $rootElement.SetAttribute("description", $settingObject.Description)
    $xmlFile.AppendChild($rootElement) | Out-Null
    $subSettings = $xmlFile.CreateElement("SubSettings")
    $rootElement.AppendChild($subSettings) | Out-Null

    $config = $settingObject.AgentConfigurations
    $config = $config | Sort-Object -Property AgentID
    foreach($subConfig in $config){
        if($Components -eq $null){
            #add everything
            Write-Debug "Add every component (Components not set)"
            $configNode = $xmlFile.CreateElement($subConfig.__CLASS)
            foreach($prop in $subConfig.Properties){
                if((($prop.Value) -ne $null) -and (($prop.Name) -ne 'AgentID')){
                    [string]$cimType = [string]::Empty

                    foreach($qualifier in $prop.Qualifiers){
                        if($qualifier.Name -eq 'CIMTYPE'){
                            $cimType = $qualifier.Value
                            break
                        }
                    }
                    $propertyNode = $xmlFile.CreateElement($prop.Name)
                    $propertyNode.SetAttribute("cimtype",$cimType)
                    $propertyNode.InnerText = $prop.Value
                    $configNode.AppendChild($propertyNode) | Out-Null
                }
            }
            $subSettings.AppendChild($configNode) | Out-Null
        }else{
            #add specific
            Write-Debug "Add specific component(s) (Components is set)"
            if($Components -eq '*'){
                #add all components
                Write-Debug "Asterisk ist set. Will add all components"
                $configNode = $xmlFile.CreateElement($subConfig.__CLASS)
                foreach($prop in $subConfig.Properties){
                    $propertyNode = $xmlFile.CreateElement($prop.Name)
                    $propertyNode.InnerXml = $prop.Value
                    if((($prop.Value) -ne $null) -and (($prop.Name) -ne 'AgentID')){
                        $configNode.AppendChild($propertyNode) | Out-Null
                    }
                }
                $subSettings.AppendChild($configNode) | Out-Null
            }else{
                #will only add specified components
                [string]$componentName = $subConfig.__CLASS
                $componentName = $componentName.Substring(4)
                if($Components -contains $componentName){
                    Write-Debug "Component name found in given component names"
                    $configNode = $xmlFile.CreateElement($subConfig.__CLASS)
                    foreach($prop in $subConfig.Properties){
                        $propertyNode = $xmlFile.CreateElement($prop.Name)
                        $propertyNode.InnerXml = $prop.Value
                        if((($prop.Value) -ne $null) -and (($prop.Name) -ne 'AgentID')){
                            $configNode.AppendChild($propertyNode) | Out-Null
                        }
                    }
                    $subSettings.AppendChild($configNode) | Out-Null
                }
            }
        }
    }
    $xmlFile.Save($ExportFilePath)
}
function Do-Gather(){
    Write-Host "Reading existing settings..." -NoNewline
    $settingList = $null
    try{
        $settingList = Get-ClientSettingNames
    }catch [System.Exception]{
        Write-Host "FAILED" -ForegroundColor Red
        Write-Error -Exception $_.Exception -Message "Cannot query instances of SMS_ClientSettings on machine $CONFIGMGR_SERVER_NAME"
        exit
    }
    Write-Host "DONE" -ForegroundColor Green
    if(($settingList.Count) -le 0){
        #no settings found
        Write-Host "No exportable client settings were found on site $CONFIGMGR_SITECODE."
    }else{
        #found at least one setting
        foreach($name in $settingList){
            Write-Host "Found a client setting named " -NoNewline
            Write-Host $name -ForegroundColor Cyan -NoNewline
            Write-Host "."
        }
    }
}
function Do-Export(){
    $settingObject = $null

    #reading setting object
    Write-Host "Trying to get client setting " -NoNewline
    Write-Host $ClientSettingName -NoNewline -ForegroundColor Cyan
    Write-Host "..." -NoNewline
    try{
        $settingObject = Get-SettingObject -settingName $ClientSettingName
    }catch [System.Exception]{
        Write-Host "DONE" -ForegroundColor Red
        Write-Error -Exception $_.Exception -Message "Unable to get setting object from site $CONFIGMGR_SITECODE."
        exit
    }
    Write-Host "DONE" -ForegroundColor Green
    $settingObject.Get()
    
    #trying to save object
    Write-Host "Trying to save settings to file..." -NoNewline
    try{
        Save-ObjectXml -settingObject $settingObject
    }catch [System.Exception]{
        Write-Host "FAILED" -ForegroundColor Red
        Write-Error -Exception $_.Exception -Message "Unable to create XML object file."
        exit
    }
    Write-Host "DONE" -ForegroundColor Green
}

# * * *  M A I N  R O U T I N E  * * *
switch($PSCmdlet.ParameterSetName){
    'Gather'{
        Write-Debug "Current parameter set is: Gather"
        Do-Gather
    }
    'Export'{
        Write-Debug "Current parameter set is: Export"
        Do-Export
    }
}