param(
[Parameter(Mandatory=$true)]
[ValidateScript({Test-Path $_})]
$csv
)
$date = Get-Date -UFormat "%m%d%Y_%H%M%S"

Get-Content $csv | Select-Object -Skip 1 | ForEach-Object {
    $wkid = $_.ToString().Split(',')[0].ToUpper()
    $output += "$wkid "
    $ErrorActionPreference = "SilentlyContinue"
    $wkiddn = Get-ADComputer $wkid -Properties DistinguishedName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty DistinguishedName
    $ErrorActionPreference = "Continue"
    
    if ($wkiddn) {
        if ($wkiddn -like "*AdminAccess*") {
            $wkiddntarget = $wkiddn.Replace("CN=$wkid,OU=AdminAccess,",'')
            Move-ADObject -Identity $wkiddn -TargetPath $wkiddntarget
            $output += " - Moved - $wkiddntarget"
        } else {
            $output += "- Compliant"
        }
    } else {
        $output += "- Not in AD"
    }
    $output
    $output | Out-File c:\temp\MoveLog_$date.txt -append
    Remove-Variable Output -Force
}