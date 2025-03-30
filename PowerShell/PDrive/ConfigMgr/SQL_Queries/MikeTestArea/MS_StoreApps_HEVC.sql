select sms.name0, sms.User_Name0, gsapp.ApplicationName0, gsapp.Version0, 
case when parsename(gsapp.Version0,2) < '31822' then 'NONCOMPLIANT' 
else 'COMPLIANT' end as status
from v_r_system sms 
join v_GS_WINDOWS8_APPLICATION gsapp on gsapp.ResourceID=sms.ResourceID
where gsapp.ApplicationName0 like '%Microsoft.HEVCVideoExtension%'
order by status


select gsapp.ApplicationName0, gsapp.Version0, count(*)
from v_r_system sms 
join v_GS_WINDOWS8_APPLICATION gsapp on gsapp.ResourceID=sms.ResourceID
where gsapp.ApplicationName0 = 'Microsoft.HEIFImageExtension'
group by gsapp.ApplicationName0, gsapp.Version0
order by gsapp.Version0