SELECT [inst_smio_id]
                                ,SMI.smio_MachineName
                                ,SMI.smio_MachineGroup
                                ,SMI.smio_inactivity_date_utc
                                ,SMI.smio_LastHW_ScanDate
FROM [dbo].[Installation] AS INST
LEFT JOIN SiteMachineInfo AS SMI ON INST.inst_smio_id = SMI.smio_id
where inst_prd_id = 30522
AND SMI.smio_inactivity_date_utc IS NULL
ORDER BY SMI.smio_LastHW_ScanDate DESC
