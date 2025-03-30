Function New-CMNObjectContainer {
    $NewObjectConter = ([wmiclass] "\\$($sccmConnectionInfo.ComputerName)\root\SMS\SITE_$($($sccmConnectionInfo.SiteCode)):SMS_ObjectContainerNode").CreateInstance()
} #End New-CMNObjectContainer
