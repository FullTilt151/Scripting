-- ### List of WKIDS
select sys.Netbios_Name0, rec.CompanyName0, rec.ExplorerFileName0, rec.FileVersion0, rec.FolderPath0, rec.LastUsedTime0, rec.LastUserName0, rec.msiDisplayName0, rec.msiPublisher0, rec.msiVersion0, rec.ProductCode0, rec.ProductName0, rec.ProductVersion0
from v_r_system SYS JOIN
v_GS_CCM_RECENTLY_USED_APPS REC ON SYS.ResourceID = REC.ResourceID
where ProductName0 = 'adobe air'
order by LastUsedTime0 desc

-- ### Count of Products
select distinct ExplorerFileName0, FolderPath0, ProductName0, count(distinct sys.Netbios_Name0) [Count]
from v_r_system SYS JOIN
v_GS_CCM_RECENTLY_USED_APPS REC ON SYS.ResourceID = REC.ResourceID
where ProductName0 in (@Product) and 
		LastUsedTime0 > DATEADD(Day, Convert(Int,@Days) ,getdate()) and
		folderpath0 like 'c:\%' and
		folderpath0 not like 'c:\temp%'
group by ExplorerFileName0, FolderPath0, ProductName0
order by ExplorerFileName0, FolderPath0

-- ### List of Products 
select distinct ProductName0
from v_GS_CCM_RECENTLY_USED_APPS
order by ProductName0