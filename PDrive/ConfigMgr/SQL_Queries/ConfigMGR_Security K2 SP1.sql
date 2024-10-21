USE master
GO

IF NOT EXISTS (
		SELECT *
		FROM sys.server_principals
		WHERE NAME = N'RSC\K2SRVACT_Prod'
		)
	CREATE LOGIN [RSC\K2SRVACT_Prod]
	FROM windows WITH default_database = [CM_SP1],
		default_language = [us_english]
GO

IF NOT EXISTS (
		SELECT *
		FROM sys.server_principals
		WHERE NAME = N'RSC\K2SRVACT_QA'
		)
	CREATE LOGIN [RSC\K2SRVACT_QA]
	FROM windows WITH default_database = [CM_SP1],
		default_language = [us_english]
GO

USE CM_SP1
GO

IF NOT EXISTS (
		SELECT *
		FROM sys.database_principals
		WHERE NAME = N'RSC\K2SRVACT_QA'
		)
	CREATE USER [RSC\K2SRVACT_QA]
	FOR LOGIN [RSC\K2SRVACT_QA]
	WITH default_schema = [dbo]
GO

IF NOT EXISTS (
		SELECT *
		FROM sys.database_principals
		WHERE NAME = N'RSC\K2SRVACT_Prod'
		)
	CREATE USER [RSC\K2SRVACT_Prod]
	FOR LOGIN [RSC\K2SRVACT_Prod]
	WITH default_schema = [dbo]
GO

GRANT SELECT
	ON vsms_folders
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON vsms_folders
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON vfoldermembers
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON vfoldermembers
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_softwareproduct
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_softwareproduct
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_softwarefile
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_softwarefile
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_program
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_program
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_productfileinfo
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_productfileinfo
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_package
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_package
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_gs_unknownfile
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_gs_unknownfile
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_gs_softwareproduct
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_gs_softwareproduct
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_gs_softwarefile
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_gs_softwarefile
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_gs_installed_software_categorized
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_gs_installed_software_categorized
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_gs_installed_software
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_gs_installed_software
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_gs_installed_executable
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_gs_installed_executable
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_collections
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_collections
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_collectionrulequery
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_collectionrulequery
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_collectionruledirect
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_collectionruledirect
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_r_system
	TO [RSC\K2SRVACT_Prod]
GO

GRANT SELECT
	ON v_r_system
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON vdeploymentsummary
	TO [RSC\K2SRVACT_PROD]
GO

GRANT SELECT
	ON vdeploymentsummary
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_advertisement
	TO [RSC\K2SRVACT_PROD]
GO

GRANT SELECT
	ON v_advertisement
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_advertisementinfo
	TO [RSC\K2SRVACT_PROD]
GO

GRANT SELECT
	ON v_advertisementinfo
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_appdeploymentsummary
	TO [RSC\K2SRVACT_PROD]
GO

GRANT SELECT
	ON v_appdeploymentsummary
	TO [RSC\K2SRVACT_QA]
GO

GRANT SELECT
	ON v_applicationassignment
	TO [RSC\K2SRVACT_PROD]
GO

GRANT SELECT
	ON v_applicationassignment
	TO [RSC\K2SRVACT_QA]
GO


