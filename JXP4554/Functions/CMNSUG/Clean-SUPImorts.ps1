$source = "$PSScriptRoot\Imports\"
$dirs = Get-ChildItem -Path $source -Directory | Sort-Object -Property Name
foreach($dir in $dirs)
{
    $files = Get-ChildItem -Path $dir.FullName | Sort-Object -Property Name
    if($files.Count -gt 1)
    {
        for($x=0;$x -lt $files.Count - 1;$x++)
        {
            if($files[$x].Name -match '\(\d\)' -and ($files[$x] -replace '\(\d\)','' -eq $files[$x + 1]))
            {
                Write-Output "Delete $($files[$x].Name)"
                $files[$x].Delete()
            }
        }
    }
}