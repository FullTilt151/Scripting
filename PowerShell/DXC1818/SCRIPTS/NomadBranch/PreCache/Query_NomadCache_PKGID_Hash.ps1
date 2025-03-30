Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Set-Location WP1:
#CLS
$PKGQuery = Read-Host "Enter the PackageID"
$PXE = Get-CMCollectionMember -CollectionId WP100825 | Sort-Object Name | Select-Object -ExpandProperty Name
Set-Location C:
$PXE |
ForEach-Object {
    If (Test-Connection -count 1 $_ -ErrorAction SilentlyContinue) {
        If (Test-Path "filesystem::\\$_\NomadSHR\$PKGQuery*.LsZ") {
        $HashVer = Get-Item "filesystem::\\$_\NomadSHR\$PKGQuery*.LsZ" | Select-Object Name | Select-Object -ExpandProperty Name
        $Write = Select-String "filesystem::\\$_\NomadSHR\$PKGQuery*.LsZ" -Pattern 'HashV4' | Select-Object -ExpandProperty Line
        $split = $Write -split ' '
        $hash1 = $split[0]
        $hash2 = $split[1]
        $hash3 = $split[2] 
            If ($Write -ne $null) {
            $HashVal = $Write -split ' '
            Write-Host "$_ $HashVer $hash3"
            } Else {
            Write-Host "$_ No hash value" -ForegroundColor red -BackgroundColor yellow}                    
        } Else {
        Write-Host "$_ No file at this location" -ForegroundColor red -BackgroundColor white} 
    } Else {
    Write-Host "$_ BAD not online" -ForegroundColor white -BackgroundColor red
        }
}