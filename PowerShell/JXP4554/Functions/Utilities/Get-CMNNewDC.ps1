#dsquery * "ou=domain controllers,dc=humad,dc=com" -filter "(objectClass=Computer)" -attr name whencreated -l -d dom.com

$strFilter = "(&(objectClass=Computer))"

$objDomain = New-Object System.DirectoryServices.DirectoryEntry
$objOU = New-Object System.DirectoryServices.DirectoryEntry("LDAP://OU=domain controllers,dc=humad,dc=com")
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objOU
$objSearcher.PageSize = 1000
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "OneLevel"

$colProplist = "whencreated"
foreach ($i in $colPropList){$objSearcher.PropertiesToLoad.Add($i)}

$colResults = $objSearcher.FindAll()

foreach ($objResult in $colResults)
{
    #$objItem = $objResult.Properties; $objItem.name
    if($objResult.Properties['whencreated'] -ge (Get-Date).AddDays(-3))
    {
        Write-Output "$($objResult.Path) - $($objResult.Properties['whencreated'])"
    }
}