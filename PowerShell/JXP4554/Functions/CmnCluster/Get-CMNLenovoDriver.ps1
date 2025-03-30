#requires -version 3

[CmdletBinding()]
param()

Write-verbose “Download Model List”
$AllModels = Invoke-WebRequest http://support.lenovo.com/en/documents/ht074984
$ModelPages = $AllModels.links.href |
   select-string -allmatches “(?:/docs/|/us/en/downloads/)(ds[0-9]+)” |
   ForEach-Object { $_.matches.groups[1].value } |
   Select-Object -Unique

Write-Debug “Done: Count[$($ModelPages.count)]”

$i = 0
#$manif
Write-Verbose “Download each model page”
ForEach ( $Model in $ModelPages )
{
    Write-Progress -Activity “Download $Model“ -PercentComplete ($i * 100 / $ModelPages.Count)
    $i++
    Invoke-WebRequest “http://support.lenovo.com/us/en/downloads/$Model“ |
        ForEach-Object {
            [PSCustomObject] @{
                 PackageID = $Model;
                 Title = $_.ParsedHTML.Title;
                 Download = ($_.links.href -match “.*exe”)
            }
        }
}

Write-Progress -Activity “Done” -Completed