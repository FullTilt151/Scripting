param(
[Parameter(Mandatory=$True)][ValidateSet('Workstations','HGB')]
$Environment
)

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Push-Location WP1:

switch ($Environment) {
    'Workstations' {$BootImageId = 'WP1009CA '; $Collection = 'WP100825'; $ImageFile = 'WP1009CA\boot.WP1009CA.wim'}
    'HGB' {$BootImageId = 'WP1009CB'; $Collection = 'WP101897'; $ImageFile = 'WP1009CB\boot.WP1009CB.wim'
}

$BootImage = Get-CMBootImage -Id $BootImageId
Pop-Location
$DateTime = Get-Item $($BootImage.PkgSourcePath) -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LastWriteTime

Push-Location WP1:
$PXE = Get-CMCollectionMember -CollectionId $Collection | Sort-Object Name | Select-Object -ExpandProperty Name

Pop-Location
$PXE |
ForEach-Object {
    if (Test-Connection -count 1 $_ -ErrorAction SilentlyContinue) {
        $Write = Get-Item \\$_\c$\ProgramData\1E\PXEEverywhere\TftpRoot\Images\$ImageFile -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LastWriteTime
        if ($Write -ne $null) {
            if ($Write.ToString() -ne $DateTime.ToString()) {
                Write-Host "$_ $Write BAD wrong time" -ForegroundColor Red
            } else {
                Write-Host "$_ $Write GOOD" -ForegroundColor Green
            }
        } else {
            Write-Host "$_ $Write BAD null" -ForegroundColor Yellow
        }
    } else {
        Write-Host "$_ OFFLINE" -ForegroundColor Gray
    }
}