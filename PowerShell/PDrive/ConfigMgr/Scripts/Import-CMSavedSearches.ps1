param(
$SiteServer = "LOUAPPWPS1825",
$SiteCode = "SP1"
)

# Define path to exported CSV file with saved searches from source system
$savedSearchExportCSV = "C:\temp\SavedSearchExport.csv"

###

# Parse CSV file into object per row
$importObjects = Import-Csv $savedSearchExportCSV

# Process each entry from file
foreach($entry in $importObjects)
{
    # Check if an existing saved search already exists by matching name. If so, skip import. Otherwise, create a new saved search.
    $matchingSearch = Get-WmiObject -ComputerName $SiteServer -Namespace "root\SMS\Site_$($SiteCode)" -Query "select * from SMS_SearchFolder where Name='$($entry.Name)'"
    if($null -eq $matchingSearch)
    {
        Write-Host "Importing saved search entry:" $entry.Name
        Set-WmiInstance -ComputerName $SiteServer -Namespace "root\SMS\Site_$($SiteCode)" -Class 'SMS_SearchFolder' -Arguments  @{
                Name = $entry.Name
                ObjectType = $entry.ObjectType
                SearchString = $entry.SearchString
            } | Out-Null
    }
    else
    {
        Write-Host "***Skipping existing saved search entry:" $entry.Name
    }
}