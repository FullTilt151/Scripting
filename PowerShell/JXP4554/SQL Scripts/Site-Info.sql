SELECT DISTINCT Client_Version0,
	count(*) [Count]
FROM v_R_System_Valid
GROUP BY Client_Version0
ORDER BY Client_Version0
