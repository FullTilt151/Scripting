##########################################################################################
##                        CONFIGMGR CLIENT NOTIFICATION TOOL                            ##
##                                                                                      ##
## Allows performing client notification actions against remote computers using the     ##
## 'fast channel' independently of the ConfigMgr console. Intended for use on your      ##
## local workstation.                                                                   ##
##                                                                                      ##
## REQUIREMENTS                                                                         ##
## - .Net 4.6.2 minimum                                                                 ##
## - PowerShell 5 minimum                                                               ##
## - WSMan remote access to the ConfigMgr Site Server on the default port               ##
## - Relevant RBAC permissions in ConfigMgr                                             ##
## - A version of ConfigMgr that supports the client notification actions               ##
##                                                                                      ##
## VERSION                                                                              ##
## 1.1                                                                                  ##
##                                                                                      ##
## AUTHOR                                                                               ##
## Trevor Jones                                                                         ##
##                                                                                      ##
## CATCH ME ON                                                                          ##
## Twitter: trevor_smsagent                                                             ##
## Blog: smsagent.wordpress.com                                                         ##
##                                                                                      ##
## DATE                                                                                 ##
## 2018-10-31                                                                           ##
##                                                                                      ##
## DISCLAIMER                                                                           ##
## The tool is provided 'as-is' with no support. I accept no liability for it's use and ##
## you are solely responsible for any resulting damage to your system or loss of data,  ##
## so use it at your own discretion and risk.                                           ##
##                                                                                      ##
##########################################################################################


# Set the location we are running from
$Source = $PSScriptRoot

# Load in the function library
. "$Source\bin\FunctionLibrary.ps1"

# Do PS version check
If ($PSVersionTable.PSVersion.Major -lt 5)
{
  $Content = "ConfigMgr Client Notification Tool cannot start because it requires minimum PowerShell 5."
  New-WPFMessageBox -Content $Content -Title "Oops!" -TitleBackground Orange -TitleTextForeground Yellow -TitleFontSize 20 -TitleFontWeight Bold -BorderThickness 1 -BorderBrush Orange -Sound 'Windows Exclamation'
  Break
}

# Load the required assemblies
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Drawing
Add-Type -Path "$Source\bin\System.Windows.Interactivity.dll"
Add-Type -Path "$Source\bin\ControlzEx.dll"
Add-Type -Path "$Source\bin\MahApps.Metro.dll"

# Define the XAML code
[XML]$Xaml = [System.IO.File]::ReadAllLines("$Source\Xaml\App.xaml") 

# Create a synchronized hash table and add the WPF window and its named elements to it
$UI = [System.Collections.Hashtable]::Synchronized(@{})
$UI.Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object -Process {
    $UI.$($_.Name) = $UI.Window.FindName($_.Name)
    }

# Hold the background jobs here. Useful for querying the streams for any errors.
$UI.Jobs = @()

# Populate the client notification types
$ClientNotificationTypes = @(
    "Download Computer Policy"
    "Download User Policy"
    "Collect Discovery Data"
    "Collect Software Inventory"
    "Collect Hardware Inventory"
    "Evaluate Application Deployments"
    "Evaluate Software Update Deployments"
    "Switch to next Software Update Point"
    "Evaluate Device Health Attestation"
    "Check Conditional Access Compliance"
    "Restart"
)
$UI.ClientNotificationCombo.ItemsSource = $ClientNotificationTypes

# Load in the other code libraries
. "$Source\bin\ClassLibrary.ps1"
. "$Source\bin\EventLibrary.ps1"

# OC for data binding source
$UI.DataSource = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
$UI.DataSource.Add("False") # ProgressBar Indeterminate
$UI.DataSource.Add("Ready") # Status
$UI.DataSource.Add("Black") # Status foreground colour
$UI.DataSource.Add($null)   # Datagrid itemssource
$UI.DataSource.Add($Source) # Source

$UI.Window.DataContext = $UI.DataSource

# Region to display the UI
#region DisplayUI

# If code is running in ISE, use ShowDialog()...
if ($psISE)
{
    $null = $UI.window.Dispatcher.InvokeAsync{$UI.window.ShowDialog()}.Wait()
}
# ...otherwise run as an application
Else
{
    # Make PowerShell Disappear
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
 
    $app = New-Object -TypeName Windows.Application
    $app.Properties
    $app.Run($UI.Window)
}

#endregion