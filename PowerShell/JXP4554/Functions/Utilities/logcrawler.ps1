# By: Scott Chadwick 2017

$erroractionpreference = "SilentlyContinue"
[Enum]::GetNames([System.Windows.Forms.MessageBoxButtons])| Out-Null
[Enum]::GetNames([System.Windows.Forms.MessageBoxIcon])| Out-Null
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null

#-----------------------
function Split-array
{
	param($inArray,[int]$parts,[int]$size)

	if ($parts)
	{
		$PartSize = [Math]::Ceiling($inArray.count / $parts)
	}
	if ($size)
	{
		$PartSize = $size
		$parts = [Math]::Ceiling($inArray.count / $size)
	}

	$outArray = @()
	for ($i=1; $i -le $parts; $i++)
	{
		$start = (($i-1)*$PartSize)
		$end = (($i)*$PartSize) - 1
		if ($end -ge $inArray.count) {$end = $inArray.count}
		$outArray+=,@($inArray[$start..$end])
	}
	return ,$outArray
}

#-------------------------------
$CurrentDir = Get-Location
$SearchString= [Microsoft.VisualBasic.Interaction]::InputBox($CurrentDir, "LOG CRAWLER","Enter STRING to search for:")

$allfound = Select-String "*.log", "*.txt" -Pattern $SearchString | select PATH,LINE

$FOUNDIT = $allfound| Out-GridView -PassThru -wait

# HASH: 44633932

$TRIMIT = $FOUNDIT.split('=;')[2].split(' ')

#---------------------------------

$FLINE = $FOUNDIT.LINE.Trim()
$FPATH = $FOUNDIT.PATH.trim()

#----------------trim and edit data
$FLINE2 = $FLINE.TrimStart("<![LOG[")
$FLINE2 = $FLINE2.replace(']LOG]!>',"`n`r")
Write-Host "`n,`r"
Write-Host "              "
Write-Host "              "
$FLINE2 = $FLINE2.replace('<time=','TIME OF ALERT:')
write-host " LINE IN FILE: `n" | Out-Null
write-host $FLINE2
write-host " NAME OF FILE: `n" | Out-Null
write-host $FPATH

Set-Clipboard -Value $FLINE
Start-Process $FPATH
Get-Clipboard > C:\tools\FileFetch\file.txt #; notepad file.txt