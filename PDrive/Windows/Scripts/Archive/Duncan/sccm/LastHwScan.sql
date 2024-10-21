select 'CH_ClientSummary' as [table], MachineID, LastHW from CH_ClientSummary
where MachineID in
(select ResourceID from v_R_System where name0 = 'isbtst06' and Obsolete0 = 0 )

union all

select 'WorkstationStatus_DATA' as [table], MachineID, LastHWScan from WorkstationStatus_DATA
where MachineID in
(select ResourceID from v_R_System where name0 = 'isbtst06' and Obsolete0 = 0 )

select CH_ClientSummary.MachineID, CH_ClientSummary.LastHW as CS_LastHW, WorkstationStatus_DATA.LastHWScan as WK_LastHW from CH_ClientSummary
inner join WorkstationStatus_DATA on CH_ClientSummary.MachineID = WorkstationStatus_DATA.MachineID
where WorkstationStatus_DATA.LastHWScan > CH_ClientSummary.LastHW
