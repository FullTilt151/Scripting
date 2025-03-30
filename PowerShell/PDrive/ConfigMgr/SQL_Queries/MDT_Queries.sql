-- Make and model entries
select m.id, m.make, m.model,  biospackage, bioscommand, driverpackage, driverpackagewin7
from settings s full join
	 MakeModelIdentity m on s.id = M.ID
where model is not null
	  --and BIOSPackage = 'WP100324' 
	  and model like '%20es%'
	  and s.id in (
		251,
		252,
		253,
		254,
		255,
		256
)

/*
update settings
set BIOSPackage = ''
where BIOSPackage = 'WP100324'
*/

/*
delete 
from MakeModelIdentity
where id in (
select m.id
from settings s full join
	 MakeModelIdentity m on s.id = M.ID
where BIOSCommand is null)
*/

-- Computer entries
select ci.ID, SerialNumber, SMSTSRole
from ComputerIdentity CI join
	 Settings s on ci.ID = s.ID
where type = 'C' and SerialNumber = 'MJ0508T5'
order by serialnumber

/*
delete 
from Settings s
where type = 'C' and id in (
select id from ComputerIdentity where SerialNumber = 'MJ0508T5')
*/