<#
LOUCMFWPB & SIMCMFWPB	Non-persistent servers
ILO & USE	Standard server name before image applied
AWS 	Amazon Web Services servers (Not Humana Managed)
Pharmacy	Pharmacy Servers
 ESX Hosts	Do not get Compliance Agents
AIX Appliances	Do not get Compliance Agents
Virtual Image	Virtual Image Servers
Linux (only for SCCM)	Cannot have SCCM but does have ePO
LOUCMFWPG01P on the TS Domain	Non-Persistent
LOUCMFWPG01V on the TS Domain	Non-Persistent
LOUCMFWPG01U on the TS Domain	Non-Persistent

Column 1 - Asset Name (WKID)
Column 2 - Asset Family
Column 3 - Class (OS)
Column 18 - IP Address
#>

Function Test-CMNClient
{
	[CmdletBinding(SupportsShouldProcess = $true,
		ConfirmImpact = 'Low')]
    Param
	(
		[Parameter(Mandatory = $true,
            Helpmessage = 'Machine to check')]
        [String]$Server,

        [Parameter(Mandatory = $false,
            HelpMessage = 'IPAddress to add')]
		[string]$IPAddress = 'None',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Maintenance window for server')]
		[String]$OS = 'None',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Person Making the change')]
		[String]$Domain = 'None',

		[Parameter(Mandatory =  $false,
			HelpMessage = 'RemediationTeam')]
		[String]$RemediationTeam = 'None',

		[Parameter(Mandatory = $false,
			HelpMessage = 'Source of information')]
		[String]$Source = 'None'
	)
	$WMIQueryParametersSP1 = @{
		ComputerName = 'LOUAPPWPS1825';
		NameSpace = 'Root/SMS/Site_SP1';}
	$WMIQueryParametersSQ1 = @{
		ComputerName = 'LOUAPPWQS1150';
		NameSpace = 'Root/SMS/Site_SQ1';}
	$WMIQueryParametersWP1 = @{
		ComputerName = 'LOUAPPWPS1658';
		NameSpace = 'Root/SMS/Site_WP1';}
	$WMIQueryParametersWQ1 = @{
		ComputerName = 'LOUAPPWQS1151';
		NameSpace = 'Root/SMS/Site_WQ1';}
	$WMIQueryParametersMT1 = @{
		ComputerName = 'LOUAPPWTS1140';
		NameSpace = 'Root/SMS/Site_MT1';}
	$Message = New-Object PSObject
	$Message | Add-Member -MemberType NoteProperty -Name 'Server' -Value $Server.ToUpper()
	if($Server -match '…CMFWPB.*'){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'Non-persistent servers'}
	elseif($Server -match '...ESX.*'){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'ESX Host'}
	elseif($Server -match '...CMFWPG01[PVU].*'){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'Non-Persistent'}
	elseif($RemediationTeam -eq 'AIX'){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'AIX'}
	elseif($RemediationTeam -eq 'AWS Cloud Server'){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'AWS'}
	elseif($OS -eq 'Linux'){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'Linux'}
	elseif($Domain -eq 'RX1AD'){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'Pharmacy'}
	else
	{
		$query = "Select * from SMS_R_System where NetBiosName = '$server' and Client =  1"
		$deviceSP1 = Get-WmiObject -Query $query @WMIQueryParametersSP1
		$deviceSQ1 = Get-WmiObject -Query $query @WMIQueryParametersSQ1
		$deviceWP1 = Get-WmiObject -Query $query @WMIQueryParametersWP1
		$deviceWQ1 = Get-WmiObject -Query $query @WMIQueryParametersWQ1
		$deviceMT1 = Get-WmiObject -Query $query @WMIQueryParametersMT1
		if($deviceSP1 -or $deviceSQ1 -or $deviceWP1 -or $deviceWQ1 -or $deviceMT1)
		{
			if($deviceSP1){$Message | Add-Member -MemberType NoteProperty -Name 'Client' -Value 'SP1'}
			elseif($deviceSQ1){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'SQ1'}
			elseif($deviceWP1){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'WP1'}
			elseif($deviceWQ1){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'WQ1'}
			elseif($deviceMT1){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'MT1'}
			else{Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Client' -Value 'Error'}
		}
		else{$Message | Add-Member -MemberType NoteProperty -Name 'Client' -Value 'No Client'}
	}
	
	if($Server.Length -gt 7){Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Environment' -Value $Server.Substring(7,1).ToUpper()}
	else{Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Environment' -Value 'UnKnown'}
	Add-Member -InputObject $Message -MemberType NoteProperty -Name 'IPAddress' -Value $IPAddress
	Add-Member -InputObject $Message -MemberType NoteProperty -Name 'OS' -Value $OS
	Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Domain' -Value $Domain
	Add-Member -InputObject $Message -MemberType NoteProperty -Name 'RemediationTeam' -Value $RemediationTeam
	Add-Member -InputObject $Message -MemberType NoteProperty -Name 'Source' -Value $Source
	Return $Message
}
[CmdletBinding(SupportsShouldProcess = $true,
	ConfirmImpact = 'Low')]

$SharePointServers = ('LOUAFPWTS01','LOUAFSWTS03','LOUAFSWTS04','LOUAPPWTL07S01','LOUAPPWTS133','LOUAPPWTS849','LOUMILWTL01S01','LOUMILWTL01S02','LOUSQLWTS233','LOUSQLWTS462','LOUWEBWTL11S01','LOUWEBWTL11S02','LOUWEBWTL14S01','LOUWEBWTS121','LOUWEBWTS122','LOUWEBWTS233','LOUAFPWQL01S01','LOUAFPWQL01S02','LOUAFSWQL01S01','LOUAFSWQL01S02','LOUAFSWQL02S01','LOUAFSWQL02S02','LOUAPPWQL15S01','LOUAPPWQL15S02','LOUAPPWQL180S01','LOUAPPWQL180S02','LOUAPPWQL180S03','LOUAPPWQL180S04','LOUAPPWQL180S05','LOUAPPWQL180S06','LOUAPPWQL181S01','LOUAPPWQL182S01','LOUAPPWQL219S01','LOUAPPWQL219S02','LOUSQLWQS233','LOUSQLWQS446','LOUWEBWQL180S01','LOUWEBWQL180S02','LOUWEBWQL189S01','LOUWEBWQL189S02','LOUWEBWQL92S01','LOUWEBWQL92S02','LOUAPPWPL17S01','LOUAPPWPL180S01','LOUAPPWPL180S03','LOUAPPWPL180S05','LOUAPPWPL181S01','LOUAPPWPL181S03','LOUAPPWPL181S05','LOUAPPWPL217S01','LOUAPPWPL217S03','LOUAPPWPL85S01','LOUMILWPL05S01','LOUSQLWPS148','LOUSQLWPS483','LOUWEBWPL08S01','LOUWEBWPL136S01','LOUWEBWPL148S01','LOUWEBWPL148S03','LOUWEBWPL180S01','LOUWEBWPL180S03','LOUWEBWPL180S05','LOUWEBWPL180S07','LOUAFPWPL03S02','LOUAFSWPL03S02','LOUAFSWPL04S02','LOUAPPWPL17S02','LOUAPPWPL180S02','LOUAPPWPL180S04','LOUAPPWPL180S06','LOUAPPWPL181S02','LOUAPPWPL181S04','LOUAPPWPL181S06','LOUAPPWPL217S02','LOUAPPWPL85S02','LOUMILWPL05S02','LOUWEBWPL08S02','LOUWEBWPL136S02','LOUWEBWPL148S02','LOUWEBWPL180S02','LOUWEBWPL180S04','LOUWEBWPL180S06','LOUWEBWPL180S08','SIMDEVWDS043','SIMDEVWDS424','LOUWEBWTL146S01','LOUWEBWTL146S02','LOUWEBWTL147S01','LOUWEBWTL147S02','LOUWEBWQL146S01','LOUWEBWQL146S02','LOUWEBWPL146S01','LOUWEBWPL146S02','LOUWEBWIS27','LOUAPPWTL117S01','LOUAPPWTL117S02','LOUAPPWTL118S01','LOUAPPWTL118S02','LOUAPPWQL117S01','LOUAPPWQL117S02','SIMDEVWDS425','LOUAPPWIS11','LOUAPPWPL117S01','LOUAPPWPL117S02')
$Files = ('e:\SP1 Migration\LTL.xlsx')
$excel = New-Object -com excel.application
$outFile = 'e:\SP1 Migration\LTL.csv'

if(Test-Path $outFile){Remove-Item $outFile}
& CMTrace.exe $outFile

#We assume the first row is headers, so we skip.
Foreach($File in $Files)
{
	Write-Verbose "Opening $File"
	$excel.Visible = $false
    $workbook = $excel.workbooks.open($File)
	$sheet = $workbook.Sheets.Item(1)
	$source = Split-Path -Path $File -Leaf
	Write-Output "Scanning $File"
	$totalRows = $sheet.UsedRange.Rows.Count-1
	For($y=2;$y -le $sheet.UsedRange.rows.Count;$y++)
	{
		Write-Progress -ID 1 -Activity 'Scanning Sheet' -Status 'Progress->' -PercentComplete (($y / $sheet.UsedRange.Rows.Count) * 100) -CurrentOperation "$y /$($sheet.UsedRange.Rows.Count)"
		$Server = $Sheet.Cells.Item($y,1).Value2
		$IPAddress = $Sheet.Cells.Item($y,7).Value2 # IP Address
		$OS = $sheet.Cells.Item($y,4).Value2 # Class (OS)
		$Domain = $sheet.Cells.Item($y,6).Value2 # ADC (Domain)
		$RemediationTeam = $sheet.Cells.Item($y,3).Value2
		Write-Verbose "Server =  $Server on row $y of $File"
		if($Server -match ' '){Write-Host -ForegroundColor Red "$Server Name Invalid"}
		#elseif($SharePointServers -contains $Server){Write-Host -ForegroundColor DarkGreen "$Server is a sharepoint server"}
		else{Test-CMNClient -Server $Server -IPAddress $IPAddress -OS $OS -Source $source -Domain $Domain -RemediationTeam $RemediationTeam | Export-Csv -Path $outFile -Encoding ASCII -Append -NoTypeInformation -Force}
	}
	Write-Progress -ID 1 -Activity 'Scanning Sheet' -Completed
	$Workbook.Close($false)
}
$Excel.Quit()