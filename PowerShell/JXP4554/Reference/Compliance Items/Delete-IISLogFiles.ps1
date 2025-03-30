PARAM
(
	[Parameter(Mandatory=$true)]
	[String]$drive,

	[Parameter(Mandatory=$false)]
	[Int32]$days=5
)

$Limit = (Get-Date).AddDays(-$days)
$Path = "$drive`:\IISlogs"
$Ext = "*.log"

write-host "Checking $Path for files older than $Limit."
Get-ChildItem $Path -Include $Ext -Recurse | Where-Object {$_.LastWriteTime -le "$Limit"} | Remove-Item -Force