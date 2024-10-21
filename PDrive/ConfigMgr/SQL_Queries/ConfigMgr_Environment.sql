-- PATH entry counts
select distinct entry0 [Path entry], count(sys.ResourceID) [Count]
from v_R_System_Valid sys join
	 v_gs_path_custom PATH on sys.ResourceID = PATH.ResourceID
where Entry0 like '%' + @Path + '%'
group by Entry0
order by Entry0 desc

-- PATH by WKID
select distinct sys.Netbios_Name0, SUM(LEN(Entry0)) over (partition by path0.resourceid) [Sum],
		(SELECT stuff((SELECT ',' + Entry0
               FROM v_GS_PATH_CUSTOM PATH2
               WHERE PATH2.ResourceID = PATH1.ResourceID
			   order by Position0
               FOR XML PATH(''), TYPE).value('.', 'varchar(max)')
            ,1,1,'')
		FROM v_GS_PATH_CUSTOM PATH1
		WHERE PATH1.ResourceID = PATH0.ResourceID
		GROUP BY PATH1.ResourceID) [PATH]
from v_R_System_Valid sys left join
	 v_GS_PATH_CUSTOM path0 on sys.ResourceID = path0.ResourceID
where sys.Netbios_Name0 in (@WKIDs)
order by sys.Netbios_Name0 desc

-- WKIDs with a PATH
select sys.netbios_name0 [WKID], entry0 [Path entry]
from v_R_System_Valid sys join
	 v_gs_path_custom PATH on sys.ResourceID = PATH.ResourceID
where Entry0 like '%' + @Path + '%'
order by WKID

-- WKIDs with error 60002
select sys.Netbios_Name0, LastExecutionResult, count(*) [Total]
from v_R_System_Valid sys join
	 v_ClientAdvertisementStatus CAS on sys.ResourceID = cas.ResourceID join
	 v_AdvertisementInfo AI on CAS.AdvertisementID = AI.AdvertisementID
where LastExecutionResult = 60002
group by Netbios_Name0, LastExecutionResult
order by Netbios_Name0

-- Deployments with error 60002
select ai.PackageID, Pkg.Manufacturer ,Pkg.Name, Pkg.Version, ai.ProgramName, LastExecutionResult, count(*) [Total]
from v_R_System_Valid sys join
	 v_ClientAdvertisementStatus CAS on sys.ResourceID = cas.ResourceID join
	 v_AdvertisementInfo AI on CAS.AdvertisementID = AI.AdvertisementID join
	 v_Package Pkg on AI.PackageID = Pkg.PackageID
where LastExecutionResult = 60002
group by ai.PackageID, Pkg.Manufacturer ,Pkg.Name, Pkg.Version, ai.ProgramName, LastExecutionResult
having count(*) > 1
order by Manufacturer, Name, Version