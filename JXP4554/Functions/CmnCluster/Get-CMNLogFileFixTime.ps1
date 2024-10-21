PARAM
(
    [Parameter(Mandatory=$true)]
    [String]$LogFile
)
$CSVFile = $LogFile -replace '(.*)\.log', '$1.csv'
$Lines = Get-Content $LogFile
foreach($Line in $Lines)
{
    $Line -match '<!\[LOG\[(.*)\]LOG\]!><time="(.*)" date="([\d\-]*)".*' | Out-Null
    $Entry = $Matches[1]
    $Time = $Matches[2]
    $Date = $Matches[3]
    $Time -match '([0-9]*:[0-9]*:[0-9\.]*)([\+\-][0-9]*)' | Out-Null
    $LocalTime = $Matches[1]
    [Int32]$Offset = $Matches[2] 
    $UTCTime = get-date "$Date $LocalTime"
    $UTCTime = $UTCTime.AddMinutes($Offset)
    "'$Entry','$UTCTime'" | Out-File -FilePath $CSVFile -Encoding ascii -Append
}