-- Compliance query - Defender AV, ATP, Bitlocker
select netbios_name0 [Name], build01 [OS build], sys.client_version0 [MEMCM Version], cdr.lastactivetime [MEMCM Last Active], cdr.lasthardwarescan [MEMCM Hardware scan], atp.SenseIsRunning [ATP Running], atp.LastConnected [ATP Last Connected], 
	   ep.EpEnabled [AV Enabled], ep.Healthy [AV Healthy], cdr.ep_Clientversion [AV Version], cdr.EP_AntivirusSignatureUpdateDateTime [AV Definition Date], 
	   bl.compliant0 [BL Compliance], bl.noncompliancedetecteddate0 [BL Noncompliance date], bl.reasonsfornoncompliance0 [BL Noncompliance reason]
from v_r_system sys left join
	 vSMS_G_System_AdvancedThreatProtectionHealthStatus atp on sys.ResourceID = atp.ResourceID left join
	 vSMS_G_System_EndpointProtectionStatus ep on sys.ResourceID = ep.ResourceID left join
	 vSMS_CombinedDeviceResources cdr on sys.resourceid = cdr.machineid left join
	 v_GS_BITLOCKER_DETAILS bl on sys.ResourceID = bl.ResourceID
where netbios_name0 = 'SIMXDWSTDB8482'

-- Defender ATP - List of all users
select Netbios_Name0, sys.Build01, atp.SenseIsRunning, atp.OnboardingState, atp.LastConnected
from v_R_System sys left join
	 vSMS_G_System_AdvancedThreatProtectionHealthStatus atp on sys.ResourceID = atp.ResourceID
where OnboardingState = 1
order by Netbios_Name0

-- Defender AV query - All fields
select Name, DeviceOSBuild, EpProtected, EP_DeploymentState, EP_DeploymentErrorCode, EP_DeploymentDescription, EP_PolicyApplicationState, EP_PolicyApplicationErrorCode, EP_PolicyApplicationDescription, EP_Enabled, EP_ClientVersion, 
	   EP_ProductStatus, EP_EngineVersion, EP_AntivirusEnabled, EP_AntivirusSignatureVersion, EP_AntivirusSignatureUpdateDateTime, EP_AntispywareEnabled, EP_AntispywareSignatureVersion, EP_AntispywareSignatureUpdateDateTime, 
	   EP_LastFullScanDateTimeStart, EP_LastFullScanDateTimeEnd, EP_LastQuickScanDateTimeStart, EP_LastQuickScanDateTimeEnd, EP_InfectionStatus, EP_PendingFullScan, EP_PendingReboot, EP_PendingManualSteps, EP_PendingOfflineScan,
	   EP_LastInfectionTime, EP_LastThreatName, eps.*
from vSMS_CombinedDeviceResources cdr inner join
	 vSMS_G_System_EndpointProtectionStatus eps on cdr.MachineID = eps.ResourceID
where name in ('SIMXDWWKF0577')

-- Defender AV - Count of deployed to
select EpEnforcementSucceeded, EpManaged, count(*)
from v_R_System_valid sys left join
	 vSMS_G_System_EndpointProtectionStatus eps on sys.ResourceID = eps.ResourceID
group by EpEnforcementSucceeded, EpManaged

-- Defender AV - Count of EPProtected
select EPEnabled, eps.EpProtected, count(*)
from v_R_System_valid sys inner join
	 vSMS_G_System_EndpointProtectionStatus eps on sys.resourceid = eps.ResourceID
group by EPEnabled, epprotected
order by EPEnabled, epprotected

exec CH_SyncClientSummary

-- Defender AV - EP client versions
select EP_ClientVersion, count(*)
from vSMS_CombinedDeviceResources
where ep_clientversion is not null
group by EP_ClientVersion

-- Defender AV and ATP - Status counts for a collection
select sys.EP_Enabled, ATP_OnboardingState, count(*) [Count]
from v_CombinedDeviceResources sys
where sys.MachineID in (select coll.resourceid from v_CM_RES_COLL_WP1082C7 coll) -- RPA Collection
group by ATP_OnboardingState, sys.EP_Enabled
order by EP_Enabled, ATP_OnboardingState

