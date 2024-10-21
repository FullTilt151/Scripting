$wim = '\\lounaswps01\pdrive\dept907.cit\osd\images\boot\MDT_WinPE_5.0_LDC_x64_Dynamic_Servers\winpe.wim'
#$wim = '\\lounaswps01\pdrive\dept907.cit\osd\images\boot\MDT_WinPE_5.0_LDC_x64_Dynamic_Servers\WinPE.LDC0000F.wim'
$mountdir = "E:\mount1"

$NeededDrivers = @(
'Cisco VIC Ethernet Interface',
'Cisco VIC-FCoE Storport Miniport',
'Emulex LightPulse HBA - Storport Miniport Driver',
'Emulex OneConnect OCe11101(R)-N 1-port 10GbE SFP+ PCIe NIC',
'Emulex OneConnect OCe11101(R)-N 1-port 10GbE SFP+ PCIe NIC',
'Emulex OneConnect OCe11101(R)-N 1-port 10GbE SFP+ PCIe NIC',
'HP NC1020 Gigabit Server Adapter 32 PCI',
'HP NC370T Multifunction Gigabit Server Adapter',
'Intel(R) 82599 Multi-Function Network Device',
'Intel(R) 82599 Virtual Function',
'Intel(R) I350 Gigabit Server Adapter',
'Intel(R) Raid Controller SRCSAS18E',
'Intel(R) X540 Multi-Function Network Device',
'LSI WarpDrive Solid State Storage',
'QLogic Teaming Virtual Adapter'
)

# Gather list of drivers needed
#Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_CAS -Class sms_driver -Filter "DriverInfFile='ocnd64.inf'" `
Get-WmiObject -ComputerName LOUAPPWPS875 -Namespace root\sms\site_CAS -Class sms_driver -Filter "LocalizedDisplayName='$DriverName'" `
-Property CI_ID, LocalizedDisplayName, ContentSourcePath, DriverInfFile, DriverVersion, LocalizedCategoryInstanceNames | Format-Table CI_ID, LocalizedDisplayName, DriverVersion, ContentSourcePath,DriverInfFile, LocalizedCategoryInstanceNames -AutoSize

$driverinfpath = "\\lounaswps01\pdrive\dept907.cit\OSD\source\Drivers\CISCO3\VIC2\fnic2k12.inf" # Success
$driverinfpath = "\\lounaswps01\pdrive\Dept907.CIT\OSD\source\Drivers\CISCO2\lsi_sss.inf" # Failed
$driverinfpath = "\\lounaswps01\pdrive\Dept907.CIT\OSD\source\Drivers\CISCO2\oemsetup.inf" # Failed
$driverinfpath = "\\lounaswps01\pdrive\dept907.cit\osd\source\Drivers\HP\ProLiant\ws2012r2-x64\elxfc\elxfc.inf" # Success
$driverinfpath = "\\lounaswps01\pdrive\dept907.cit\OSD\source\Drivers\CISCO3\LSI\x64\megasas2.inf" # Success

$driverinfpath = "\\lourdpwps03\f$\MS_SCCM_OSD\Cisco\Network\Cisco\VIC\W2K12R2\x64\enic6x64.inf" # Success
$driverinfpath = "\\lourdpwps03\f$\MS_SCCM_OSD\Cisco\Storage\Cisco\VIC\W2K12R2\x64\fnic2k12.inf" # Success
$driverinfpath = "\\lourdpwps03\f$\MS_SCCM_OSD\Cisco\Storage\LSI\UCSB-MRAID12G-HE\W2K12R2\x64\megasas2.inf" # Success

$driverinfpath = "\\lounaswps01\pdrive\dept907.cit\osd\source\Drivers\HP\ProLiant\ws2012r2-x64\ocnd64\ocnd64.inf" # Success

$SourceDrivers += Get-ChildItem 'F:\temp\Drivers\Cisco' -Filter *.inf -Recurse | Select-Object -ExpandProperty FullName
$SourceDrivers += Get-ChildItem 'f:\temp\Drivers\HP' -Filter *.inf -Recurse | Select-Object -ExpandProperty FullName

if (-not (Test-Path $mountdir)) {
    New-Item $mountdir -ItemType Directory
}

& "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Mount-Wim /WimFile:"$wim" /index:1 /MountDir:"$mountdir"
foreach ($driver in $SourceDrivers) {
    & "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Add-Driver /Image:"$mountdir" /Driver:"$driver" /forceunsigned
}
& "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Get-Drivers /Image:"$mountdir" | out-file c:\temp\drivers.txt
& "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Unmount-Wim /MountDir:"$mountdir" /commit
& "C:\Program Files (x86)\Windows Kits\8.1\Assessment and Deployment Kit\Deployment Tools\amd64\DISM\Dism.exe" /Unmount-Wim /MountDir:"$mountdir" /discard