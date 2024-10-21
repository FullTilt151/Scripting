$AllDevicesQuery = @"
select case IsVirtualMachine
		when 0 then 'Physical'
		when 1 then 'Virtual'
	  end [Platform], count(*) [Online]
from v_CombinedDeviceResources
where CNIsOnline = 1 and Domain = 'HUMAD' and IsVirtualMachine is not null
group by case IsVirtualMachine
		when 0 then 'Physical'
		when 1 then 'Virtual'
	  end
"@

$IPUTargetDevicesQuery = @"
select case IsVirtualMachine
		when 0 then 'Physical'
		when 1 then 'Virtual'
	  end [Platform], count(*) [Online]
from v_CombinedDeviceResources
where CNIsOnline = 1 and Domain = 'HUMAD' and IsVirtualMachine is not null and 
	  (DeviceOSBuild like '10.0.14393%' or DeviceOSBuild like '10.0.15063%' or DeviceOSBuild like '10.0.16299%' or DeviceOSBuild like '10.0.17134%')
group by case IsVirtualMachine
		when 0 then 'Physical'
		when 1 then 'Virtual'
	  end
"@

$AllDevicesResults = Invoke-Sqlcmd -ServerInstance CMWPDB.humad.com -Database CM_WP1 -Query $AllDevicesQuery

$IPUResults = Invoke-Sqlcmd -ServerInstance CMWPDB.humad.com -Database CM_WP1 -Query $IPUTargetDevicesQuery