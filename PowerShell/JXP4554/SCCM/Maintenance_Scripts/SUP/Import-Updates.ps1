function Test-RegistryValue {
    param (
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]$Path,
    
        [parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]$Value
    )
    
    try {
        Get-ItemProperty -Path $Path -Name $Value -ErrorAction Stop | Out-Null
        return $true
    }
    
    catch {
        return $false
    }
}
    
$logFile = 'c:\Temp\Import-WSUSUpdates.log'
$newLogEntry = @{
    Component = 'Import-WSUSUpdates';
    logFile   = $logFile;
}
New-CMNLogEntry -entry 'Started!!!' -type 1 @newLogEntry
$regKeyPath = 'HKLM:\SOFTWARE\Humana\Win2k3 Updates\'
if (!(Test-Path -Path $regKeyPath)) {
    if (!(Test-Path -Path (Split-Path -Path $regKeyPath))) {New-Item -Path (Split-Path -Path $regKeyPath)}
    New-Item -Path $regKeyPath
}
$source = 'D:\Win2k3_Patches'
$cmd = "C:\Program Files\Update Services\Tools\WsusUtil.exe"
$dirs = Get-ChildItem -Path "$source\ScanCab" | Where-Object {$_.PSIsContainer -eq $true} | Sort-Object -Property Name

foreach ($dir in $dirs) {
    $files = Get-ChildItem -Path $dir.FullName
    foreach ($file in $files) {
        New-CMNLogEntry -entry "Checking $($file.FullName)" -type 1 @newLogEntry
        if (!(Test-RegistryValue -Path $regKeyPath -Value $file.FullName)) {
            New-ItemProperty -Path $regKeyPath -Name $file.FullName -Value 'Starting' | Out-Null
            $result = 'Starting'
        }
        else {
            $result = (Get-ItemProperty -Path $regKeyPath -Name $file.FullName ).($file.FullName)
        }
        if ($result -ne 'Complete') {
            New-CMNLogEntry -entry "Importing $($file.FullName)" -type 1 @newLogEntry
            try {
                New-CMNLogEntry -entry  'Optimizing database' -type 1 @newLogEntry
                & .\Optimize-WSUS -doIndex
                $params = @('CSAImport', "$($file.FullName)", "$source\Payload")
                $error.Clear()
                New-CMNLogEntry -entry "Executing $cmd $params" -type 1 @newLogEntry
                & $cmd $params
                if (!(Test-RegistryValue -Path $regKeyPath -Value $file.FullName)) {New-ItemProperty -Path $regKeyPath -Name $file.FullName -Value 'Complete' | Out-Null}
                else {Set-ItemProperty -Path $regKeyPath -Name $file.FullName -Value 'Complete' | Out-Null}
            }
            catch {
                if (!(Test-RegistryValue -Path $regKeyPath -Value $file.FullName)) {New-ItemProperty -Path $regKeyPath -Name $file.FullName -Value 'Failed' | Out-Null}
                else {Set-ItemProperty -Path $regKeyPath -Name $file.FullName -Value 'Failed' | Out-Null}
            }
        }
        else {New-CMNLogEntry -entry "Skipping $($file.FullName)" -type 2 @newLogEntry}
    }
}
& .\Optimize-WSUS -doIndex -doWsusCleanup
New-CMNLogEntry -entry 'Finished!!!' -type 1 @newLogEntry