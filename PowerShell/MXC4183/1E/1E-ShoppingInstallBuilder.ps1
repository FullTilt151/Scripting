#----------------------------------------------------------------------------------------
# ScriptName: ShoppingInstallBuilder.ps1
# Written by: Richard Fellows
# Purpose: This script is designed to gather as much detail as possible FROM an existing Shopping Database in order to build/rebuild an installation

# Limitations: Service Account passwords must be manually specified by editing the output file, License Keys


# output: v<version>_Install.cmd
# log:  CurrentScriptFolder\ShoppingInstallationBuilder.log

# supported versions of Shopping  - all

# Version: 1.1
# Date: 5/10/2016
# 1E Ltd Copyright 2008-2019
# 
# Disclaimer:                                                                                                                                                                                                                                        
# Your use of this script is at your sole risk. This script is provided "as-is", without any warranty, whether express               
# or implied, of accuracy, completeness, fitness for a particular purpose, title or non-infringement, and is not                      
# supported or guaranteed by 1E. 1E shall not be liable for any damages you may sustain by using this script, whether      
# direct, indirect, special, incidental or consequential, even if it has been advised of the possibility of such damages. 

$ShowSQL = $false # output the SQL used
$Logfile = ".\ShoppingInstallBuilder.log"

# logging function 
Function WriteLog{
   Param ([string]$string)
       $Time = Get-Date -Format "HH:mm:ss"
       $Date = Get-Date -Format "MM-dd-yyyy"
   Add-content $Logfile -value $("[" + $Date + ": " + $Time + "] " + $string) 
   #[System.Threading.Thread]::Sleep(250)
}

function qrySQLSingleValue{param([string]$qry)
if ($ShowSQL -eq $true)
       {
              WriteLog "-------------------------------------------------------------------------"
              WriteLog $qry
              WriteLog "-------------------------------------------------------------------------"
       }
#Exit
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $SQLConnectString
$SqlConnection.Open()
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $qry
$SqlCmd.Connection = $SqlConnection
$reader = $SqlCmd.ExecuteReader()
#$counter = $reader.FieldCount
    if (($reader.HasRows))
       {
                     while ($Reader.Read()) 
                         {
                    
                            Writelog "Database Setting: $($reader.GetValue(0))"
                            Return $reader.GetValue(0)
                            
                         }
       }
       else {
              Write-Host "the query: $qry `n returned no results"
              WriteLog "the query: $qry `n returned no results"
              }
$SqlConnection.Close()
}

function qrySQLNamedValuePair{param([string]$qry)
if ($ShowSQL -eq $true)
       {
              WriteLog "-------------------------------------------------------------------------"
              WriteLog $qry
              WriteLog "-------------------------------------------------------------------------"
       }
#Exit
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = $SQLConnectString
$SqlConnection.Open()
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $qry
$SqlCmd.Connection = $SqlConnection
$reader = $SqlCmd.ExecuteReader()
#$counter = $reader.FieldCount
    if (($reader.HasRows))
       {
                     while ($Reader.Read()) 
                         {
                            $Name = $reader.GetValue(0)
                            $Value = $reader.GetValue(1)
                            Writelog "Database Setting: $Name = $Value"
                            Return $reader.GetValue(1)
                         }
       }
       else {
              Write-Host "the query: $qry `n returned no results"
              WriteLog "the query: $qry `n returned no results"
              }
$SqlConnection.Close()
}

function qrySQLAdaptor{param([string]$qry,[string]$output)
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = $SQLConnectString
    $SqlConnection.Open()
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.CommandText = $qry
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
    $SqlAdapter.SelectCommand = $SqlCmd
    $SqlCmd.Connection = $SqlConnection
    $DataSet = New-Object System.Data.DataSet
    $SqlAdapter.Fill($DataSet)
    $SqlConnection.Close()

    $Results += $DataSet.Tables[0]

    ($Results | Export-Clixml ".\$output")
}

# =========================================================================================
# Main
# =========================================================================================

