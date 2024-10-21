param(
[Parameter(Mandatory=$true)]
[ValidateSet('HUMAD','LOUTMS')] 
$Domain
)

if($Domain -eq 'HUMAD') {
    $Server = 'SIMADMWPS06.humad.com'
    $SearchBase = 'DC=HUMAD,DC=com'
} elseif ($Domain -eq 'LOUTMS') {
    $Server = 'LOUADMWTS01.loutms.tree'
    $SearchBase = 'DC=loutms,DC=tree'
}

# Disabled computers never logged on
Search-ADAccount -AccountDisabled -ComputersOnly -SearchBase $SearchBase -Server $Server | Where-Object {$_.LastLogonDate -eq $null} | Format-Table Enabled, Name, DistinguishedName, LastLogonDate -AutoSize

# Disabled computers with logged on date
Search-ADAccount -AccountDisabled -ComputersOnly -SearchBase $SearchBase -Server $Server | Where-Object {$_.LastLogonDate -ne $null} | Format-Table Enabled, Name, DistinguishedName, LastLogonDate -AutoSize

# All computers logged on > 365 days
Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan 365 -SearchBase $SearchBase -Server $Server | Where-Object {$_.LastLogonDate -ne $null} | Format-Table Enabled, Name, DistinguishedName, LastLogonDate -AutoSize

# All computers never logged on > 90 days
Search-ADAccount -AccountInactive -ComputersOnly -TimeSpan 1 -SearchBase $SearchBase -Server $Server | Where-Object {$_.LastLogonDate -eq $null} | Format-Table Enabled, Name, DistinguishedName, LastLogonDate -AutoSize
Get-ADComputer -Properties DistinguishedName, Created -Filter {Created -gt '30'}

# All computers created > 1 year
$YearOld = (Get-Date) - (New-TimeSpan -Days 365) | Get-Date -UFormat %m/%d/%Y
$YearOld = ([datetime]$YearOld).Date
Get-ADComputer -Filter {WhenCreated -lt $YearOld} -Properties WhenCreated -SearchBase $SearchBase -Server $Server | Sort-Object WhenCreated | Format-Table DistinguishedName, Name, WhenCreated -AutoSize

# Disable-ADAccount
# Remove-ADObject

#OU=Computers,OU=LOU,DC=humad,DC=com

Get-ADComputer -Filter {OperatingSystem -eq 'Windows XP Professional'} -Properties Name, OperatingSystem, LastLogonDate | export-csv c:\temp\xp.csv