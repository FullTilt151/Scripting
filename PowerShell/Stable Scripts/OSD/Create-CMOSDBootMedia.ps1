param(
    [Parameter(ParameterSetName = 'WorkstationsProd')]
    [switch]$WorkstationsProd,
    [Parameter(ParameterSetName = 'WorkstationsQA')]
    [switch]$WorkstationsQA,
    [Parameter(ParameterSetName = 'ServersProd')]
    [switch]$ServersProd,
    [Parameter(ParameterSetName = 'ServersQA')]
    [switch]$ServersQA,
    [Parameter(ParameterSetName = 'HGB')]
    [switch]$HGB,
    [Parameter(Mandatory = $true, ParameterSetName = 'HGB')]
    [Parameter(Mandatory = $true, ParameterSetName = 'WorkstationsProd')]
    [ValidateScript( { Test-Path $_ } )]
    [string]$CertificatePath,
    [string]$CertificatePassword
)

switch ($PSCmdlet.ParameterSetName) {
    'WorkstationsProd' {
        $Environment = 'WorkstationsProd'
        $SiteCode = 'WP1'
        $BootImage = 'Humana Boot Image x64 Workstations'
        $secureStringPass = $CertificatePassword | ConvertTo-SecureString -AsPlainText -Force
        $certSplat = @{
            CertificatePath     = $CertificatePath
            CertificatePassword = $secureStringPass
        }
    }
    'WorkstationsQA' {
        $Environment = 'WorkstationsQA'
        $SiteCode = 'WQ1'
        $BootImage = 'Humana Boot Image x64 Workstations'
    }
    'ServersProd' {
        $Environment = 'ServersProd'
        $SiteCode = 'SP1'
        $BootImage = 'Humana Boot Image x64 Servers'
    }
    'ServersQA' {
        $Environment = 'ServersQA'
        $SiteCode = 'SQ1'
        $BootImage = 'Humana Boot Image x64 Servers'
    }
    'HGB' {
        $Environment = 'HGB'
        $SiteCode = 'WP1'
        $BootImage = 'Humana Boot Image x64 HGB'
        $secureStringPass = $CertificatePassword | ConvertTo-SecureString -AsPlainText -Force
        $certSplat = @{
            CertificatePath     = $CertificatePath
            CertificatePassword = $secureStringPass
        }
    }
}

Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module
Push-Location "$($SiteCode):" # Set the current location to be the site code.

$BootImage = Get-CMBootImage -Name $BootImage
$DP = Get-CMDistributionpoint -SiteCode $SiteCode
$MP = Get-CMManagementPoint -SiteCode $SiteCode
$newCMBootablsplateMediaSplat = @{
    AllowUnknownMachine = $true
    Path                = "\\lounaswps08\pdrive\dept907.cit\osd\images\boot\BootImage_$($Environment)_$($BootImage.SourceVersion).iso"
    MediaType           = 'CdDvd'
    BootImage           = $BootImage
    ManagementPoint     = $MP
    MediaMode           = 'Dynamic'
    DistributionPoint   = $DP
}

switch ($Environment) {
    'ServersProd' { New-CMBootableMedia @newCMBootablsplateMediaSplat }
    'ServersQA' { New-CMBootableMedia @newCMBootablsplateMediaSplat }
    'HGB' { New-CMBootableMedia @newCMBootablsplateMediaSplat @certSplat }
    'WorkstationsProd' { New-CMBootableMedia @newCMBootablsplateMediaSplat @certSplat; Robocopy "\\lounaswps08\pdrive\dept907.cit\osd\images\boot" "\\louhpvwtw002\d$\Hyper-V\Repository" BootImage_$($Environment)_$($BootImage.SourceVersion).iso /Z }
    'WorkstationsQA' { New-CMBootableMedia @newCMBootablsplateMediaSplat; Robocopy "\\lounaswps08\pdrive\dept907.cit\osd\images\boot" "\\louhpvwqw001\d$\Hyper-V\Repository" BootImage_$($Environment)_$($BootImage.SourceVersion).iso /Z}
}

Pop-Location