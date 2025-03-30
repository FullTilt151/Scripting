[CmdletBinding()]
PARAM
(
    [Parameter(Mandatory=$True,HelpMessage='Path to clean')]
    [String]$Path,
    [Parameter(Mandatory=$false,HelpMessage='Extension')]
    [String[]]$Ext = ('*.col','*.DAT','*.JOB','*.mif','*.mof','*.NCF','*.pkc','*.REQ','*.RPG','*.SBC','*.SMW','*.src','*.txt'),
    [Parameter(Mandatory=$False,HelpMessage='Number of days')]
    [Int16]$Days=5
)

if(Test-Path $Path)
{
    $Limit = (Get-Date).AddDays(-$Days)
    Get-ChildItem $Path -Include $Ext -Recurse | Where-Object {$_.LastWriteTime -le "$Limit"} | Remove-Item -Force
}
else
{
    write-output 'Invalid path'
}