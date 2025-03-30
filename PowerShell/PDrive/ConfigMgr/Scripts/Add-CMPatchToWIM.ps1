$wim = 'D:\temp\Win_Svr_2008_R2_SP1_64Bit.wim'
$mountdir = "D:\mount"

if (-not (Test-Path $mountdir)) {
    New-Item $mountdir -ItemType Directory
}

& "D:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Mount-Wim /WimFile:"$wim" /index:1 /MountDir:"$mountdir"
& "D:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Add-Package /Image:"$mountdir" /PackagePath:"D:\temp\2990941\Windows6.1-KB2990941-v3-x64.cab" 
& "D:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Unmount-Wim /MountDir:"$mountdir" /commit