--Use this command if SUSDB is in single user mode
--ALTER DATABASE SUSDB
--SET MULTI_USER

--Find active process on SUSDB.  Will have to use Kill to stop process to move DB back to multi user mode
select d.name, d.dbid, spid, login_time, nt_domain, nt_username, loginame
from sysprocesses p inner join sysdatabases d on p.dbid = d.dbid
where d.name = 'SUSDB'
go

--kill 59

sp_who2
