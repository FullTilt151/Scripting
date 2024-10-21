-- Policy for a task sequence
select * from Policy where PolicyID like '%WP1005D8%'
select CONVERT(XML,Body) FROM Policy WHERE PolicyID = 'DEP-WP1267DB-WP1005D8-6F6BCC28'

-- Policies for a machine
select *
from ResPolicyMap
where machineid in (select resourceid from v_r_system where Netbios_Name0 = 'louxdwdeve0161')

-- Policies with NULL BodyHash
select top 100 *
from PolicyAssignment
--where BodyHash IS NULL
where PolicyID like '%CAS00E63%'
order by FLOOR(Version) DESC

-- Package hashes
select *
from smspackages_g
--where NewHash = ''
--where pkgid = 'CAS00D1A'
where pkgid in 
(select RefPackageID
from v_TaskSequencePackageReferences
where packageid = 'CAS00A92')

-- Packages by PackageID
select *
from v_Package 
where packageid = 'CAS00D1A'

-- Adverts by AdvertID
select *
from v_Advertisement
--where AdvertisementID = 'CAS23EBE'
where packageid = 'CAS00d1a'

-- Policies by PolicyAssignment ID
select *
from PolicyAssignment
where PolicyAssignmentID = '{c621e641-df96-4505-b9e2-612c6c6b575d}'

select *
from PolicyAssignment
where PADBID = '19135458'

/*
delete
from PolicyAssignment
where PADBID = '19135458'
*/

-- Count of policy updates
Set NoCount ON;
Select  distinct stat.RecordID,
stat.SiteCode,
(insPid.InsStrValue + ' - ' + insN.InsStrValue) as Pkg
into #tmpRecords
from v_StatusMessage as stat
left outer join v_StatMsgAttributes as att on stat.recordid = att.recordid 
left outer join v_StatMsgInsStrings as insN on stat.recordid = insN.recordid 
left outer join v_StatMsgInsStrings as insPid on stat.recordid = insPid.recordid 

WHERE (COMPONENT='SMS_POLICY_PROVIDER')
AND (stat.Time>=DATEADD(HOUR, -1, SYSDATETIME())) 
and stat.MessageID = 5101
and insN.InsStrIndex = 0
and insPid.InsStrIndex = 1;

Set NoCount Off;
select SiteCode, Pkg, count(*) as Total
from #tmpRecords
group by SiteCode, Pkg
order by SiteCode, count(*) desc;
drop table #tmpRecords;

-- Count of policy updates
declare @TimeFrame int
set @timeframe = '-24'

SELECT        Stat.SiteCode, Ins.InsStrValue AS Name, PIIns.InsStrValue AS PackageID, Att1.AttributeValue AS Deployment, COUNT(*) AS Total
FROM            v_StatusMessage AS Stat LEFT OUTER JOIN
                         v_StatMsgInsStrings AS Ins ON Ins.RecordID = Stat.RecordID LEFT OUTER JOIN
                         v_StatMsgAttributes AS Att1 ON Att1.RecordID = Stat.RecordID INNER JOIN
                         v_StatMsgInsStrings AS PIIns ON PIIns.RecordID = Ins.RecordID
WHERE        (Stat.MessageID = 5101) AND (PIIns.InsStrIndex = 1) AND (Ins.InsStrIndex = 0) AND (Att1.AttributeID = 405) AND (Stat.Time >= DATEADD(HOUR, @TimeFrame, SYSDATETIME()))
GROUP BY Stat.SiteCode, Ins.InsStrValue, PIIns.InsStrValue, Att1.AttributeValue
HAVING        (COUNT(*) > '15')
ORDER BY Stat.SiteCode, total DESC


-- List of policy updates
declare @TimeFrame int
set @timeframe = '-1'
SELECT        Stat.Time, Stat.SiteCode, stat.MachineName, Ins.InsStrValue [Pkg], PIIns.InsStrValue [PkgID], Att1.AttributeValue [Deployment]
FROM            v_StatusMessage AS Stat LEFT OUTER JOIN
                         v_StatMsgInsStrings AS Ins ON Ins.RecordID = Stat.RecordID LEFT OUTER JOIN
                         v_StatMsgAttributes AS Att1 ON Att1.RecordID = Stat.RecordID INNER JOIN
                         v_StatMsgInsStrings AS PIIns ON PIIns.RecordID = Ins.RecordID
WHERE        (Stat.MessageID = 5101) AND (PIIns.InsStrIndex = 1) AND (Ins.InsStrIndex = 0) AND (Att1.AttributeID = 405) AND (Stat.Time >= DATEADD(HOUR, @TimeFrame, SYSDATETIME()))
ORDER BY Time DESC

-- Packages without policies
select N'SMS10000', t1.PkgID, t1.Name,pkg.Manufacturer, pkg.Name, pkg.Version, pkg.SourceDate, pkg.LastRefreshTime
from PkgPrograms as t1 LEFT JOIN 
	 SoftwarePolicy as t2 on t2.OfferID=N'SMS10000' and 
	 t1.PkgID = t2.PkgID and 
	 t1.Name = t2.ProgramName join
	 v_Package PKG on t1.PkgID = pkg.PackageID
where (t1.ProgramFlags & 1) != 0 and 
	  t2.OfferID is NULL
order by SourceDate DESC