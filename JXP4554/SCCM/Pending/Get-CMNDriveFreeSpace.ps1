Function Get-Size
{
    PARAM
    (
        [Parameter(Mandatory=$true)]
        $Bytes
    )
    $DiskSizesLong = ('Byte','Kilobyte','Megabyte','Gigabyte','Terabyte','Petabyte','Exabyte','Zettabyte','Yottabyte')
    $DiskSizesShort = ('BT','KB','MB','GB','TB','PB','EB','ZB','YB')
    for($x=0;$x -le 8;$x++)
    {
        if(($Bytes/[math]::pow(2,$x*10)) -le 1)
        {
            if($x -eq 0){$SizeIndex = $x}
            else{$SizeIndex = $x - 1}
            break
        }
    }
    $ReturnHashTable = @{
    SizeLong = $DiskSizesLong[$SizeIndex];
    SizeShort = $DiskSizesShort[$SizeIndex];
    SizeIndex = $SizeIndex;
    Size = ($Bytes / [math]::pow(2,$SizeIndex * 10));}

    $obj = New-Object -TypeName PSObject -Property $ReturnHashTable
    $obj.PSObject.TypeNames.Insert(0,'CMN.DiskSize')
    Return $obj
}

$Drives = Get-WmiObject -Class WIN32_LogicalDisk -Filter "DriveType = 3"
foreach($Drive in $Drives)
{
    $Name = $Drive.DeviceID
    $SizeInfo = Get-Size($Drive.Size)
    $Size = "{0:N2} {1}" -f $SizeInfo.Size, $SizeInfo.SizeShort
    $FreeInfo = Get-Size($Drive.FreeSpace)
    $FreeSpace = "{0:N2} {1}" -f $FreeInfo.Size, $FreeInfo.SizeShort
    $FreePercent = "{0:P2}" -f ($Drive.FreeSpace / $Drive.Size)
    $MinFree = $Drive.Size * .1
    if($MinFree -ge $Drive.FreeSpace)
    {
        $NeedSpace = ($Drive.Size * .1 - $Drive.FreeSpace)
        $NeedInfo = Get-Size($NeedSpace)
        $Need = "Needs {0:N2} {1}" -f $NeedInfo.Size, $NeedInfo.SizeShort
    }
    Else
    {
        $Need = 'is All Good'
    }
    Write-Output "$Name is $Size with $FreeSpace ($FreePercent). $Name $Need"
}