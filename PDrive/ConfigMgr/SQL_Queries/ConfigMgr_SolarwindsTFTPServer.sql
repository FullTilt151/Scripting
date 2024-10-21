select cdr.Name, cdr.LastLogonUser, usr.title0, usr.department0, sft.ProductName0
from vSMS_CombinedDeviceResources cdr inner join
	 v_GS_INSTALLED_SOFTWARE sft on cdr.MachineID = sft.ResourceID inner join
	 v_R_User usr on cdr.LastLogonUser = usr.User_Name0 and usr.Full_Domain_Name0 = 'HUMAD.COM'
where sft.ProductName0 = 'Solarwinds TFTP Server'
order by department0