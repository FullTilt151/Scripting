<#
	WMI Classes related to security: https://msdn.microsoft.com/en-us/library/hh949628.aspx
		SMS_Admin - Lists Admin Users
		SMS_AdminCategory
		SMS_AdminRole
		SMS_ARoleOperation
		SMS_AssociatedSecuredCategory
		SMS_LastCategoryObject
		SMS_Operation
		SMS_Permission - Links AdminID, CategoryID, TypeID, and RoleID
		SMS_RbacSecuredObject
		SMS_Roles - List Roles
		SMS_SecuredCategory
		SMS_SecuredCategoryMembership
		SMS_SettableSecuredCategory
#>

PARAM
(
	[Parameter(Mandatory=$true,HelpMessage='Name of SCCM Site Server')]
	[String]$SiteServer,
    #Parameters in script for New-LogEntry
    [Parameter(Mandatory=$false,HelpMessage="Sets the Log Level, 1 - Informational, 2 - Warning, 3 - Error")]
    [Int32]$LogLevel = 1,
    [Parameter(Mandatory=$false,HelpMessage="Log File Directory")]
    [String]$LogFileDir = 'C:\Temp\',
    [Parameter(Mandatory=$false,HelpMessage="Clear any existing log file")]
    [Switch]$ClearLog
)

Function Get-CMNGroupMemberCount
{
    Param
    (
		[Parameter(Mandatory=$True)]
		[String]$GroupName
    )
	[Int]$Count = 0
	$GroupMembers = Get-ADGroupMember ($GroupName)
	foreach($GroupMember in ($GroupMembers | Where-Object {$_.objectClass -eq 'group'}))
	{
		$Count += Get-CMNGroupMemberCount $GroupMember.Name
	}
	$Count += ($GroupMembers | Where-Object {$_.objectClass -eq 'user'}).Count
    return $Count
}

#Begin New-LogEntry Function
Function New-LogEntry 
{
    # Writes to the log file
    Param
    (
        [Parameter(Position=0,Mandatory=$true)]
        [String] $Entry,
               
        [Parameter(Position=1,Mandatory=$false)]
        [INT32] $type = 1,
       
        [Parameter(Position=2,Mandatory=$false)]
        [String] $component = $ScriptName
    )
    Write-Verbose $Entry
    if ($type -ge $Script:LogLevel)
    {
        if ($Entry.Length -eq 0)
        {
            $Entry = 'N/A'
        }
        $TZOffset = ([TimeZoneInfo]::Local).BaseUTcOffset.TotalMinutes
        $TZOffset = "$(Get-Date -Format "HH:mm:ss.fff")+$(-$TZOffset)"
        $Entry = "<![LOG[{0}]LOG]!><time=""{2}"" date=""{1}"" component=""{5}"" context="""" type=""{4}"" thread=""{3}"">" -f $Entry, (Get-Date -Format "MM-dd-yyyy"), $TZOffset, $pid, $type, $component
        $Entry | Out-File $Script:LogFile -Append -Encoding ascii
    }
}
#End New-LogEntry

#Build variables for New-LogEntry Function
         
$ScriptName = $MyInvocation.MyCommand.Name
if(-not ($LogFileDir -match '\\$')){$LogFileDir = "$LogFileDir\"}
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'
$LogFile = $LogFileDir + $LogFile + '.log'
if($ClearLog)
{
    if(Test-Path $Logfile) {Remove-Item $LogFile}
}

$SiteCode = $(Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode

$WMIQueryParameters = @{
    ComputerName = $SiteServer
    Namespace = "root\sms\site_$SiteCode"
}

$OutputFile = 'C:\Temp\Permissions.txt'

$Admins = Get-CimInstance -ClassName SMS_Admin @WMIQueryParameters

if(Test-Path $OutputFile){Remove-Item $OutputFile}

foreach($Admin in $Admins)
{
    New-LogEntry "Working on $($Admin.LogonName)"
    $NumMembers = Get-CMNGroupMemberCount ($Admin.LogonName -replace '.*\\(.*)', '$1')
    if($NumMembers)
    {
        New-LogEntry "$($Admin.LogonName) has $NumMembers members"
        "$($Admin.LogonName) has $NumMembers members" | Out-File $OutputFile -Append
    }
    New-LogEntry "$($Admin.LogonName) is a member of the following roles:"
    "$($Admin.LogonName) is a member of the following roles:" | Out-File $OutputFile -Append
    foreach($Role in $Admin.RoleNames)
    {
        New-LogEntry "`t$Role"
        "`t$Role" | Out-File $OutputFile -Append
    }
    New-LogEntry "$($Admin.LogonName) can use these permissions on the following collections:"
    "$($Admin.LogonName) can use these permissions on the following collections:" | Out-File $OutputFile -Append
    foreach($Collection in $Admin.CollectionNames)
    {
        New-LogEntry "`t$Collection"
        "`t$Collection" | Out-File $OutputFile -Append
    }
    New-LogEntry " "
    " " | Out-File $OutputFile -Append
}