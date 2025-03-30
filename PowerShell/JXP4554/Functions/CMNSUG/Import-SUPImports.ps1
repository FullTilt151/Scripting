$source = "$PSScriptRoot\Imports"
$destination = $PSScriptRoot
$dirs = Get-ChildItem -Path $source -Directory | Sort-Object -Property Name

if(-not (Test-Path -Path "$destination\ScanCab"))
{
    New-Item -Path "$source" -Name 'ScanCab' -ItemType Directory
}

if(-not (Test-Path -Path "$destination\Payload"))
{
    New-Item -Path "$source" -Name 'Payload' -ItemType Directory
}

foreach($dir in $dirs)
{
    if($dir.Name -ne 'Payload' -and $dir.Name -ne 'ScanCab' -and $dirs.Name -ne 'WSUSImportTool')
    {
        if($dir.Name -match 'Scan cab')
        {
            $dirName = $dir.Name -replace '(.*?)_.*', '$1'

            if(-not (Test-Path -Path "$destination\ScanCab\$dirName")){New-Item -Path "$destination\ScanCab" -Name $dirName -ItemType Directory}
            Copy-Item -Path "$($dir.FullName)\*" -Destination "$destination\ScanCab\$dirName" -Recurse -Force
        }
        else
        {
            $dirName = $dir.Name -replace '(.*?)_.*', '$1'

            if(-not (Test-Path -Path "$destination\Payload")){New-Item -Path "$destination" -Name 'Payload' -ItemType Directory}
            Copy-Item -Path "$($dir.FullName)\*" -Destination "$destination\Payload" -Recurse -Force
        }
    }
}