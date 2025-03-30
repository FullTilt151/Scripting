#Requires -Version 5.0 
$DSIPXEa = for ($i = 1; $i -le 9; $i++) { 
    Test-Connection -Count 1 -TimeToLive 30 -ComputerName  DSIPXEWPW0$i -erroraction silentlycontinue | Select-Object -ExpandProperty Address
}
$DSIPXEb = for ($i = 10; $i -le 99; $i++) { 
    Test-Connection -Count 1 -TimeToLive 30 -ComputerName  DSIPXEWPW$i -erroraction silentlycontinue | Select-Object -ExpandProperty Address
}
$ATSPXEa = for ($i = 1; $i -le 9; $i++) { 
    Test-Connection -Count 1 -TimeToLive 30 -ComputerName  ATSPXEWPW0$i -erroraction silentlycontinue | Select-Object -ExpandProperty Address
}
$CISPXEa = for ($i = 1; $i -le 9; $i++) { 
    Test-Connection -Count 1 -TimeToLive 30 -ComputerName  CISPXEWPW0$i -erroraction silentlycontinue | Select-Object -ExpandProperty Address
}
$CISPXEb = for ($i = 1; $i -le 9; $i++) { 
    Test-Connection -Count 1 -TimeToLive 30 -ComputerName  CISPXEWTW0$i -erroraction silentlycontinue | Select-Object -ExpandProperty Address
}
$CISPXEc = for ($i = 1; $i -le 9; $i++) { 
    Test-Connection -Count 1 -TimeToLive 30 -ComputerName  CISPXEWQW0$i -erroraction silentlycontinue | Select-Object -ExpandProperty Address
}
$EUEPXEa = for ($i = 1; $i -le 9; $i++) { 
    Test-Connection -Count 1 -TimeToLive 30 -ComputerName  EUEPXEWPW0$i -erroraction silentlycontinue | Select-Object -ExpandProperty Address
}
$PXEs = ($DSIPXEa + $DSIPXEb + $ATSPXEa + $CISPXEa + $CISPXEb +$CISPXEc +$EUEPXEa)
Foreach ($PXE in $PXEs) {
    $IP = Test-Connection -Count 1 -TimeToLive 45 -ComputerName $PXE -ErrorAction SilentlyContinue| Select-Object -ExpandProperty IPv4Address
    $TGT = Get-CimInstance CIM_LogicalDIsk -ComputerName $PXE -ErrorAction SilentlyContinue | Where-Object DeviceID -eq "F:" 
    $Free = $TGT.FreeSpace/1GB
    $RSC = $TGT.PSComputerName
    function Get-ComputerSite($PXE)
    {
        $site = nltest /server:$PXE /dsgetsite 2>$null
        if($LASTEXITCODE -eq 0){ $site[0] }
    }
    $ADSite = Get-ComputerSite $PXE
    #$Logon = Get-CimInstance Win32_NetworkLoginProfile -ComputerName $PXE -ErrorAction SilentlyContinue| Sort-Object -Descending LastLogon | Select-Object * -First 1
    #$User = $Logon.FullName
    Write-Output "$Free,$RSC,$ADSite,$IP"
}