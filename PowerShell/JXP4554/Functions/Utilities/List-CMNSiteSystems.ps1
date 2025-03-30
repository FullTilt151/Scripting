
<#
.Synopsis
    Creates an Excel spreadsheet listing all your site servers and their roles.

.DESCRIPTION
    This script will create an Excel spreadsheet listing all your site servers and current roles.
    It will also show the total number of roles heald by each server on the last column and the
    total number of servers holding each role along the last row.

.PARAMETER SiteServer
    This is the SMSProvider for the site you are after

.PARAMETER LogLevel
    This is the minimum logging level you want for the logfile, nothing below this level will be logged. It defaults to 2. The levels are:
    1 - Informational
    2 - Warning
    3 - Error

.PARAMETER LogFileDir
    This is the directory where the log will be created. It defaults to C:\Temp

.EXAMPLE
    List-SiteSystems -SiteServer SCCM01

    This will list all the site systems from the site server SCCM01

.LINK
    http://configman-notes.com

.NOTES
    9/10/2015 - Created script
#>


[CmdletBinding(SupportsShouldProcess = $true)]
Param(
	[Parameter(Mandatory = $true, HelpMessage = "Site server where the SMS Provider is installed")]
	[ValidateScript( { Test-Connection -ComputerName $_ -Count 1 -Quiet })]
	[String]$SiteServer,
	[Parameter(Mandatory = $false, HelpMessage = "Background color, defaults to 15849925")]
	[int32]$BackGroundColor = 15849925,
	[Parameter(Mandatory = $false, HelpMessage = "Log File Directory")]
	[String]$LogFileDir = 'C:\Temp\',
	[Parameter(Mandatory = $false, HelpMessage = "Clear existing log file")]
	[Switch]$ClearLog
)

#Build variables for New-CMNLogEntry Function
#First, get the script name         
$ScriptName = $MyInvocation.MyCommand.Name

#Next, make sure the LogFileDir has the \ at the end, if not, put it there
if (-not ($LogFileDir -match '\\$')) {
	$LogFileDir = "$LogFileDir\"
}

#Now, take that script name and get rid of the .ps1 at the end
$LogFile = $ScriptName -replace '(.*)\.ps1', '$1'

#Finally, put the two together to get the log file name.
$LogFile = $LogFileDir + $LogFile + '.log'
if ($ClearLog) {
	if (Test-Path $Logfile) {
		Remove-Item $LogFile
	}
}

$NewLogEntry = @{
	logFile    = $logFile;
	component  = 'List-CMNSiteSystems';
	maxLogSize = 5242880;
	maxLogHistory = 5;
}

New-CMNLogEntry -entry 'Starting Script' -type 1 @NewLogEntry
New-CMNLogEntry -entry "SiteServer - $SiteServer" -type 1 @NewLogEntry
New-CMNLogEntry -entry "Importing SCCM Module from $($Env:SMS_ADMIN_UI_PATH.Substring(0,$Env:SMS_ADMIN_UI_PATH.Length-5) + '\ConfigurationManager.psd1')" -type 1 @NewLogEntry

#SCCM Import Module
Import-Module ($Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + '\ConfigurationManager.psd1')

New-CMNLogEntry -entry 'Getting SiteCode' -type 1 @NewLogEntry

$SiteCode = (Get-WmiObject -ComputerName $SiteServer -Namespace 'root\SMS' -Class SMS_ProviderLocation).SiteCode | Select-Object -Unique
if (-not [string]::IsNullOrWhiteSpace($SiteCode)) {
	New-CMNLogEntry -entry "Success! It's $SiteCode" -type 1 @NewLogEntry
}
else {
	New-CMNLogEntry -entry "Failed to identify sitecode based on SiteServer $SiteServer" -type 3 @NewLogEntry
}

#Save the directory we are in to the stack so we can get back there when we are done.
Push-Location
Set-Location "$($SiteCode):"