$Time = Get-Date -Format "HH:mm:ss"
$Date = Get-Date -Format "MM-dd-yyyy"
WriteLog "---------------------------------------------------------------"
WriteLog " script started on: $Date at: $time"
WriteLog "---------------------------------------------------------------"

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic") 

Function Show-InputBox{
 
 [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$Prompt, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Title ="", 
    [Parameter(Position=2, Mandatory=$true)] [string]$Default =""
    ) 
       $EnteredText =  [Microsoft.VisualBasic.Interaction]::InputBox("$Prompt", "$Title", "$Default") 

    if($EnteredText.Length -gt 0) 
    { 
        return $EnteredText 
    }
}

Function Show-MsgBox{
 
 [CmdletBinding()] 
    param( 
    [Parameter(Position=0, Mandatory=$true)] [string]$Msg, 
    [Parameter(Position=1, Mandatory=$true)] [string]$Title =""
   
    ) 
       $EnteredText =  [Microsoft.VisualBasic.Interaction]::MsgBox("$Msg","YesNo,SystemModal", "$Title") 

    if($EnteredText.Length -gt 0) 
    { 
        return $EnteredText 
    }
}
<#
$msgbox = Show-MsgBox -Msg "Is this a new Shopping installation?" -Title "Question?"
if ($msgbox = "yes"){
 "this is a new install"
 $x = New-Install
 $x
 exit
}
#>

$ServerName = Show-InputBox -Prompt "Please enter the server/intance name hosting the Shopping SQL database `r`n example:  `r`n MYSQLSERVER\INSTANCE,PORT `r`n or MYSQLSERVER,PORT `r`n or MYSQLSERVER" -Title "Shopping Database Server or Instance name:?" -Default "(local)"
$DatabaseName = Show-InputBox -Prompt "Please enter the name Shopping database name" -Title "Shopping Database:?" -Default "Shopping2"
#$InstallDir = Show-InputBox -Prompt "Where would you like to Install Shopping?" -Title "Install Directory:?" -Default "C:\Program Files (x86)\1E\Shopping"

if (!$ServerName.Length -eq 0){
        if (!$DatabaseName.Length -eq 0) {
        $SQLConnectString = "Server=$ServerName;Database=$DatabaseName;Trusted_Connection=True"
    }
    else {
    Write-Host "unable to continue due to missing parameters..."
    exit
    }

}
else {
Write-Host "unable to continue due to missing parameters..."
 exit
}

# show the Shopping connect String
$msg = "Shopping SQL ConnectString: $SQLConnectString"
Write-Host $msg
WriteLog $msg

#Make a backup copy of all the preference settings from tb_Preference

$msg = "Backup Preference Table to: $($PSScriptRoot)\PreferencesBackup.xml"
Write-Host $msg
WriteLog $msg

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference UNION ALL SELECT 'SQLServer' as PreferenceName,'$ServerName' as PreferenceValue UNION ALL SELECT 'DatabaseName' as PreferenceName,'$DatabaseName' as PreferenceValue"
qrySQLAdaptor $cmd "PreferencesBackup.xml"


#determine the version of the Shopping database

$cmd = "SELECT TOP 1 SUBSTRING(Version, 1, LEN(Version) - CHARINDEX('.', REVERSE(Version), 0)) as Data FROM  dbo.tb_VersionHistory ORDER BY ID DESC"
$VERSION = qrySQLSingleValue $cmd 

#gather settings for install/re-install

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'AD Server'"
$ADSRV = qrySQLNamedValuePair $cmd 

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'ActiveEfficiency ServerName'"
$AESRV = qrySQLNamedValuePair $cmd 

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Admin Account'"
$ADMIN = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'ConfigMgr Database Access Group'"
$CONSMSUSERS = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'ConfigMgr Central Server Name'"
$SMSServerName = qrySQLNamedValuePair $cmd
#$SMSServerName
$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Full Database Access Group'"
$CONADMINUSERS = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Global License Manager Account'"
$LICMGR = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Limited Database Access Group'"
$CONUSERS = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Receiver Account'"
$RECVACCOUNT = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Reports Account'"
$REPORTS = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Service Account'"
$SVCUSR = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'SMTP Server'"
$SMTP = qrySQLNamedValuePair $cmd

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Web Url'"
$HOSTHDR = qrySQLNamedValuePair $cmd
$HOSTHDR = $HOSTHDR.Split("/")
$HOSTHDR = $HOSTHDR[2]

