-- OSD packages and apps
select ref.PackageID, ref.refpackageid, pkg.Manufacturer, pkg.Name, pkg.Version, pkg.PkgSourcePath,
	   case pkg.PackageType
	   when 8 then 'Application'
	   when 4 then 'Task sequence'
	   when 0 then 'Package'
	   when 258 then 'Boot Image'
	   when 257 then 'OS image'
	   end [Type]
from v_TaskSequencePackageReferences ref inner join
	 v_Package pkg on ref.RefPackageID = pkg.PackageID
where ref.packageid = 'WP100624'
order by PkgSourcePath