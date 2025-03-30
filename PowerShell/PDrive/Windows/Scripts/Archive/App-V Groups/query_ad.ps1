import-module activedirectory

$listgroups = get-adgroup -filter "*" -searchbase "OU=software distribution,DC=HUMAD, DC=COM" | select name | sort name

$groupname

get-adgroupmember $groupname | select name,samaccountname