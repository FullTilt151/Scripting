-- Patch compliance by MS ID
SELECT     dbo.vSMS_SoftwareUpdate.BulletinID, dbo.vSMS_SoftwareUpdate.ArticleID, dbo.v_UpdateInfo.Title, dbo.v_UpdateInfo.Description, 
                      dbo.vSMS_SoftwareUpdate.NumMissing, dbo.vSMS_SoftwareUpdate.NumPresent, dbo.vSMS_SoftwareUpdate.NumNotApplicable, 
                      dbo.vSMS_SoftwareUpdate.PercentCompliant, dbo.v_UpdateInfo.IsSuperseded, dbo.vSMS_SoftwareUpdate.SeverityName, dbo.vSMS_SoftwareUpdate.NumUnknown, 
                      dbo.vSMS_SoftwareUpdate.NumTotal
FROM         dbo.vSMS_SoftwareUpdate INNER JOIN
                      dbo.v_UpdateInfo ON dbo.vSMS_SoftwareUpdate.CI_ID = dbo.v_UpdateInfo.CI_ID
Where dbo.v_UpdateInfo.Title NOT LIKE '%Server%' and
	  NumMissing > 1

-- Update info
select top 5 BulletinID, ArticleID, IsSuperseded, IsLatest, DatePosted, DateRevised, Title, Description, InfoURL, UpdateType
from v_UpdateInfo

-- List of WKIDs by MS ID and status
select a.netbios_name0 [WKID], Resource_Domain_OR_Workgr0 [Domain], BulletinID, ArticleID, Title, 
			 case ui.IsSuperseded
			 when '0' then 'No'
			 when '1' then 'Yes'
			 end [Superseded],
			 case comp.Status
			 when '0' then 'Unknown'
			 when '1' then 'Not required'
			 when '2' then 'Missing'
			 when '3' then 'Installed'
			 end [Status]
from v_R_System a
join v_Update_ComplianceStatusAll comp on a.ResourceID=comp.ResourceID
join v_UpdateInfo ui on comp.CI_ID=ui.CI_ID
where Netbios_Name0 in (
	select Name
	from v_CM_RES_COLL_CAS0179A
)
and ui.BulletinID in (
'MS13-044',
'MS13-074',
'MS13-106',
'MS14-001',
'MS14-009',
'MS14-014',
'MS14-024',
'MS14-064',
'MS14-066',
'MS14-068',
'MS14-079',
'MS14-080',
'MS14-081'

)-- and comp.status != '1'
order by BulletinID, ArticleID, Title

-- List of WKIDs by MS ID and status, grouped
select Resource_Domain_OR_Workgr0 [Domain], BulletinID, ArticleID, Title, ui.IsSuperseded, 
			 case comp.Status
			 when '0' then 'Unknown'
			 when '1' then 'Not required'
			 when '2' then 'Missing'
			 when '3' then 'Installed'
			 end [Status],
			 count(*) [Total], (count(*)*100/868) [Percentage]
from v_R_System a
join v_Update_ComplianceStatusAll comp on a.ResourceID=comp.ResourceID
join v_UpdateInfo ui on comp.CI_ID=ui.CI_ID
where Netbios_Name0 in (
	select Name
	from v_CM_RES_COLL_CAS0179A
)
group by Resource_Domain_OR_Workgr0, BulletinID, ArticleID, Title, ui.IsSuperseded, 
			 comp.Status
having  (comp.Status = '1' and Count(*) != '868') or (comp.Status != '1')
order by BulletinID, ArticleID, Title


-- Patch compliance state for a WKID
select comp.*, ui.BulletinID, ui.ArticleID, ui.Title
from v_Update_ComplianceStatusAll comp
join v_UpdateInfo ui on comp.CI_ID=ui.CI_ID
where ResourceID = '16830050'
order by BulletinID, ArticleID, Title

--
DECLARE @X as dec, @y as dec
SET @x = (select *,
NumPresent
from v_CIAssignmentToCI cia 
join v_UpdateInfo ui on cia.CI_ID = ui.CI_ID
join (v_CICategories_All catall join v_CategoryInfo catinfo on catall.CategoryInstance_UniqueID = catinfo.CategoryInstance_UniqueID and catinfo.CategoryTypeName='Company') 
on catall.CI_ID=ui.CI_ID
left join v_CITargetedCollections col on col.CI_ID=ui.CI_ID and col.CollectionID='CAS00ABE'
join v_UpdateSummaryPerCollection us on us.CI_ID=ui.CI_ID and us.CollectionID='CAS00ABE'
where cia.AssignmentID='1733'
)
SET @y = (select 
SUM(NumMissing)
from v_CIAssignmentToCI cia 
join v_UpdateInfo ui on cia.CI_ID = ui.CI_ID
join (v_CICategories_All catall join v_CategoryInfo catinfo on catall.CategoryInstance_UniqueID = catinfo.CategoryInstance_UniqueID and catinfo.CategoryTypeName='Company') 
on catall.CI_ID=ui.CI_ID
left join v_CITargetedCollections col on col.CI_ID=ui.CI_ID and col.CollectionID='CAS00ABE'
join v_UpdateSummaryPerCollection us on us.CI_ID=ui.CI_ID and us.CollectionID='CAS00ABE'
where cia.AssignmentID='1733'
)
SELECT @x as 'Total Patches Installed', @y as 'Total Patches Required', convert(Decimal(19,2),((@x-@y)/@x)*100 ) as 'Compliance %'


select us.CollectionID, us.CollectionName, AssignmentID, BulletinID, ArticleID, DatePosted, DateRevised, RevisionNumber, Title, Description, IsSuperseded, IsLatest,  NumNotApplicable, NumMissing, NumPresent, NumInstalled, NumFailed, NumPending, NumUnknown
from v_CIAssignmentToCI cia 
join v_UpdateInfo ui on cia.CI_ID = ui.CI_ID
join (v_CICategories_All catall join v_CategoryInfo catinfo on catall.CategoryInstance_UniqueID = catinfo.CategoryInstance_UniqueID and catinfo.CategoryTypeName='Company') 
on catall.CI_ID=ui.CI_ID
left join v_CITargetedCollections col on col.CI_ID=ui.CI_ID and col.CollectionID='CAS017A2'
join v_UpdateSummaryPerCollection us on us.CI_ID=ui.CI_ID and us.CollectionID='CAS017A2'
order by BulletinID, ArticleID

select *
from v_CIAssignmentToCI