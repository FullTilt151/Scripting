param(
[Parameter(Mandatory=$True)][ValidateSet('Workstations','HGB')]
$Environment
)

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1"
Push-Location WP1:

switch ($Environment) {
    'Workstations' {$BootImageId = 'WP1002B5'; $Collection = 'WP100825'; $ImageFile = 'WP1002B5\boot.WP1002B5.wim'}
    'HGB' {$BootImageId = 'WP1002FB'; $Collection = 'WP101897'; $ImageFile = 'WP1002FB\boot.WP1002FB.wim'}
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
        $Write = Get-Item \\$_\c$\ProgramData\1E\PXELite\TftpRoot\Images\$ImageFile -ErrorAction SilentlyContinue | Select-Object -ExpandProperty LastWriteTime
        if ($Write -ne $null) {
            if ($Write.ToString() -ne $DateTime.ToString()) {
                "$_ $Write BAD wrong time"
            } else {
                "$_ $Write GOOD"
            }
        } else {
            "$_ $Write BAD null"
        }
    } else {
        "$_ OFFLINE"
    }
}