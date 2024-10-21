Param(
    [Parameter(Mandatory = $true)][ValidateSet('WinPE', 'FullOS')]
    [String]$environment,

    [Paramter(Mandatory = $false)]
    [String]$path = '\\lounaswps08.rsc.humad.com\pdrive\Dept907.CIT\OSD\Logs\'
)

Get-ChildItem -Directory -Path "filesystem::$path" 
$Result = $?
If ($Result -eq $True) {
    New-PSDrive -Name P -PSProvider FileSystem -Root $path
}
Else {
    $userid = Read-Host "Please enter your 'A account' USERID (example: abc1234a)"
    $pass = Read-Host "Please enter your password" | ConvertTo-SecureString -AsPlainText -Force
    $Cred = New-Object System.Management.Automation.PsCredential("humad\$userid", $pass)
    (New-PSDrive -Name P -Credential $cred -PSProvider FileSystem -Root $path)
}

$Vendor = (Get-WmiObject win32_computersystemproduct).Vendor
$SerialNumber = (Get-WmiObject win32_bios).SerialNumber
$SerialNumber = $SerialNumber.Replace(' ', '')
$SerialNumber = $SerialNumber.Replace('-', '')
$SerialNumber = $SerialNumber.Substring(0, 13)

if ($Vendor -in ('Microsoft Corporation', 'innotek GmbH', 'VMware, Inc.')) {
    $FolderName = "VM$SerialNumber"
    New-Item -Path $path -Name $FolderName -ItemType Directory | Out-Null
}
else {
    $FolderName = "WK$SerialNumber"
    New-Item -Path $path -Name $FolderName -ItemType Directory | Out-Null
}

if ($Environment -eq 'WinPE') {
    Copy-Item -Path x:\windows\temp\SMSTSLog\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
    Copy-Item -Path C:\_SMSTaskSequence\NomadBranch\LogFiles\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
}
elseif ($Environment -eq 'FullOS') {
    Copy-Item -Path C:\Windows\CCM\Logs\* -Destination "$path\$FolderName" -Recurse -Force -Verbose -ErrorAction SilentlyContinue
} 
