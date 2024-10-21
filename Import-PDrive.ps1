$sources = ('\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\Scripts', '\\LOUNASWPS08\PDrive\Dept907.CIT\ConfigMgr\SQL_Queries', '\\LOUNASWPS08\PDrive\Dept907.CIT\Win10\Scripts', '\\LOUNASWPS08\PDrive\Dept907.CIT\Windows\Scripts')#, '\\SIMCLRDAT01\ClientInnovation\Scripting\XD_Scripts')    
$destinationRoot = "$($PSScriptRoot)\PDrive\"
foreach ($source in $sources) {
    if ($source -match 'SIMCLRDAT01') { $destination = "$($destinationRoot)$($source -replace '\\\\SIMCLRDAT01\\ClientInnovation\\Scripting\\','')" }
    else { $destination = "$($destinationRoot)$($source -replace '\\\\LOUNASWPS08\\PDrive\\Dept907.CIT\\','')" }
    Write-Host "Copying $source -> $destination"
    $cmd = 'robocopy'
    $robocopyOptions = @('/mir', '/r:0', '/XO')
    $fileList = '*.*'
    $switches = @($source, $destination, $fileList) + $robocopyOptions
    & $cmd $switches
    if (test-path -Path "$destination\LastSync.txt") { Remove-Item -Path "$destination\LastSync.txt" }
    New-Item -path "$destination\LastSync.txt" -ItemType File
}