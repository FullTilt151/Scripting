Param(
    [Parameter(Mandatory = $true)][ValidateSet('WinPE', 'FullOS')]
    [String]$environment,

    [Parameter(Mandatory = $false)]
    [String]$path = '\\lounaswps08.rsc.humad.com\pdrive\Dept907.CIT\OSD\Logs',

    [Parameter(Mandatory = $False)]
    [String]$Map = '\\lounaswps08.rsc.humad.com\pdrive\Dept907.CIT\OSD'
)

$Vendor = (Get-WmiObject win32_computersystemproduct).Vendor
$SerialNumber = (Get-WmiObject win32_bios).SerialNumber
$SerialNumber = $SerialNumber.Replace(' ', '')
$SerialNumber = $SerialNumber.Replace('-', '')
$SerialNumber = $SerialNumber.Substring(0, 13) 

if ($Vendor -in ('Microsoft Corporation', 'innotek GmbH', 'VMware, Inc.')) {
    $FolderName = "VM$SerialNumber"
}
Else {
    $FolderName = "WK$SerialNumber"
}

if (Test-Path -Path $path) {
    New-PSDrive -Name Z -PSProvider FileSystem -Root $Map -ErrorAction SilentlyContinue
    New-Item -Path $path -Name $FolderName -ItemType Directory  -ErrorAction SilentlyContinue | Out-Null

    if ($Environment -eq 'WinPE') {
        Copy-Item -Path x:\windows\temp\SMSTSLog\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Copy-Item -Path C:\_SMSTaskSequence\NomadBranch\LogFiles\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
    elseif ($Environment -eq 'FullOS') {
        Copy-Item -Path C:\Windows\CCM\Logs\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Copy-Item -Path C:\Windows\Logs\DISM\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
}

Else {
    $Cred = Get-Credential -Credential "humad\"
    New-PSDrive -Name Z -PSProvider FileSystem -Root $Map -Credential $Cred -ErrorAction SilentlyContinue
    New-Item -Path $path -Name $FolderName -ItemType Directory  -ErrorAction SilentlyContinue | Out-Null
    
    if ($Environment -eq 'WinPE') {
        Copy-Item -Path x:\windows\temp\SMSTSLog\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Copy-Item -Path C:\_SMSTaskSequence\NomadBranch\LogFiles\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue

    }
    elseif ($Environment -eq 'FullOS') {
        Copy-Item -Path C:\Windows\CCM\Logs\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
        Copy-Item -Path C:\Windows\Logs\DISM\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    }
}