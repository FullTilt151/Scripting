SELECT (SELECT COUNT(*)
       FROM SiteMachineInfo AS A
       WHERE A.smio_inactivity_date_utc IS NULL
       AND a.smio_MachineRole = 1)
       AS [Number of Active Desktop],

       (SELECT COUNT(*)
       FROM SiteMachineInfo AS A
	   WHERE A.smio_inactivity_date_utc IS NULL
	   AND a.smio_MachineRole = 2)
       AS [Number of Active Servers],

       (SELECT COUNT(*)
       FROM SiteMachineInfo AS A
       WHERE A.smio_inactivity_date_utc IS NULL)
       AS [Total Active clients]
