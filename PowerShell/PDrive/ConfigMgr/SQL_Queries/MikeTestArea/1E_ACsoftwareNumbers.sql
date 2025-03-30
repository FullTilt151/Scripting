SELECT applicationid, 
       rawpublisher, 
       rawproduct, 
       rawrelease, 
       installcount 
FROM   (SELECT uapp_guid           ApplicationId, 
               uapp_publisher_desc RawPublisher, 
               wisc_installcount   InstallCount, 
               uapp_product_desc   RawProduct, 
               uapp_release        RawRelease, 
               pub_name            Publisher, 
               prd_product         Product, 
               prd_edition         Edition, 
               CASE 
                 WHEN prl_rel_name IS NULL THEN '(unknown)' 
                 ELSE prl_rel_name 
               END                 Release 
        FROM   application 
               JOIN wrkinstallcount 
                 ON wisc_uapp_guid = uapp_guid 
               JOIN product 
                 ON uapp_vprd_guid = prd_id 
               JOIN publisher 
                 ON pub_guid = prd_pub_guid 
               LEFT JOIN release 
                      ON uapp_vprl_guid = prl_id 
        WHERE  pub_name = 'Adobe Systems Incorporated' 
               AND prd_product = 'Adobe Acrobat DC' 
               AND prd_edition = 'Professional') t   
			   --AND uapp_release
			   order by RawRelease 
	   
select *
from application
where uapp_guid = '6228AF2F-7734-E711-8123-005056837D05' --from above query (that came from AC diag tool).

Select smio_MachineName
from InstallationBase
Join SiteMachineInfo on installationbase.MachineId = SiteMachineInfo.smio_id
where ProductId = 32618 --uapp_vprd_guid
AND ReleaseId = 109744 --uapp_vprl_guid (from above query).