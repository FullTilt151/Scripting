#https://learn-powershell.net/2014/02/04/using-powershell-parameter-validation-to-make-your-day-easier/
#https://devblogs.microsoft.com/scripting/use-parameter-sets-to-simplify-powershell-commands/
#Requires -Version <N>[.<n>]
#Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]
#Requires -Modules { <Module-Name> | <Hashtable> }
#Requires -PSEdition <PSEdition-Name>
#Requires -ShellId <ShellId>
#Requires -RunAsAdministrator

#Install-Module -Name SqlServer -RequiredVersion 21.1.18080
[CmdletBinding(ConfirmImpact=<String>,
DefaultParameterSetName=<String>,
HelpURI=<URI>,
SupportsPaging=<Boolean>,
SupportsShouldProcess=<Boolean>,
PositionalBinding=<Boolean>)]

Param(
	[Parameter(Mandatory = $true, ParameterSetName = 'SetName')]
		[ValidateSet('Tom','Dick','Jane')] 
		[ValidateNotNull()]
		[ValidateNotNullOrEmpty()]
		[ValidateRange(21,65)] 
		[ValidateScript({Test-Path $_ -PathType 'Container'})] 
		[ValidateLength(1,8)]
		[ValidateCount(1,4)]
		[ValidatePattern('^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')]
        [String]$Name 
    ) 

[System.Management.ManagementDateTimeConverter]::ToDmtfDateTime($DateTime) #Converts Date/Time string to DMTF format
[System.Management.ManagementDateTimeConverter]::ToDateTime($DateTime) #Converts DMTF to Date/Time format
[System.IO.Directory]::CreateDirectory("C:\test") #Creates directory - https://devblogs.microsoft.com/scripting/learn-four-ways-to-use-powershell-to-create-folders/
[regex]::Replace($text,'(?<SingleQuote>'')','${SingleQuote}''') #Converts text with single ' to double ' for SQL queries etc.
[regex]::Replace($text,'(?<SingleQuote>'')','\${SingleQuote}') #Converts text with single ' to WMI \'
[bool](get-member -InputObject $TestOBJ -name 'Nope' -MemberType Properties) #Test for existance of a property on PSObject
[IO.Path]::GetTempFileName()
[convert]::ToString($number,16)
[convert]::ToString($number,10)
[convert]::ToString($number,2)

# Signing a script
$FileName = 'd:\Projects\SCCm\SKPSWI_Dat_Remediate.ps1'
Set-AuthenticodeSignature $FileName @(Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0]
$CollectionSettings = New-CimInstance -CimSession ($sccmConnectionInfo.CimSession) -Namespace ($sccmConnectionInfo.NameSpace) -ClassName SMS_CollectionSettings -Property @{
	CollectionID = ($collectionObj.CollectionID)
}

# Create a SMS_CollectionRuleQuery in memory, to do that, we first need a copy of the class from the site server.
$smsCollectionRuleClass = Get-CimClass -CimSession ($sccmConnectionInfo.CimSession) -Namespace ($sccmConnectionInfo.NameSpace) -ClassName SMS_CollectionRuleQuery

# Now that we have a copy of the class, we can create a temporary one in memory (because of the -ClientOnly switch) for the rule.
$queryMemberRule = New-CimInstance -ClientOnly -CimClass $smsCollectionRuleClass -Property @{
	QueryExpression = $colQuery;
	RuleName        = $ruleName;
}