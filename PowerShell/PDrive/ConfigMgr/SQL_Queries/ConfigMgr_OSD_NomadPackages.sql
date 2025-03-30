SELECT  PackageID0, Percent0, Version0, CAST(DiskUsageKB0 as bigint)/1024 [Size], pkg.Name, pkg.Version, pkg.SourceVersion, count(*) [Count]
FROM    v_r_system sys join
	    dbo.v_GS__E_NomadPackages0 NOMAD ON sys.resourceid = nomad.resourceid join
		v_Package PKG on nomad.PackageID0 = pkg.PackageID
where Netbios_Name0 like '%pxewpw%'
	  --and nomad.PackageID0 = 'CAS0036F'
group by PackageID0, Percent0, Version0, DiskUsageKB0, pkg.Name, pkg.Version, pkg.SourceVersion
order by [Size] DESC

select RefPackageID
from v_TaskSequencePackageReferences
where PackageID = 'CAS00083'