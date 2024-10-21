<#
Script: OrderHistoryCleanup.ps1
Requirements: Works with Shopping v5.5 or above.
Version: 1.0
Created: 2/5/2020


Purpose:  this script is designed to purge excess records and keep the most recent one for each OrderId in the tb_OrderHistory table
Requirements: must run from the Shopping Central Server

<# 
1E Ltd Copyright 2020

 Disclaimer:
 Your use of this script is at your sole risk. This script is provided "as-is", without any warranty, whether express 
 or implied, of accuracy, completeness, fitness for a particular purpose, title or non-infringement, and is not
 supported or guaranteed by 1E. 1E shall not be liable for any damages you may sustain by using this script, whether
 direct, indirect, special, incidental or consequential, even if it has been advised of the possibility of such damages.
#>
$regValue = Get-ItemProperty -Path HKLM:\Software\Wow6432Node\1E\ShoppingCentral -Name InstallationDirectory
if ($regValue.InstallationDirectory -ne ""){
    $installDir = $regValue.InstallationDirectory 
    $installdir = $installDir -replace '\\CentralService',''
    #$installDir
}
else {
"unable to determine the InstallationDirectory Path"
exit
}

# we need the SQL ConnectionString
$appConfigFile= "$InstallDir" + "Centralservice\ShoppingCentral.exe.config"
$appConfig = New-Object XML
# load the config file as an xml object
$appConfig.Load($appConfigFile)
$ConnectionString = $appConfig.Configuration.appSettings.add | where { $_.key -eq "ConnectionString" }
$ConnectString = $ConnectionString.value
"SQL ConnectionString is: $ConnectString"

try {
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.Connection=New-Object System.Data.SqlClient.SqlConnection
$SqlCmd.Connection.ConnectionString=$ConnectString
$SqlCmd.Connection.Open()
}
catch {
"unable to open SQL connection , quiting"
   $_.Exception.Message
   $_.Exception.ItemName
    
    exit 
}

$qryDistinctOrders = @"
SELECT  DISTINCT OrderId FROM tb_OrderHistory
"@
    $SqlCmd.CommandText=$qryDistinctOrders
    $SqlCmd.CommandTimeout = 0
    $rows = $SqlCmd.ExecuteReader()

$i = 0

foreach ($row in $rows){

$qryDeleteHistory = @"
DELETE tb_OrderHistory
WHERE Id NOT IN(SELECT Max([Id]) FROM tb_OrderHistory WHERE OrderId = $($row[0].ToString()))
AND OrderId = $($row[0].ToString())
"@
#Write-Progress -Activity 'Purging OrderHistory' -Status "Clearing extra records->" -PercentComplete $i -CurrentOperation "purging OrderId: $($row[0].Tostring())"
#Write-Host $qryDeleteHistory
#sleep -Milliseconds 500

$SqlCmd1 = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd1.Connection=New-Object System.Data.SqlClient.SqlConnection
$SqlCmd1.Connection.ConnectionString=$ConnectString
$SqlCmd1.Connection.Open()
 "Purging excessive order history records for OrderId: $($row.Item(0))"
 $SqlCmd1.CommandTimeout = 0
 $SqlCmd1.CommandText =$qryDeleteHistory
 [void]$SqlCmd1.ExecuteNonQuery()
 $i++
}
