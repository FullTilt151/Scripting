declare @OS table (Value varchar(1000)) 
insert into @OS values ('Microsoft Windows NT Workstation 10.0'),('Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
--insert into @OS values ('Microsoft Windows NT Workstation 6.1')

-- Citrix Receiver versions
select top 7 ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 like 'Citrix Receiver %' and sft.ProductName0 not in ('Citrix Receiver (HDX Flash Redirection)','Citrix Receiver Inside','Citrix Receiver Updater') and Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
order by count(*) DESC

-- Voicerite versions
select ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (productname0 = 'VoiceRite Desktop Client' or ProductName0 like 'ThinkRite Voice Desktop Client%') and Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
order by count(*) DESC

-- Oracle JRE versions
select top 10 ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (productname0 like 'Java 2 Runtime Environment%' or 
	  productname0 like 'Java 7 Update%' or 
	  productname0 like 'Java 8 Update%' or
	  productname0 like 'Java(TM)%' or
	  productname0 like 'Java 2 Runtime Environment%') and 
	  productname0 not like 'Java(TM) SE Development Kit%' and	  
      Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
order by count(*) DESC

-- Adobe Reader versions
select ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (productname0 like 'Adobe Reader%' or ProductName0 like 'Adobe Acrobat Reader%') and 
	  Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
order by count(*) DESC

-- Silverlight versions
select ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (productname0 = 'Microsoft Silverlight') and 
	  Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
order by count(*) DESC

-- Visual C++ Redis versions
select ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (productname0 like 'Microsoft Visual C++%Redistributable%') and 
	  Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
having count(*) > 100
order by ProductName0, ProductVersion0 DESC

-- Visual Studio Tools for Office
select distinct top 10 ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (productname0 = 'Microsoft Visual Studio 2010 Tools for Office Runtime (x64)') and 
	  Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
order by count(*) DESC

-- Cisco Webex Meetings
select ProductName0 [Product], ProductVersion0 [Version], count(*)
from v_r_system SYS join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where (productname0 = 'Cisco WebEx Meeting Center') and 
	  Operating_System_Name_and0 in (select value from @OS)
group by ProductName0, ProductVersion0
order by count(*) DESC