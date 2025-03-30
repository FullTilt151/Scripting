# ***************************************************************************
# 
# File:      ConfigureConfigMgrIntegration.ps1
#
# Version:   1.0
# 
# Author:    Michael Niehaus 
# 
# Purpose:   Integrate MDT components into the ConfigMgr 2007 and/or 2007
#            console.
#
# Usage:     Run this script elevated on a system where PowerShell scripts
#            are enabled ("set-executionpolicy bypass").
#
# ------------- DISCLAIMER -------------------------------------------------
# This script code is provided as is with no guarantee or waranty concerning
# the usability or impact on systems and may be used, distributed, and
# modified in any way provided the parties agree and acknowledge the 
# Microsoft or Microsoft Partners have neither accountabilty or 
# responsibility for results produced by use of this script.
#
# Microsoft will not provide any support through any means.
# ------------- DISCLAIMER -------------------------------------------------
#
# ***************************************************************************

# Get the MDT path
$mdtPath = (get-itemproperty "hklm:\Software\Microsoft\Deployment 4" -name Install_Dir -ErrorAction SilentlyContinue).Install_Dir
if ($mdtPath -eq $null)
{
    throw "Unable to locate the Microsoft Deployment Toolkit installation directory."
}

# Get the CM07 path
$cm07Path = (get-itemproperty "hklm:\Software\Microsoft\ConfigMgr\Setup" -name "UI Installation Directory" -ErrorAction SilentlyContinue).'UI Installation Directory'
if ($cm07Path -ne $null)
{
    Write-Host "Found CM07 at $cm07Path"
}
else
{
    $cm07Path = (get-itemproperty "hklm:\Software\wow6432node\Microsoft\ConfigMgr\Setup" -name "UI Installation Directory" -ErrorAction SilentlyContinue).'UI Installation Directory'
    if ($cm07Path -ne $null)
    {
        Write-Host "Found CM07 (32-bit) at $cm07Path"
    }
}

# Get the CM12 path
$cm12Path = (get-itemproperty "hklm:\Software\Microsoft\ConfigMgr10\Setup" -name "UI Installation Directory" -ErrorAction SilentlyContinue).'UI Installation Directory'
if ($cm12Path -ne $null)
{
    Write-Host "Found CM12 at $cm12Path"
}
else
{
    $cm12Path = (get-itemproperty "hklm:\Software\wow6432node\Microsoft\ConfigMgr10\Setup" -name "UI Installation Directory" -ErrorAction SilentlyContinue).'UI Installation Directory'
    if ($cm12path -ne $null)
    {
        Write-Host "Found CM12 (32-bit) at $cm12Path"
    }
}

# Extend CM07 console if found
if ($cm07Path -ne $null)
{
    Write-Host "Integrating MDT into the ConfigMgr 2007 console"

    # Copy needed DLLs
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.SCCMActions.dll" -Destination "$cm07Path\Bin\Microsoft.BDD.SCCMActions.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.Workbench.dll" -Destination "$cm07Path\Bin\Microsoft.BDD.Workbench.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.Wizards.dll" -Destination "$cm07Path\Bin\Microsoft.BDD.Wizards.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.PSSnapIn.dll" -Destination "$cm07Path\Bin\Microsoft.BDD.PSSnapIn.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.Core.dll" -Destination "$cm07Path\Bin\Microsoft.BDD.Core.dll" -Force

    # Copy extensions folder
    Copy-Item -Path "$mdtPath\Templates\Extensions" -Destination "$cm07Path\XmlStorage\Extensions" -Force -Recurse
}

# Extend CM12 console if found
if ($cm12Path -ne $null)
{
    Write-Host "Integrating MDT into the ConfigMgr 2012 console"

    # Copy needed DLLs
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.CM12Actions.dll" -Destination "$cm12Path\Bin\Microsoft.BDD.CM12Actions.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.Workbench.dll" -Destination "$cm12Path\Bin\Microsoft.BDD.Workbench.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.ConfigManager.dll" -Destination "$cm12Path\Bin\Microsoft.BDD.ConfigManager.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.CM12Wizards.dll" -Destination "$cm12Path\Bin\Microsoft.BDD.CM12Wizards.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.PSSnapIn.dll" -Destination "$cm12Path\Bin\Microsoft.BDD.PSSnapIn.dll" -Force
    Copy-Item -Path "$mdtPath\Bin\Microsoft.BDD.Core.dll" -Destination "$cm12Path\Bin\Microsoft.BDD.Core.dll" -Force

    # Copy extensions folder
    Copy-Item -Path "$mdtPath\Templates\CM12Extensions" -Destination "$cm12Path\XmlStorage\Extensions" -Force -Recurse
}
