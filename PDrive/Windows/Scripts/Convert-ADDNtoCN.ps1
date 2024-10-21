#$OUList = Get-ADOrganizationalUnit -Filter * -Server SIMRSCWPS02.rsc.humad.com | Select-Object -ExpandProperty DistinguishedName
#$OUList = get-content C:\temp\OUs.txt

foreach ($OU in $OUList) { 
    $Parts=$OU.Split(",") 
    $NumParts=$Parts.Count 
    $FQDNPieces=($Parts -match 'DC').Count 
    $Middle=$NumParts-$FQDNPieces
        
    foreach ($x in ($Middle+1)..($NumParts)) { 
        $CN+=$Parts[$x-1].SubString(3)+'.' 
    }
  
    $CN=$CN.substring(0,($CN.length)-1) 
 
    foreach ($x in ($Middle-1)..0) {  
        $Parts[$x].substring(3) | Out-Null
        $CN+="/"+$Parts[$x].SubString(3)
    }

    $CN = $CN.Replace("rsc.humad.com/","")

    $CN | Out-File c:\temp\OUs_CN.txt -Append
    $CN = ""
}