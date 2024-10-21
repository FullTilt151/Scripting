--Check DB for any applications marked for deletion but 'stuck'
select *
from tb_Application
where MarkedForDeletion = 1


--Run stored proc below to remove apps from the database that EUX messed up. https://1eportal.force.com/s/article/KB000001943

--EXEC [dbo].[spDeleteMarkedEntries]

