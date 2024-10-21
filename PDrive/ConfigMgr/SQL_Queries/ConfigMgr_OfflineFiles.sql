-- List of VMs and Offline files status
select sys.netbios_name0 [WKID], svc.DisplayName0 [Service Display Name], svc.Name0 [Service Name], svc.StartMode0 [Start Mode]
from v_r_system SYS join
	 v_GS_SERVICE SVC on sys.resourceid = svc.resourceid
where sys.Client0 = '1' and
	  svc.Name0 = 'CscService' and
	  sys.Is_Virtual_Machine0 = '1' and
	  sys.Operating_System_Name_and0 like '%workstation%'
order by sys.Netbios_Name0

-- Count of VMs and Offline files status
select svc.DisplayName0 [Service Display Name], svc.Name0 [Service Name], svc.StartMode0 [Start Mode], count(*) [Total]
from v_r_system SYS join
	 v_GS_SERVICE SVC on sys.resourceid = svc.resourceid
where sys.Client0 = '1' and
	  svc.Name0 = 'CscService' and
	  sys.Is_Virtual_Machine0 = '1' and
	  sys.Operating_System_Name_and0 like '%workstation%'
group by svc.DisplayName0, svc.Name0, svc.StartMode0

-- Offline files inventory
select sys.Netbios_Name0 [WKID], sys.Is_Virtual_Machine0 [VM], ItemPath0 [Path], ItemName0 [Name], 
	   case ItemType0
	   when '0' then 'File'
	   when '1' then 'Directory'
	   when '2' then 'Share'
	   when '3' then 'Server'
	   end [Type]
from v_R_System SYS join
	  v_GS_OFFLINE_FILES_ITEM OFI on sys.ResourceID = ofi.ResourceID
where sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP'
order by WKID

-- Offline files count
select sys.Is_Virtual_Machine0 [VM], count(*) [Total]
from v_R_System SYS join
	  v_GS_OFFLINE_FILES_ITEM OFI on sys.ResourceID = ofi.ResourceID
where sys.Resource_Domain_OR_Workgr0 != 'HMHSCHAMP'
group by sys.Is_Virtual_Machine0