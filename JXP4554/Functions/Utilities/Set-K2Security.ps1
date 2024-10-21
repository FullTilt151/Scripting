Function Set-K2Security {
    <#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER SCCMConnectionInfo
		This is a connection object used to know how to connect to the site. The best way to get this is storing the results of
		Get-CMNSCCMConnectionInfo in a variable and passing that variable.

 	.PARAMETER logFile
		File for writing logs to

	.PARAMETER logEntries
		Switch to say whether or not to create a log file

	.PARAMETER maxLogSize
		Max size for the log. Defaults to 5MB.

	.PARAMETER maxHistory
			Specifies the number of history log files to keep, default is 5

 	.EXAMPLE

	.LINK
		http://configman-notes.com

	.NOTES
		Author:      James Parris
		Contact:     Jim@ConfigMan-Notes.com
		Created:     
		Updated:     
		Version:     1.0.0
	#>

    [CmdletBinding(SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]

    PARAM(
        [Parameter(Mandatory = $false,
            HelpMessage = 'LogFile Name')]
        [String]$logFile = 'C:\Temp\Error.log',

        [Parameter(Mandatory = $false,
            HelpMessage = 'Log entries')]
        [Switch]$logEntries,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max Log size')]
        [Int32]$maxLogSize = 5242880,

        [Parameter(Mandatory = $false,
            HelpMessage = 'Max number of history logs')]
        [Int32]$maxHistory = 5
    )

    Begin {
        # Disable Fast parameter usage check for Lazy properties
        $CMPSSuppressFastNotUsedCheck = $true
        #Build splat for log entries
        $NewLogEntry = @{
            LogFile    = $logFile;
            Component  = 'Set-K2Security';
            maxLogSize = $maxLogSize;
            maxHistory = $maxHistory;
        }

        $sites = ('SP1','SQ1','WP1','WQ1','MT1')

        $SQLConnectionStringHashTable = @{
            SP1 = 'Data Source=LOUSQLWPS618;Integrated Security=SSPI;Initial Catalog=CM_SP1';
            SQ1 = 'Data Source=LOUSQLWQS534;Integrated Security=SSPI;Initial Catalog=CM_SQ1';
            WP1 = 'Data Source=LOUSQLWPS606;Integrated Security=SSPI;Initial Catalog=CM_WP1';
            WQ1 = 'Data Source=LOUSQLWQS535;Integrated Security=SSPI;Initial Catalog=CM_WQ1';
            MT1 = 'Data Source=LOUSQLWTS553;Integrated Security=SSPI;Initial Catalog=CM_MT1';
        }

        $SQLQueryHashTable = @{
            SP1 = "USE master 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Prod') 
              CREATE login [RSC\K2SRVACT_Prod] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE login [RSC\K2SRVACT_QA] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE login [RSC\K2SRVACT_Test] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE login [RSC\K2SRVACT] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            USE CM_SQ1 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE USER [RSC\K2SRVACT_QA] FOR login [RSC\K2SRVACT_QA] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Prod') 
              CREATE USER [RSC\K2SRVACT_Prod] FOR login [RSC\K2SRVACT_Prod] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE USER [RSC\K2SRVACT_Test] FOR login [RSC\K2SRVACT_Test] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE USER [RSC\K2SRVACT] FOR login [RSC\K2SRVACT] WITH default_schema=[dbo] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_QA] 
            
           *
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT] 
            
           *";
            SQ1 = "USE master 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Prod') 
              CREATE login [RSC\K2SRVACT_Prod] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE login [RSC\K2SRVACT_QA] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE login [RSC\K2SRVACT_Test] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE login [RSC\K2SRVACT] FROM windows WITH default_database=[CM_SQ1], 
              default_language=[us_english] 
           * 
            
            USE CM_SQ1 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE USER [RSC\K2SRVACT_QA] FOR login [RSC\K2SRVACT_QA] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Prod') 
              CREATE USER [RSC\K2SRVACT_Prod] FOR login [RSC\K2SRVACT_Prod] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE USER [RSC\K2SRVACT_Test] FOR login [RSC\K2SRVACT_Test] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE USER [RSC\K2SRVACT] FOR login [RSC\K2SRVACT] WITH default_schema=[dbo] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_QA] 
            
           *
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT] 
            
           *";
            WP1 = "USE master 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE login [RSC\K2SRVACT_QA] FROM windows WITH default_database=[CM_WP1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_PROD') 
              CREATE login [RSC\K2SRVACT_PROD] FROM windows WITH default_database=[CM_WP1], 
              default_language=[us_english] 
           * 
            
            USE CM_WP1 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_PROD') 
              CREATE USER [RSC\K2SRVACT_PROD] FOR login [RSC\K2SRVACT_PROD] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE USER [RSC\K2SRVACT_QA] FOR login [RSC\K2SRVACT_QA] WITH default_schema=[dbo] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_PROD] 
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_QA] 
            
           *";
            WQ1 = "USE master 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Prod') 
              CREATE login [RSC\K2SRVACT_Prod] FROM windows WITH default_database=[CM_WQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE login [RSC\K2SRVACT_QA] FROM windows WITH default_database=[CM_WQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE login [RSC\K2SRVACT_Test] FROM windows WITH default_database=[CM_WQ1], 
              default_language=[us_english] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE login [RSC\K2SRVACT] FROM windows WITH default_database=[CM_WQ1], 
              default_language=[us_english] 
           * 
            
            USE CM_WQ1 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_QA') 
              CREATE USER [RSC\K2SRVACT_QA] FOR login [RSC\K2SRVACT_QA] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Prod') 
              CREATE USER [RSC\K2SRVACT_Prod] FOR login [RSC\K2SRVACT_Prod] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE USER [RSC\K2SRVACT_Test] FOR login [RSC\K2SRVACT_Test] WITH default_schema=[dbo] 
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE USER [RSC\K2SRVACT] FOR login [RSC\K2SRVACT] WITH default_schema=[dbo] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_Prod] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_QA] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_Test] 
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT] 
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_QA] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Prod] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_QA] 
            
           *
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT] 
            
           *";
            MT1 = "USE master 

           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE login [RSC\K2SRVACT_Test] FROM windows WITH default_database=[CM_MT1], 
              default_language=[us_english] 
            
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.server_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE login [RSC\K2SRVACT] FROM windows WITH default_database=[CM_MT1], 
              default_language=[us_english] 
            
           * 
            
            USE cm_mt1 
            
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT') 
              CREATE USER [RSC\K2SRVACT] FOR login [RSC\K2SRVACT] WITH default_schema=[dbo] 
            
           * 
            
            IF NOT EXISTS (SELECT * 
                           FROM   sys.database_principals 
                           WHERE  NAME = N'RSC\K2SRVACT_Test') 
              CREATE USER [RSC\K2SRVACT_Test] FOR login [RSC\K2SRVACT_Test] WITH 
              default_schema=[dbo] 
            
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON vsms_folders TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON vfoldermembers TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_softwareproduct TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_softwarefile TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_program TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_productfileinfo TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_package TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_gs_unknownfile TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_gs_softwareproduct TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_gs_softwarefile TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_gs_installed_software_categorized TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_gs_installed_software TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_gs_installed_executable TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_collections TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_collectionrulequery TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_collectionruledirect TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_r_system TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON vdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisement TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_advertisementinfo TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_appdeploymentsummary TO [RSC\K2SRVACT] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT_Test] 
            
           * 
            
            GRANT SELECT ON v_applicationassignment TO [RSC\K2SRVACT] 
            
           *";
        }
        if ($PSBoundParameters['logEntries']) {
            New-CMNLogEntry -entry 'Starting Function' -type 1 @NewLogEntry
            New-CMNLogEntry -entry "SCCMConnectionInfo = $SCCMConnectionInfo" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logFile = $logFile" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "logEntries = $logEntries" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxLogSize = $maxLogSize" -type 1 @NewLogEntry
            New-CMNLogEntry -entry "maxHistory = $maxHistory" -type 1 @NewLogEntry
        }
    }

    Process {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Beginning processing loop' -type 1 @NewLogEntry}
        # Main code part*es here
        foreach($site in $sites){
            if ($PSBoundParameters['logEntries']){New-CMNLogEntry -entry "Updating security for site $site" -type 1 @NewLogEntry}
            Invoke-CMNDatabaseQuery -connectionString $SQLConnectionStringHashTable[$site] -query $SQLQueryHashTable[$site] -isSQLServer
        }
    }

    End {
        if ($PSBoundParameters['logEntries']) {New-CMNLogEntry -entry 'Completing Function' -Type 1 @NewLogEntry}
    }
} #End Set-K2Security
Set-K2Security