<#
Script: ProcessDeleteMarkedEntries.ps1
Requirements: Works with Shopping v5.4 or above.
Version: 1.2
Created: 1/3/2019

Purpose:  this script is intended to be setup as a scheduled job to run once a day and proactively clean up applications which may not have been properly removed,
it goes thru Applications one by one and removes all refererences from all tables 
Run From: The script reads data from the Shopping web servers registry to get the installationdirectory and then to obtain SQL connection details for the SQL database hosting shopping.

# 1E Ltd Copyright 2018
# 
# Disclaimer:
# Your use of this script is at your sole risk. This script is provided "as-is", without any warranty, whether express 
# or implied, of accuracy, completeness, fitness for a particular purpose, title or non-infringement, and is not
# supported or guaranteed by 1E. 1E shall not be liable for any damages you may sustain by using this script, whether
# direct, indirect, special, incidental or consequential, even if it has been advised of the possibility of such damages.
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

$qryMarkedForDeletion = @"
SELECT ApplicationId from tb_Application WHERE MarkedForDeletion = 1 AND RequestItemType <> 'APS' -- Do not delete App Sets
"@
    $SqlCmd.CommandText=$qryMarkedForDeletion
    $SqlCmd.CommandTimeout = "600"
    $rows = $SqlCmd.ExecuteReader()

$qryDeleteApp = @"
-- Extract application Ids from the image
DECLARE @ApplicationIds TABLE
(
    ApplicationId BIGINT NOT NULL
)

INSERT INTO @ApplicationIds SELECT TOP 1 ApplicationId FROM tb_Application WHERE MarkedForDeletion = 1 AND RequestItemType <> 'APS' -- Do not delete App Sets
    
-- Remove applications from uninstalls
DELETE FROM    dbo.tb_Uninstalls
WHERE    UninstallId IN (
            SELECT    UninstallId
            FROM    dbo.tb_Applications_Uninstalls
            WHERE    ApplicationId IN (SELECT ApplicationId FROM @ApplicationIds))
            
DELETE FROM dbo.tb_Applications_Uninstalls WHERE ApplicationId IN (SELECT ApplicationId FROM @ApplicationIds)
 
-- Remove History from Processing
DELETE FROM tb_Processing WHERE ProcessingId IN
(
    SELECT    P.ProcessingId
    FROM    tb_Processing P
                INNER JOIN @ApplicationIds A ON P.ApplicationID = A.ApplicationId
)

-- Remove History FROM Basket
DELETE FROM tb_Basket WHERE ApplicationID IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Delete from the RentalSettings Table
DELETE FROM [tb_RentalSettings] WHERE RentalSettingsId IN
(
    SELECT RentalSettings FROM tb_Application WHERE MarkedForDeletion = 1
)

DELETE FROM tb_AdvertisedItem WHERE RequestItemId IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Delete from ApplicationContent
DELETE FROM tb_ApplicationContent WHERE ApplicationId IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Delete from WsaOrder table
IF OBJECT_ID('tb_WsaOrder', 'U') IS NOT NULL 
BEGIN
DELETE FROM tb_WsaOrder WHERE DeploymentId IN
(
    SELECT ApplicationId FROM @ApplicationIds
)
END 
-- Delete from Application_WSDDetails
IF OBJECT_ID('tb_Application_WSDDetails', 'U') IS NOT NULL 
BEGIN
DELETE FROM tb_Application_WSDDetails WHERE Id IN
(
    SELECT ApplicationId FROM @ApplicationIds
)
END 
-- Delete from ReviewHelpful table
DELETE FROM tb_ReviewHelpful WHERE UserApplicationRatingId IN
(
    SELECT UserApplicationRatingId FROM dbo.tb_UserApplicationRating
    WHERE ApplicationId IN (SELECT ApplicationId FROM @ApplicationIds)
)

-- Delete from UserApplicationRating table
DELETE FROM tb_UserApplicationRating WHERE ApplicationId IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Delete from ApplicationAvgRating table
DELETE FROM tb_ApplicationAvgRating WHERE ApplicationId IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Delete from OSDWizard table
DELETE FROM tb_OsdWizard WHERE RequestItemId IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Delete from OsdRecommendedItemsMapping  table
DELETE FROM tb_OsdRecommendedItemsMapping WHERE TargetRequestItem IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Delete from OsdRecommendedItem  table
DELETE FROM tb_OsdRecommendedItem WHERE ApplicationId IN
(
    SELECT ApplicationId FROM @ApplicationIds
)

-- Remove the Application
DELETE FROM tb_Application WHERE ApplicationId IN 
(
 SELECT ApplicationId FROM @ApplicationIds
)
"@
foreach ($row in $rows){
$SqlCmd1 = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd1.Connection=New-Object System.Data.SqlClient.SqlConnection
$SqlCmd1.Connection.ConnectionString=$ConnectString
$SqlCmd1.Connection.Open()
 "removing ApplicationId: $($row.Item(0))"
 $SqlCmd1.CommandText = $qryDeleteApp
 [void]$SqlCmd1.ExecuteNonQuery()
}