$cmd = "SELECT PreferenceName,PreferenceValue FROM tb_Preference WHERE PreferenceName = 'Use Global Catalog'"
$USEGLOBALCATALOG = qrySQLNamedValuePair $cmd

#Create a script to install Shopping
$file = "v" + $VERSION + "_Install"
$file

$stream = [System.IO.StreamWriter] "$file.cmd"
    $s = 'SET PK=<replace with your licensekey>'
    $stream.WriteLine($s)
    $s = 'SET SVCPWD=<replace with your Service Password>'
    $stream.WriteLine($s)
    $s = 'REM ------------------------------------------------'
    $stream.WriteLine($s)
    $s = 'REM start shoppping installation'
    $stream.WriteLine($s)
    $s = 'REM ------------------------------------------------'
    $stream.WriteLine($s)
    $s = "msiexec /i ShoppingCentral.msi ACTIVE_DIRECTORY_SERVER=$ADSRV ^"
    $stream.WriteLine($s)
    $s = "InstallDir=""$InstallDir"" ^"
    $stream.WriteLine($s)
    $s = "ADMINACCOUNT=""$ADMIN"" ^"
    $stream.WriteLine($s)
    $s = "AESERVERNAME=$AESRV ^"
    $stream.WriteLine($s)
    $s = "DATABASENAME=$DatabaseName ^"
    $stream.WriteLine($s)
    $s = "IISHOSTHEADER=$HOSTHDR ^"
    $stream.WriteLine($s)
    $s = "INSTALLTYPE=COMPLETE ^"
    $stream.WriteLine($s)
    $s = "LICENSEMGRACCOUNT=""$LICMGR"" ^"
    $stream.WriteLine($s)
    $s = "PIDKEY=%PK% ^"
    $stream.WriteLine($s)
    $s = "RECEIVERACCOUNT=""$RECVACCOUNT"" ^"
    $stream.WriteLine($s)
    $s = "REPORTSACCOUNT=""$REPORTS"" ^"
    $stream.WriteLine($s)
    $s = "SHOPPINGCONSOLEADMINUSERS=""$CONADMINUSERS"" ^"
    $stream.WriteLine($s)
    $s = "SHOPPINGCONSOLESMSUSERS=""$CONSMSUSERS"" ^"
    $stream.WriteLine($s)
    $s = "SHOPPINGCONSOLEUSERS=""$CONUSERS"" ^"
    $stream.WriteLine($s)
    $s = "SHOPPINGURLPREFIX=http://$HOSTHDR ^"
    $stream.WriteLine($s)
    $s = "SMTP_SERVER_NAME=$SMTP ^"
    $stream.WriteLine($s)
    $s = "SQLSERVER=$ServerName ^"
    $stream.WriteLine($s)
    $s = "SMSPROVIDERLOCATION=$SMSServerName ^"
    $stream.WriteLine($s)
    $s = "SVCPASSWORD=%SVCPWD% ^"
    $stream.WriteLine($s)
    $s = "SVCUSER=$SVCUSR ^"
    $stream.WriteLine($s)
    $s= "USEGLOBALCATALOG=$USEGLOBALCATALOG /l*v %TEMP%\$file.log"
    $stream.WriteLine($s)

$stream.close()

$BackupData = (Import-Clixml .\PreferencesBackup.xml)

$BackupData | Out-GridView -Title "Backup of Shopping Preferences"
"script completed" 
#----------------------------------------------------------------------------------------