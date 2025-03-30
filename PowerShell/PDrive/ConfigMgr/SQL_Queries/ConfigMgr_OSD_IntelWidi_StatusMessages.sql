SELECT adv.PackageName, adv.CollectionName, sys.Netbios_Name0, executiontime, step, actionname, groupname, LastStatusMessageID, ExitCode, ActionOutput
FROM            dbo.v_TaskExecutionStatus tse INNER JOIN
                dbo.v_advertisementinfo Adv ON tse.AdvertisementID = adv.AdvertisementID INNER JOIN
				dbo.v_r_system SYS ON tse.ResourceID = SYS.ResourceID
--WHERE        (tse.ExitCode = '16389')
WHERE tse.ActionName = 'Intel WiDi 3.5.40.0'
ORDER BY ExecutionTime DESC