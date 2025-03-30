select top 50 * from v_GS_OFFICE_ADDIN
select top 50 * from v_GS_OFFICE_CLIENTMETRIC

-- List of devices with M365A
select sys.Netbios_Name0
from v_r_system_valid sys inner join
	 v_GS_OFFICE_DEVICESUMMARY m365 on sys.ResourceID = m365.ResourceID
where IsProPlusInstalled0 = 1
order by Netbios_Name0

select top 50 * from v_GS_OFFICE_DOCUMENTMETRIC
select top 50 * from v_GS_OFFICE_DOCUMENTSOLUTION
select * from v_GS_OFFICE_MACROERROR

-- WKIDs with top macro errors
select sys.Netbios_Name0, sum(count0) [Count]
from v_R_System_Valid sys inner join
	 v_GS_OFFICE_MACROERROR mac on sys.ResourceID = mac.ResourceID
group by Netbios_Name0
order by Count desc

--- Access usage
select *
from v_GS_CCM_RECENTLY_USED_APPS
where ExplorerFileName0 = 'msaccess.exe'
order by LastUsedTime0 desc

-- Office versions
select Architecture0, Channel0, ProductName0, productversion0, count(*)
from v_GS_OFFICE_PRODUCTINFO
group by Architecture0, Channel0, ProductName0, productversion0
order by Architecture0, Channel0, ProductName0, productversion0

select * from v_GS_OFFICE_VBARULEVIOLATION
select * from v_GS_OFFICE_VBASUMMARY where HasResults0 != 0 order by HasVba0 desc

select top 50 * from vSMS_OfficeMacroHealthDetail -- Many rows, needs analysis
select * from vSMS_OfficeMacroHealthSummary
select distinct documentsolutionid, name, filename, officeproduct, devicecount, overallhealth  from vSMS_OfficePilotMacrosHealth

select * from v_OfficeAddinSummary
select top 50 * from vOfficeAddin_DeviceCount
select top 50 * from vOfficeAddin_VersionCount
select top 50 * from vSMS_OfficeAddinHealthDetail
select top 50 * from vSMS_OfficeAddinReadiness
select distinct MachineName, name, publisher, version, OverallHealth, LoadHealth, RunHealth, AddInHealthStatusReason from vSMS_OfficePilotAddInsHealth

-- Count of macro errors
select issue, severity, RuleDescription, count(*)
from vSMS_OfficeMacroAdvisory
group by issue, severity, RuleDescription

-- List of macro errors
select distinct *
from vSMS_OfficeMacroAdvisory

select * from vSMS_OfficeMacroHealthDetail
select * from vSMS_OfficeMacroHealthSummary

-- Devices ready to deploy counts
select DeploymentReadiness, count(*)
from vSMS_OfficeDevicesReadyToDeploy
group by DeploymentReadiness

-- Devices ready to deploy list
select *
from vSMS_OfficeDevicesReadyToDeploy
where DeploymentReadiness = 1

-- Macro readiness list
select distinct OPR.name,
CASE
WHEN OPR.MacroInventory = '1' THEN 'No Macro Present'
WHEN OPR.MacroInventory = '2' THEN 'Not all scanned'
WHEN OPR.MacroInventory = '3' THEN 'Macro Present'
WHEN OPR.MacroInventory = '4' THEN 'Needs Review'
ELSE 'Other / Unknown' END as 'Macro Readiness'
from vSMS_OfficeProplusReadiness OPR
group by OPR.MacroInventory,OPR.Name

-- Macro readiness count
select distinct OPR.MacroInventory, count(distinct opr.Name)
from vSMS_OfficeProplusReadiness OPR
group by OPR.MacroInventory

-- Addin readiness
select distinct OAR.AddinVersion as 'Addin Version',
OAR.FriendlyName as 'Addin Name',
OAR.AdoptionStatus as 'Adoption Status',
OAR.AddinReadiness as 'Addin Readiness'
from vSMS_OfficeAddinReadiness OAR