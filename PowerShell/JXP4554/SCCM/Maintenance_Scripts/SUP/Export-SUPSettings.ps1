. .\DS-SUPSettings.ps1
Switch ($env:COMPUTERNAME){
    'LOUAPPWTS1140' {$con = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWTS1140'}
    'LOUAPPWPS1658' {$con = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWPS1658'}
    'LOUAPPWPS1825' {$con = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWPS1825'}
    'LOUAPPWQS1150' {$con = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWQS1150'}
    'LOUAPPWQS1151' {$con = Get-CMNSCCMConnectionInfo -siteServer 'LOUAPPWQS1151'}
    default {Throw 'This is not a suported server'}
}

Export-CMNSUPSettings -sccmConnectionInfo $con -exportPath 'C:\Temp\WSUSSettings.xml'