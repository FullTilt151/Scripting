--Initial query for full sync:
select * from SCCM_Ext.vex_FullCollectionMembership where ChangeAction='U'

--Using the maximum rowversion returned from the results, run the delta query:
select * from SCCM_Ext.vex_FullCollectionMembership where rowversion > <maximum rowversion>