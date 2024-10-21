param(
$SiteServer = "LOUAPPWPS875",
$SiteCode = "CAS"
)

# Define path to create export file
$ExportFilePath = "c:\temp\SavedSearchExport.csv"

# Query SMS provider for saved search entries
$savedSearchObjects = Get-WmiObject -Computer $SiteServer -Namespace "root\sms\site_$($SiteCode)" -Query "select * from SMS_SearchFolder where ObjectType='1011'"

# Export results as CSV with Name, ObjectType, and SearchString definition
$exportObjects = $savedSearchObjects | select Name,ObjectType,SearchString
$exportObjects | Export-Csv $ExportFilePath -NoTypeInformation