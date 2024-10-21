param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    $csv
)
$date = Get-Date -UFormat "%m%d%Y_%H%M%S"

Import-CSV $csv |
ForEach-Object {
    $output += "$($_.Computer)"
    if (Test-Connection $_.Computer -Count 1 -ErrorAction SilentlyContinue) {
        $objUser = [ADSI]("WinNT://HUMAD/$($_.UserName)")
        $objGroup = [ADSI]("WinNT://$($_.Computer)/Administrators")
        $objGroup.PSBase.Invoke("Remove",$objUser.PSBase.Path)
        if ($?) {
            $output += " - $($_.UserName) Removed"
        } else {
            $output += " - $($_.UserName) - $($Error[0].Exception.InnerException)"
        }
    } else {
        Write-Output "$($_.Computer): Offline"
        $output += " - Computer Offline"
    }
    $output
    $output | Out-File c:\temp\RemoveLog_$date.txt -append
    Remove-Variable Output -Force
}