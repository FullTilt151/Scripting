select distinct MachineAccount [WKID], wkid.LastInventoryUpdate, AM.PackageName [PkgID], Pkg.PackageName [Pkg], SoftwareUsage [Usage]
from tb_OsdRecommendedItem AM join
	 tb_SMSProgram Pkg on AM.PackageName = Pkg.PackageId join
	 tb_Machine WKID on AM.MachineAccount = WKID.MachineName
where MachineAccount = 'WKMJ029CW9'
order by Pkg.PackageName