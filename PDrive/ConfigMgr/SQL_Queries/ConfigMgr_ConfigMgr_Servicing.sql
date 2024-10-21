SELECT *
FROM CM_UpdatePackages
--where Flag IS NOT NULL
order by FullVersion desc

select * from v_package where PackageID = 'WP100007' 
select * from EasySetupSettings
select * from cm_updatepackageSiteStatus order by PackageGuid
select * from CM_UpdatePackageSiteStatus_HIST order by PackageGuid
select * from CM_UpdatePackage_MonitoringStatus order by MessageTime desc

-- update CM_Updatepackages set state = 196607 where PackageGUID = 'C0AD6B1A-D64A-497E-AE9D-D12C7A75C1EB' 



/*
--If Update is missing or content will not download
1. Restart SMS_EXECUTIVE twice
2. If doesn't work, delete all rows for that full version

DELETE FROM dbo.CM_UpdatePackages
where FullVersion = '5.00.8740.1033'
--where PackageGuid = 'AF633310-E419-44B3-9E0E-AB93D57087CF'

3. Change HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\SMS\COMPONENTS\SMS_DMP_DOWNLOADER\EasySetupDownloadInterval to a different value
4. Restart CMUpdate service
5. Update missing? Force it to show.

update CM_UpdatePackages set state = '262146', flag=NULL where PackageGuid='454B3508-4387-4106-9441-283495DEC3EC' -- This status is ready to install
update CM_UpdatePackages set state = '196607', flag=NULL where PackageGuid='454B3508-4387-4106-9441-283495DEC3EC' -- This status is Failed PreReq check
*/

/*
# The update package installation is initiated
 INSTALLING = 2

 # downloading update pack is in progress
 DOWNLOAD_IN_PROGRESS = 262145

 # The update package is not installed yet
 DOWNLOAD_SUCCESS = 262146

 # Update pack download failed
 DOWNLOAD_FAILED = 327679

 # Checking applicability
 APPLICABILITY_CHECKING = 327681

 # Applicability succeeded
 APPLICABILITY_SUCCESS = 327682

 # Not applicable
 APPLICABILITY_NA = 393214

 # Applicability checking failed
 APPLICABILITY_FAILED = 393215

 # Content is replicating
 CONTENT_REPLICATING = 65537

 # Content replication succeeded
 CONTENT_REPLICATION_SUCCESS = 65538

 # Content replication failed
 CONTENT_REPLICATION_FAILED = 131071

 # Prerequisite check in progress
 PREREQ_IN_PROGRESS = 131073

 # Prereq check succeeded
 PREREQ_SUCCESS = 131074

 # Prereq check completed with warning
 PREREQ_WARNING = 131075

 # Prereq check failed
 PREREQ_ERROR = 196607

 # Installation in progress
 INSTALL_IN_PROGRESS = 196609

 # Installation is scheduled
 INSTALL_WAITING_SERVICE_WINDOW = 196610

 # Installation is waiting for parent installation
 INSTALL_WAITING_PARENT = 196611

 # Update package is installed
 INSTALL_SUCCESS = 196612

 # Installation is pending reboot
 INSTALL_PENDING_REBOOT = 196613

 # Installation failed
 INSTALL_FAILED = 262143

 # Validating Configuration Manager Service
 INSTALL_CMU_VALIDATING = 196614

 # Stopped CONFIGURATION_MANAGER_SERVICE
 INSTALL_CMU_STOPPED = 196615

 # Install files for CONFIGURATION_MANAGER_SERVICE
 INSTALL_CMU_INSTALLFILES = 196616

 # Started CONFIGURATION_MANAGER_SERVICE
 INSTALL_CMU_STARTED = 196617

 # CONFIGURATION_MANAGER_SERVICE installation success
 INSTALL_CMU_SUCCESS = 196618

 # INSTALL_WAITING_CMU = 196619

 # CONFIGURATION_MANAGER_SERVICE installation failed
 INSTALL_CMU_FAILED = 262142

 # Install Files
 INSTALL_INSTALLFILES = 196620

 # Upgrade site control configuration
 INSTALL_UPGRADESITECTRLIMAGE = 196621

 # Configure SSB
 INSTALL_CONFIGURESERVICEBROKER = 196622

 # Install System
 INSTALL_INSTALLSYSTEM = 196623

 # CONFIGURATION_MANAGER_SERVICE installation success
 INSTALL_CONSOLE = 196624

 # Install SMS_SITE_COMPONENT_MANAGER service
 INSTALL_INSTALLBASESERVICES = 196625

 # Update Sites table
 INSTALL_UPDATE_SITES = 196626

 # Turn SSB Activation
 INSTALL_SSB_ACTIVATION_ON = 196627

 # Upgrade database
 INSTALL_UPGRADEDATABASE = 196628

 # CM Admins want to run prereq check only
 PREREQ_ONLY = 1

 # CM Admins want to continue Setup even if there are prereq rules that report WARNING
 CONTINUE_ON_PREREQ_WARNING = 2

 # CM Admins DO NOT want to continue Setup even when there are prereq rules that report WARNING
 NOT_CONTINUE_ON_PREREQ_WARNING = 0

 # Flag column..
 0 - 
 1 - 
 2 - 
*/

