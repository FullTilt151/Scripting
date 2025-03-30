param(
[parameter(Mandatory=$true)]
[ValidateSet('10.0 (14393)','10.0 (15063)','10.0 (16299)','10.0 (17134)','10.0 (17763)')]
$OSBuild,
[parameter(Mandatory=$true)]
[ValidateSet('Add','Remove')]
$Purpose
)

$i = 0

switch ($Purpose) {
    'Add' {
        # Add necessary WKIDs
        $WKIDs = Get-ADComputer -Filter "OperatingSystemVersion -eq '$OSBuild'" -Properties Name -SearchBase 'OU=Workstations,DC=humad,DC=com' -SearchScope Subtree 
        $WKIDs | ForEach-Object {
            $Groups = Get-ADPrincipalGroupMembership -Identity $_ | Select-Object -ExpandProperty Name
            if ('T_Windows10IPU' -notin $Groups) {
                Add-ADGroupMember -Identity T_Windows10IPU -Members $_ -Confirm:$false
                $i++
            }
        }
    }
        
    'Remove' {
        # Remove unnecessary WKIDs
        $GroupMembers = Get-ADGroup -Identity 'T_Windows10IPU' -Properties Members | Select-Object -ExpandProperty Members
        $GroupMembers | ForEach-Object {
            $WKID = $_.split(',')[0].replace('CN=','')
            $Build = Get-ADComputer -Identity $WKID -Properties OperatingSystemVersion | Select-Object -ExpandProperty OperatingSystemVersion
            if ($Build -ne $OSBuild) {
                $ADObject = Get-ADObject -Filter "Name -eq '$WKID'"
                Remove-ADGroupMember -Identity T_Windows10IPU -Members $ADObject -Confirm:$false
                $i++
            }
        }
    }
}

Write-Output "Modified $i computers."