param(
[Parameter(Mandatory=$True)]
$Serial,
[Parameter(Mandatory=$True)]
[ValidateSet('EIPAM','JavaArch','JavaDev','JavaQAL','JavaTest','NETPSD','NETFullStackPro','NETFullStackEnt','NETWebDev','NETUXDev','NETArch','NETMobile','NETQAL','NETTest')]
$SMSTSRole
)

Import-Module \\lounaswps08\pdrive\dept907.cit\ConfigMgr\Scripts\MDTDB\MDTDB.psm1
Connect-MDTDatabase -sqlserver SIMMDTWPS01 -instance MDTDB -database MDTDB

New-MDTComputer -serialNumber $Serial -settings @{OSInstall=’YES’; SMSTSRole="$SMSTSRole"}