[CmdletBinding()]
PARAM(
    [Parameter(Mandatory = $true)]
    [String]$pattern,

    [Parameter(Mandatory = $false)]
    [String]$path = '.'
)
$files = Get-ChildItem -Path $path
foreach ($file in $files) {
    $results = Get-Content -Path $file.FullName | Select-String -Pattern $pattern
    if ($results) {Write-Output $file.FullName}
}