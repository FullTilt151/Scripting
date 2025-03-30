<#
.SYNOPSIS
   AE clean script we got from 1E.
.DESCRIPTION
   This script will 'clean' any packages on the machine so it'll pull everthing back down from AE.
   NOTE: Do NOT run this on a bunch of machines at once, it could crash the AE service.
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>
param(
	[Parameter(Mandatory=$true)]
	[ValidateSet('True','False')]
    [string]$Precache = 'False'
)

#Constants
$NomadBaseKey = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\1E\NomadBranch"
$SsdKey = "SSDEnabled"
$NomadCacheKey = "LocalCachePath"
$PackageStatusKey = "PkgStatus"
$DeviceIdKey = "DeviceId"
$PlatformUrlKey = "PlatformUrl"
$NomadLogKey="LogFileName"
$ScriptLog = "C:\temp\SyncNomadAE.log"

#Membmer Functions
function UpdateAllCachedPackages
{
	Add-Content $ScriptLog "Updating all cached packages."
	try{$Packages = Get-ChildItem -Path "$NomadBaseKey\$PackageStatusKey"
		foreach($Package in $Packages)
		{
			#Get the package ID.  We'll need this to find the rest of the details.
			$PkgPath = $Package.ToString().Split("\")
			$pkgId = $PkgPath[$PkgPath.Length - 1]
			WritePackageDetails $pkgId
		}
	}
	catch 
	{
		Add-Content $ScriptLog "`nCaught an exception:"
    	Add-Content $ScriptLog "`nException Type: $($_.Exception.GetType().FullName)"
    	Add-Content $ScriptLog "`nException Message: $($_.Exception.Message)"
	}

}

function WritePackageDetails
{
	Param(
	[string]$PkgId = ""
	)
	Add-Content $ScriptLog "`nWriting details of $PkgId to Active Efficiency"	
	try{
		#We need to get the version from the registry before we can get any properties from the lsz file.
		$VersionKey = "$NomadBaseKey\$PackageStatuskey\$PkgId"
		[Float]$PkgVersion = (Get-ItemProperty -Path $VersionKey -Name Version).Version
		$PkgPercent = (Get-ItemProperty -Path $VersionKey -Name Percent).Percent
		$PkgST = (Get-ItemProperty -Path $VersionKey -Name StartTimeUTC).StartTimeUTC
    	$PkgEnd = (Get-ItemProperty -Path $VersionKey -Name FinishTimeUTC).FinishTimeUTC
		#Write-Host "start time = $PkgST"
    	#Write-Host "end time = $PkgEnd"

    	$PkgStart = Get-NomadDate($PkgST)
    	$PkgEnd = Get-NomadDate($PkgEnd)
		#Get the LsZ file
		$lszPath = "$NomadCachePath$PkgId" + "_$PkgVersion.LsZ"
		$lszFile = Get-Content $lszPath
	
		[Long]$Bytes = 0
		[Int]$FileCount = 0
	
		foreach ($line in $lszFile)
		{
			if ($line.Contains("bytes in"))
			{
				#Write-Host $line
				$FilesLine = $line.Split(" ")
				$Bytes = $FilesLine[1]
				$FileCount = $FilesLine[4]
				Break
			}	
		}


<#	Write-Host "ContentName = $PkgId"
	Write-Host "    DeviceId = $DeviceId"
	Write-Host "    NumberOfFiles = $FileCount"
	Write-Host "    Percent = $PkgPercent"
	Write-Host "    Size = $Bytes"
	Write-Host "    StartTime = $PkgDate"
	Write-Host "    Version = $PkgVersion"	
#>
    	$JSON = @{
    	"ContentName" = $PkgId
    	"DeviceId" = $DeviceId
    	"NumberOfFiles" = $FileCount
    	"Percent" = $PkgPercent
    	"Size" = $Bytes
    	"StartTime" = $PkgStart
    	"EndTime" = $PkgEnd
    	"Version" = $PkgVersion} | ConvertTo-Json 
    
    	#Write-Host ConvertFrom-Json $JSON
	
    	$FullUrl = "$PlatformUrl/Devices/{$DeviceId}/ContentDelivery"
    	$webcall = Invoke-WebRequest ($FullUrl) -UseBasicParsing -Method Post -Body $JSON -ContentType "application/json" -Headers @{"Accept"="application/json"}
    	#Write-Host ConvertFrom-Json $webcall
	}
	catch 
	{
		Add-Content $ScriptLog "`nCaught an exception:"
    	Add-Content $ScriptLog "`nException Type: $($_.Exception.GetType().FullName)"
    	Add-Content $ScriptLog "`nException Message: $($_.Exception.Message)"
	}	
}

function ClearAllDeliveries
{
	try{
		Add-Content $ScriptLog "`nClearing all entries from Active Efficiency"
		$commandURL = "Devices/{$DeviceId}/ContentDelivery"
		$fullUrl = "$PlatformUrl/$commandUrl"
    	#Write-Host $fullUrl
		$webcall = Invoke-WebRequest ($fullUrl) -UseBasicParsing -Method Delete -Headers @{"Accept"="application/json"}
		$tempraw = $webcall.Content
		#Write-Host $webcall.Content
		#	Add-Content -Value $webcall -Path $jsonFile
	}
	catch 
	{
		Add-Content $ScriptLog "`nCaught an exception:"
    	Add-Content $ScriptLog "`nException Type: $($_.Exception.GetType().FullName)"
    	Add-Content $ScriptLog "`nException Message: $($_.Exception.Message)"
	}
}

function Get-NomadDate
{
    Param(
        [string] $datestring
    )
	try{
		Add-Content $ScriptLog "Converting Date"
    	#Get the date from the registry value
		$Year = $datestring.Substring(0,4)
		$Month = $datestring.Substring(4,2)
		$Day = $datestring.Substring(6,2)
		$Hour = $datestring.Substring(8,2)
		$Minute = $datestring.Substring(10,2)
		$Second = $datestring.Substring(12,2)
		$Millisecond = $datestring.Substring(14,3)
		$PkgDate = New-Object -TypeName System.DateTime -ArgumentList $Year, $Month, $Day, $Hour, $Minute, $Second, $Millisecond, "UTC"
		return $PkgDate
	}
	catch 
	{
		Add-Content $ScriptLog "`nCaught an exception:"
    	Add-Content $ScriptLog "`nException Type: $($_.Exception.GetType().FullName)"
    	Add-Content $ScriptLog "`nException Message: $($_.Exception.Message)"
	}
}

#Main


#Get the global variables:
try
{
	[Int]$SsdValue = (Get-ItemProperty -Path $NomadBaseKey -Name $SsdKey).$SsdKey
	[String]$NomadCachePath = (Get-ItemProperty -Path $NomadBaseKey -Name $NomadCacheKey).$NomadCacheKey
	[String]$DeviceId = (Get-ItemProperty -Path "$NomadBaseKey\ActiveEfficiency" -Name $DeviceIdKey).$DeviceIdKey
	[String]$PlatformUrl = (Get-ItemProperty -Path "$NomadBaseKey\ActiveEfficiency" -Name $PlatformUrlKey).$PlatformUrlKey
	[String]$NomadLogName = (Get-ItemProperty -Path $NomadBaseKey -Name $NomadLogKey).$NomadLogKey
}
catch
{
	"Failed to find required registry entries.  Is Nomad installed?"
	Exit
}

#Write-Host "PlatformUrl = $PlatformUrl"

#Create Log File
if ($ScriptLog -eq "")
{
	$ScriptLogPath = $NomadLogName.Split("\")
	$ScriptLogPath[$ScriptLogPath.Length - 1] = "SyncPackagesAE.log"
	$ScriptLog = [System.String]::Join("\", $ScriptLogPath)
}

#Write variables to log
Add-Content $ScriptLog "`nStarting SyncPackagesWithAE Script `n$SsdValue `n$NomadCachePath `n$DeviceId `n$PlatformUrl"

if ((2 -band $SsdValue) -eq 2)
{
	ClearAllDeliveries
	UpdateAllCachedPackages
	if($Precache){
		& "$((Get-ItemProperty -Path 'HKLM:\SOFTWARE\1E\NomadBranch' -Name 'InstallationDirectory').InstallationDirectory)\NomadBranch.exe" -precache
	}
}