-- Defender AV status counts for a collection
select eps.EpProtected [AV], count(*) [Count]
from v_r_system sys left join
	 vSMS_G_System_EndpointProtectionStatus eps on sys.ResourceID = eps.ResourceID	 
where sys.ResourceID in (select resourceid from v_cm_res_coll_WP1082C7)
group by eps.EpProtected
order by EpProtected

-- Defender ATP status counts
select atp.OnboardingState, atp.SenseIsRunning, count(*) [Count]
from v_r_system sys left join
	 vSMS_G_System_AdvancedThreatProtectionHealthStatus atp on sys.ResourceID = atp.ResourceID
where Resource_Domain_OR_Workgr0 = 'HUMAD' and Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
	  and client0 = 1
	  and sys.ResourceID not in (select resourceid from v_cm_res_coll_WP100BE4)
group by atp.OnboardingState,atp.SenseIsRunning
order by atp.OnboardingState,SenseIsRunning

-- Defender ATP list of WKIDs and state
select sys.Netbios_Name0, atp.OnboardingState, atp.SenseIsRunning, cdr.PrimaryUser, cdr.CurrentLogonUser, os.InstallDate0, cdr.LastActiveTime
from v_r_system sys left join
	 vSMS_G_System_AdvancedThreatProtectionHealthStatus atp on sys.ResourceID = atp.ResourceID left join
	 v_GS_OPERATING_SYSTEM os on sys.ResourceID = os.ResourceID left join
	 v_CombinedDeviceResources cdr on sys.ResourceID = cdr.MachineID
where Resource_Domain_OR_Workgr0 = 'HUMAD' and Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
	  and ( OnboardingState != 1 or OnboardingState is null)
	  and sys.Client0 = 1
	  and sys.ResourceID not in (select resourceid from v_cm_res_coll_WP100BE4)
order by Netbios_Name0

-- Defender ATP status counts for a collection
select atp.SenseIsRunning [ATP], count(*) [Count]
from v_r_system sys left join
	 vSMS_G_System_AdvancedThreatProtectionHealthStatus atp on sys.ResourceID = atp.ResourceID
where sys.ResourceID in (select resourceid from v_cm_res_coll_wp106F27) or
	  sys.ResourceID in (select resourceid from v_cm_res_coll_wp106F28) or
	  sys.ResourceID in (select resourceid from v_CM_RES_COLL_WP106F29) or
	  sys.ResourceID in (select resourceid from v_CM_RES_COLL_WP106F2A) or
	  sys.ResourceID in (select resourceid from v_CM_RES_COLL_WP106F2B) or
	  sys.ResourceID in (select resourceid from v_CM_RES_COLL_WP106F2C) or
	  sys.ResourceID in (select resourceid from v_CM_RES_COLL_WP106F2D)
group by atp.SenseIsRunning
order by SenseIsRunning

-- Defender AV/ATP list of WKIDs for a collection
select Name, EpProtected,  ATP_SenseIsRunning,
		(select 'X' from v_cm_res_coll_WP106F02 av where cdr.machineid = av.ResourceID) [AV],
		(select 'X' from v_cm_res_coll_WP106F00 mcafee where cdr.machineid = mcafee.ResourceID) [McAfee],
		(select 'X' from v_cm_res_coll_WP106F07 atp where cdr.machineid = atp.ResourceID) [ATP]
from vSMS_CombinedDeviceResources cdr left join
	 vSMS_G_System_EndpointProtectionStatus eps on cdr.MachineID = eps.ResourceID
where MachineID in (select resourceid from v_cm_res_coll_wp106F27) or
	  MachineID in (select resourceid from v_cm_res_coll_wp106F28) or
	  MachineID in (select resourceid from v_CM_RES_COLL_WP106F29) or
	  MachineID in (select resourceid from v_CM_RES_COLL_WP106F2A)
order by [AV] desc,[McAfee] desc,[ATP] desc