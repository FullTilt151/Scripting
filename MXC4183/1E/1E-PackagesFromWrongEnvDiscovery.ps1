Where-Object
$OtherEnvDpNamePattern = "*wq*"

$LocalCachePath = [string]::Empty
$InstallationDirectory = [string]::Empty

$LocalCachePath = [string](Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\1E\NomadBranch -Name LocalCachePath -ErrorAction Ignore).LocalCachePath
$InstallationDirectory = [string](Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\1E\NomadBranch -Name InstallationDirectory -ErrorAction Ignore).InstallationDirectory

$regex = '^; Generated by "(?<servername>[^"]*)" from "(?<path>[^"]*)"(.*)$'

$contentIDs = @()

if($LocalCachePath.Length -gt 0){
    Get-ChildItem -Path "$($LocalCachePath)*.lsz" | ForEach-Object {Select-String -Path $_ -Pattern $regex -AllMatches | ForEach-Object { if($($_.matches[0].groups["servername"].value) -like $OtherEnvDpNamePattern){$($_.matches[0].groups["path"].value) | Select-String -Pattern '[^ \\]*$' -AllMatches | ForEach-Object { $contentIDs += $($_.matches[0].groups[0].value) } } }}
}
Write-Host ("{0}" -f $contentIDs.Count)
