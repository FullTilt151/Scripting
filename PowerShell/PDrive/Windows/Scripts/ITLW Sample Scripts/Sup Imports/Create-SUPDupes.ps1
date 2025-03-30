$source = $PSScriptRoot
$dirs = Get-ChildItem -Path $source -Directory | Sort-Object -Property Name
foreach($dir in $dirs)
{
    for($x = 1 ; $x -le 15 ; $x++)
    {
        New-Item -Path $dir.FullName -Name "File($x).txt"
    }
}