New-CMNLogEntry -entry 'Creating Excel SpreadSheet' -type 1 @NewLogEntry

$objExcel = New-Object -ComObject Excel.Application
$objExcel.Visible = $true
$objWorkBook = $objExcel.Workbooks.Add()
$objWorkSheet = $objWorkBook.Worksheets.Item(1)

New-CMNLogEntry -entry 'Getting Site System Roles' -type 1 @NewLogEntry

$Roles = @() #Intitialize the array
$Roles = $(Get-CMSiteRole).RoleName | Sort-Object -Unique #This will get all the unique roles used in the site and sort them

New-CMNLogEntry -entry 'Filling out spreadhseet header' -type 1 @NewLogEntry

$objExcel.cells.item(1, 1) = 'Server Name' #Text
$objExcel.cells.item(1, 2) = 'Site Code' #Text

New-CMNLogEntry -entry 'Adding the roles to the header' -type 1 @NewLogEntry

for ($i = 0; $i -le $Roles.Count; $i++) { #Because the roles start at 0, they actually end at Count -1, but we want the last row for totals, so we use -le instead of -lt
	if ($i -eq $Roles.Count) { #If we are at the last one, put up the totals
		$objExcel.cells.item(1, $i + 3) = 'Total Roles'
	}
	else { #Othewise, put up the role name.
		$objExcel.cells.item(1, $i + 3) = $Roles[$i]
	}
}

$objExcel.cells.item(1, $Roles.count + 4) = 'Processor Name'
$objExcel.cells.item(1, $Roles.count + 5) = 'Processor Speed'
$objExcel.cells.item(1, $Roles.count + 6) = 'Number of Procs'
$objExcel.cells.item(1, $Roles.count + 7) = 'Memory'
$objExcel.cells.item(1, $Roles.count + 8) = 'C Drive (MB)'
$objExcel.cells.item(1, $Roles.count + 9) = 'D Drive (MB)'

for ($i = 1; $i -le $Roles.count + 9; $i++) {
	$objExcel.cells.item(1, $i).Font.Size = 14
	$objExcel.cells.item(1, $i).Font.Bold = $true
	if ($i -gt 1) {
		$objExcel.cells.item(1, $i).Orientation = 90
	}
	$objExcel.cells.item(1, $i).Interior.Color = $BackGroundColor
}

$y = 2 #Starting at row 2

