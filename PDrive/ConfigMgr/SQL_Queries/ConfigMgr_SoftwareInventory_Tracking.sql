Declare @Product varchar(255)
Declare @FileName varchar(255)
 
set @Product = 'android'
set @FileName = '5646.exe'
select FileName, FileVersion, FilePath, count(*) [Count]
from v_GS_SoftwareFile
where FileName = @FileName
group by FileName, FileVersion, FilePath
order by FileName, FileVersion, FilePath
 
select Publisher0, ProductName0, ProductVersion0, count(*) [Count]
from v_GS_INSTALLED_SOFTWARE
where ProductName0 like '%' + @Product + '%'
group by Publisher0, ProductName0, ProductVersion0
order by Publisher0, ProductName0, ProductVersion0
 
select Publisher0, DisplayName0, Version0, Count(*) [Count]
from v_Add_Remove_Programs
where DisplayName0 like '%' + @Product + '%'
group by Publisher0, DisplayName0, Version0
order by Publisher0, DisplayName0, Version0