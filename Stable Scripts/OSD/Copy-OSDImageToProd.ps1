#$Path = '\\lounaswps08\pdrive\dept907.cit\osd\images\OS\VLMedia'
$Path = '\\louosdwps01\Source\images\OS\VLMedia'

# Copy QA OS upgrade package to Prod
Get-ChildItem -Path $Path -Filter *_QA -Directory |
ForEach-Object {
    $ProdPath = ($_.FullName).Replace('_QA','')
    Copy-Item -Path "$($_.FullName)\*" -Destination $ProdPath -Recurse -Force
}

# Copy QA OS image to Prod
Get-ChildItem -Path $Path -Filter *_QA.wim -File |
ForEach-Object {
    $ProdImage = ($_.FullName).Replace('_QA','')
    Copy-Item $($_.FullName) -Destination $ProdImage -Force
}

# Validate hashes
$SourcePathQA = Get-ChildItem -Path $Path -Filter *_QA -Directory | Select-Object -ExpandProperty FullName
$SourcePathPROD = $SourcePathQA.Replace('_QA','')
New-FileCatalog -Path $SourcePathQA -CatalogFilePath c:\temp\OSUpgradePackage.cat -CatalogVersion 2.0
Test-FileCatalog -Path $SourcePathPROD -CatalogFilePath c:\temp\OSUpgradePackage.cat