#Get Site Sysetms for each site
$Sites = $(Get-CMSite).SiteCode
foreach ($Site in $Sites) {
	New-CMNLogEntry -entry "Getting site systems for $Site" -type 1 @NewLogEntry

	$SiteSystems = Get-CMSiteSystemServer -SiteCode $Site | Sort-Object -Property NetworkOSPath #Get the info and sort by Site System Name

	New-CMNLogEntry -entry 'Filling out site systems and their roles' -type 1 @NewLogEntry

	foreach ($Row in $SiteSystems) { #Get the site system
		$Name = $Row.NetworkOSPath -replace "\\*(.*)", '$1' #Set the name and remove the leading \\
		$objExcel.cells.item($y, 1) = $Name.ToUpper() #Put the name in the spreadsheet uppercase
		$objExcel.cells.item($y, 2) = $Row.SiteCode #Put in the site code
    
		#Get the roles for this site system
		$CMRoles = Get-CMSiteRole -SiteSystemServerName $Name 
		foreach ($Role in $CMRoles) { #Now we are going to put an * in each role the system has
			for ($x = 0; $x -le $Roles.Count; $x++) { #Again, we use -lt so we can put the formula in for the totals column
				if ($x -lt $Roles.count) {
					if ($role -match $Roles[$x]) {
						$objExcel.cells.item($y, $x + 3) = '*' #Put in the *
						$objExcel.cells.item($y, $x + 3).HorizontalAlignment = -4108 #This will center it
					}
				}
				else {
					$Formula = "=COUNTA(C$($y):$([char](64 + $x+2))$($y))" #Generate the formula, converting the $x to a letter
					$objExcel.cells.item($y, $x + 3).Formula = $Formula #Put in the formula
					$objExcel.cells.item($y, $x + 3).Font.Bold = $true #Bold
				}
			}
		}

		New-CMNLogEntry -entry 'Getting Processor Info' -type 1 @NewLogEntry
		$objProccessor = Get-WmiObject -ComputerName $Name -Namespace root\cimv2 -Class Win32_Processor
		$objExcel.cells.item($y, $Roles.count + 4) = $objProccessor.Name
		$objExcel.cells.item($y, $Roles.Count + 5) = "{0:N0}" -f $objProccessor.MaxClockSpeed

		New-CMNLogEntry -entry 'Figuring out how many Procs' -type 1 @NewLogEntry
		[int]$intTotalCores = 0
		foreach ($CPU in $objProccessor) {
			$intTotalCores += $CPU.NumberOfLogicalProcessors
		}

		$objExcel.cells.item($y, $Roles.count + 6) = $intTotalCores

		New-CMNLogEntry -entry 'Getting Memory' -type 1 @NewLogEntry
		$objMemory = Get-WmiObject -ComputerName $Name -Namespace root\cimv2 -Class Win32_PhysicalMemory
		[int64]$intTotalMemory = 0

		New-CMNLogEntry -entry 'Calculating Memory' -type 1 @NewLogEntry
		foreach ($Bank in $objMemory) {
			$intTotalMemory += "{0:N0}" -f $Bank.Capacity
		}
		$objExcel.cells.item($y, $Roles.count + 7) = $intTotalMemory

		New-CMNLogEntry -entry 'Getting Drive Info' -type 1 @NewLogEntry
		$objDrives = Get-WmiObject -ComputerName $Name -Namespace root\cimv2 -Class Win32_LogicalDisk
		foreach ($Drive in $objDrives) {
			if ($Drive.DeviceID -eq 'C:') {
				$objExcel.cells.item($y, $Roles.count + 8) = ($Drive.Size / 1024 / 1024)
   }
			if ($Drive.DeviceID -eq 'D:') {
				$objExcel.cells.item($y, $Roles.count + 9) = ($Drive.Size / 1024 / 1024)
   }
		}

		$networkConfig = Get-WmiObject -ComputerName $Name -Namespace root\cimv2 -Class Win32_NetworkAdapterConfiguration
		New-CMNLogEntry -entry "$Name has an IP of $($networkConfig.IPAddress)" -type 1 @NewLogEntry

		if (($y % 2) -eq 1) { #Check if this is an odd numbered row
			#If it is, set the fill color.
			New-CMNLogEntry -entry 'Odd row, filling color' -type 1 @NewLogEntry
			for ($i = 1; $i -lt $roles.Count + 8; $i++) {
				$objExcel.cells.item($y, $i).Interior.Color = $BackGroundColor
			}
		}
		$y++
	}
}

New-CMNLogEntry -entry 'Putting in totals' -type 1 @NewLogEntry

$objExcel.cells.item($y, 1) = 'Totals'
$objExcel.cells.item($y, 1).Font.Bold = $true

for ($i = 3; $i -lt $Roles.Count + 3; $i++) {
	$Formula = "=COUNTA($([char](64 + $i))2:$([char](64 + $i))$($y-1))"
	$objExcel.cells.item($y, $i).Formula = $Formula
	$objExcel.cells.item($y, $i).Font.Bold = $true
}

New-CMNLogEntry -entry 'Formatting sheet to autofit' -type 1 @NewLogEntry

$Range = $objWorkSheet.UsedRange
[void] $Range.EntireColumn.Autofit()

#We're done! Time to return to our original directory
Pop-Location 
New-CMNLogEntry -entry 'Finished Script' -type 1 @NewLogEntry