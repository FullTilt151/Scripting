$source = $PSScriptRoot
$dirs = Get-ChildItem -Path $source -Directory | Sort-Object -Property Name
foreach($dir in $dirs)
{
    $files = Get-ChildItem -Filter '*.txt' -Path $dir.FullName | Where-Object {$_.Name -notmatch '\(\d*\)'} | Sort-Object -Property Name
    if($files.Count -ge 1)
    {
        foreach($file in $files)
        {
            $dupes = Get-ChildItem -Filter '*.txt' -Path $dir.FullName | Where-Object {$_.Name -match "$($file.BaseName)\(\d*\).*"}
            if($dupes.Count -ge 1)
            {
                foreach($dupe in $dupes)
                {
                    Write-Output "Delete $($dupe.Name)"
                    $dupe.Delete()
                }
            }
        }
    }
}