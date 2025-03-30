select *
from tb_Machine
where MachineName = 'WKR9032TWX'

select *
from tb_OsdWizard
where MachineId = 38713

select *
from tb_User
where FullName like '%clapp%'

SELECT FullName, MachineName, LastCompletedStep
FROM tb_machine MAC
JOIN tb_OsdWizard WIZ 
ON MAC.MachineId = WIZ.MachineId
JOIN tb_user U
ON WIZ.UserId = U.UserId
where FullName like '%clapp%'

SELECT FullName, MachineName,
	CASE LastCompletedStep
	WHEN  0 THEN 'Please select your operating system'
	WHEN  1 THEN 'Select Applications to Re-install'
	WHEN  2 THEN 'Scheduling'
	WHEN  3 THEN 'Summmary'
	WHEN  4 THEN 'Completed'
	END LastCompletedStep, HasConfirmedBackup
FROM tb_machine MAC
JOIN tb_OsdWizard WIZ 
ON MAC.MachineId = WIZ.MachineId
JOIN tb_user U
ON WIZ.UserId = U.UserId