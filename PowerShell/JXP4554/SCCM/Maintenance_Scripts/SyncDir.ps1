
if ($env:COMPUTERNAME -eq 'LOUAPPWTS1140') {
    Write-Output 'This is the source server, please do not sync'
    exit
}
else {
    $source = Split-Path $PSScriptRoot -Leaf
    $destination = "D:\$source"
    Switch ($env:COMPUTERNAME) {
        'GRBAPPWPS12' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1405' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1642' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1643' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1644' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1645' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1646' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1647' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1648' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1649' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1653' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1654' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1655' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1656' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1657' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1658' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1700' {$source = "\\LOUAPPWPS1658.rsc.humad.com\d$\$source"}
        'LOUAPPWPS1701' {$source = "\\LOUAPPWPS1700.dmzad.hum\$source"}
        'LOUAPPWPS1740' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1741' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1742' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1750' {$source = "\\LOUAPPWPS1825.rsc.humad.com\d$\$source"}
        'LOUAPPWPS1821' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1822' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWPS1825' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1020' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1021' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1022' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1023' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1024' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1025' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1150' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWQS1151' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWTS1150' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWTS1151' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LOUAPPWTS1152' {$source = "\\LOUAPPWTS1140.rsc.humad.com\$source"}
        'LTLSCMDPWTS01' {$source = "\\LOUAPPWQS1150.rsc.humad.com\d$\$source"}
        default {
            Write-Host 'Do not sync this server'
            exit
        }
    }
    if (!(Test-Path $destination)) {
        Write-Output "Creating directory $destination"
        New-Item -Path $destination -ItemType Directory
    }
    $shareName = Split-Path $destination -Leaf
    if($env:COMPUTERNAME -in ('LOUAPPWTS1140','LOUAPPWQS1150','LOUAPPWQS1151','LOUAPPWPS1658','LOUAPPWPS1825','LOUAPPWPS1742','LOUAPPWPS1405')){
        if((Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue).Name -eq $shareName){
            Write-Output 'Removing Share'
            Remove-SmbShare -Name $shareName -Force
        }
    }
    elseif ((Get-SmbShare -Name $shareName -ErrorAction SilentlyContinue).Name -ne $shareName) {
        Write-Output 'Creating share'
        New-SmbShare -Name $shareName -Path $destination -ReadAccess 'Everyone'
    }
    Write-Host "Copying $source -> $destination"
    $cmd = 'robocopy'
    $robocopyOptions = @('/mir', '/r:0')
    $fileList = '*.*'
    $switches = @($source, $destination, $fileList) + $robocopyOptions
    & $cmd $switches
    if (test-path -Path "$destination\LastSync.txt") {Remove-Item -Path "$destination\LastSync.txt"}
    New-Item -path "$destination\LastSync.txt" -ItemType File
}