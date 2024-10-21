Import-Module $env:SMS_ADMIN_UI_PATH\..\ConfigurationManager.psd1
Set-Location WP1:

$Scope = Get-CMSecurityScope -Name HGB
Get-CMTaskSequence -Name *HGB* | Select-Object -ExpandProperty References | Select-Object -ExpandProperty Package | 
ForEach-Object {
    $Pkg = Get-CMPackage -Id $_ -ErrorAction SilentlyContinue
    $SSN = $Pkg | Select-Object -ExpandProperty SecuredScopeNames
    if ($SSN -notcontains 'HGB') {
        $Pkg | Add-CMObjectSecurityScope -Scope $Scope -Verbose
    }
}