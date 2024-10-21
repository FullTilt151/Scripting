select sv32.UpdateConsentMode0 [UCM], sv32.UpdateMode0 [UM], sv64.UpdateConsentMode0 [UCM64], sv64.UpdateMode0 [UM64], count(*) [Count]
from v_R_System_Valid sys left join
	 v_gs_silverlight0 sv32 on sys.ResourceID = sv32.ResourceID left join
	 v_GS_Silverlight640 sv64 on sys.ResourceID = sv64.ResourceID
group by sv32.UpdateConsentMode0, sv32.UpdateMode0, sv64.UpdateConsentMode0, sv64.UpdateMode0
order by sv32.UpdateConsentMode0, sv32.UpdateMode0, sv64.UpdateConsentMode0, sv64.UpdateMode0