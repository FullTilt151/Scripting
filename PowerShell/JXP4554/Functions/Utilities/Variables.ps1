$FeatureTypes = @("Unknown", "Application", "Program", "Invalid", "Invalid", "Software Update", "Invalid", "Task Sequence")

$OfferTypes = @("Required", "Not Used", "Available")

$FastDPOptions = @('RunProgramFromDistributionPoint', 'DownloadContentFromDistributionPointAndRunLocally')

$ObjectIDtoObjectType = @{
    2 = 'SMS_Package';
    3 = 'SMS_Advertisement';
    7 = 'SMS_Query';
    8 = 'SMS_Report';
    9 = 'SMS_MeteredProductRule';
    11 = 'SMS_ConfigurationItem';
    14 = 'SMS_OperatingSystemInstallPackage';
    17 = 'SMS_StateMigration';
    18 = 'SMS_ImagePackage';
    19 = 'SMS_BootImagePackage';
    20 = 'SMS_TaskSequencePackage';
    21 = 'SMS_DeviceSettingPackage';
    23 = 'SMS_DriverPackage';
    25 = 'SMS_Driver';
    1011 = 'SMS_SoftwareUpdate';
    2011 = 'SMS_ConfigurationBaselineInfo';
    5000 = 'SMS_Collection_Device';
    5001 = 'SMS_Collection_User';
    6000 = 'SMS_ApplicationLatest';
    6001 = 'SMS_ConfigurationItemLatest';
}

$ObjectTypetoObjectID = @{
    'SMS_Package' = 2;
    'SMS_Advertisement' = 3;
    'SMS_Query' = 7;
    'SMS_Report' = 8;
    'SMS_MeteredProductRule' = 9;
    'SMS_ConfigurationItem' = 11;
    'SMS_OperatingSystemInstallPackage' = 14;
    'SMS_StateMigration' = 17;
    'SMS_ImagePackage' = 18;
    'SMS_BootImagePackage' = 19;
    'SMS_TaskSequencePackage' = 20;
    'SMS_DeviceSettingPackage' = 21;
    'SMS_DriverPackage' = 23;
    'SMS_Driver' = 25;
    'SMS_SoftwareUpdate' = 1011;
    'SMS_ConfigurationBaselineInfo' = 2011;
    'SMS_Collection_Device' = 5000;
    'SMS_Collection_User' = 5001;
    'SMS_ApplicationLatest' = 6000;
    'SMS_ConfigurationItemLatest' = 6001;
}

$RerunBehaviors = @{
    RERUN_ALWAYS = 'AlwaysRerunProgram';
    RERUN_NEVER = 'NeverRerunDeployedProgra';
    RERUN_IF_FAILED = 'RerunIfFailedPreviousAttempt';
    RERUN_IF_SUCCEEDED = 'RerunIfSucceededOnpreviousAttempt';
}

$SlowDPOptions = @('DoNotRunProgram', 'DownloadContentFromDistributionPointAndLocally', 'RunProgramFromDistributionPoint')

$SMS_Advertisement_AdvertFlags = @{
    IMMEDIATE = "0x00000020";
    ONSYSTEMSTARTUP = "0x00000100";
    ONUSERLOGON = "0x00000200";
    ONUSERLOGOFF = "0x00000400";
    WINDOWS_CE = "0x00008000";
    ENABLE_PEER_CACHING = "0x00010000";
    DONOT_FALLBACK = "0x00020000";
    ENABLE_TS_FROM_CD_AND_PXE = "0x00040000";
    OVERRIDE_SERVICE_WINDOWS = "0x00100000";
    REBOOT_OUTSIDE_OF_SERVICE_WINDOWS = "0x00200000";
    WAKE_ON_LAN_ENABLED = "0x00400000";
    SHOW_PROGRESS = "0x00800000";
    NO_DISPLAY = "0x02000000";
    ONSLOWNET = "0x04000000";
}

$SMS_Advertisement_DeviceFlags = @{
    AlwaysAssignProgramToTheClient = "0x01000000";
    OnlyIfDeviceHighBandwidth = "0x02000000";
    AssignIfDocked = "0x04000000";
}

$SMS_Advertisement_ProgramFlags = @{
    DYNAMIC_INSTALL = "0x00000001";
    TS_SHOW_PROGRESS = "0x00000002";
    DEFAULT_PROGRAM = "0x0000001";
    DISABLE_MOM_ALERTS = "0x00000020";
    GENERATE_MOM_ALERT_IF_FAIL = "0x00000040";
    ADVANCED_CLIENT = "0x00000080";
    DEVICE_PROGRAM = "0x00000100";
    RUN_DEPENDENT = "0x00000200";
    NO_COUNTDOWN_DIALOG = "0x00000400";
    RESTART_ADR = "0x00000800";
    PROGRAM_DISABLED = "0x00001000";
    NO_USER_INTERACTION = "0x00002000";
    RUN_IN_USER_CONTEXT = "0x00004000";
    RUN_AS_ADMINISTRATOR = "0x00008000";
    RUN_FOR_EVERY_USER = "0x00010000";
    NO_USER_LOGGED_ON = "0x00020000";
    EXIT_FOR_RESTART = "0x00080000";
    USE_UNC_PATH = "0x00100000";
    PERSIST_CONNECTION = "0x00200000";
    RUN_MINIMIZED = "0x00400000";
    RUN_MAXIMIZED = "0x00800000";
    RUN_HIDDEN = "0x01000000";
    LOGOFF_WHEN_COMPLETE = "0x02000000"
    ADMIN_ACCOUNT_DEFINED = "0x04000000";
    OVERRIDE_PLATFORM_CHECK = "0x08000000";
    UNINSTALL_WHEN_EXPIRED = "0x20000000";
    PLATFORM_NOT_SUPPORTED = "0x40000000"
    DISPLAY_IN_ADR = "0x80000000";
}

$SMS_Advertisement_RemoteClientFlags = @{
    BATTERY_POWER = "0x00000001";
    RUN_FROM_CD	= "0x00000002";
    DOWNLOAD_FROM_CD = "0x00000004";
    RUN_FROM_LOCAL_DISPPOINT = "0x00000008";
    DOWNLOAD_FROM_LOCAL_DISPPOINT = "0x00000010";
    DONT_RUN_NO_LOCAL_DISPPOINT = "0x00000020";
    DOWNLOAD_FROM_REMOTE_DISPPOINT = "0x00000040";
    RUN_FROM_REMOTE_DISPPOINT = "0x00000080";
    DOWNLOAD_ON_DEMAND_FROM_LOCAL_DP = "0x00000100";
    DOWNLOAD_ON_DEMAND_FROM_REMOTE_DP = "0x00000200";
    BALLOON_REMINDERS_REQUIRED = "0x00000400";
    RERUN_ALWAYS = "0x00000800";
    RERUN_NEVER = "0x00001000";
    RERUN_IF_FAILED = "0x00002000";
    RERUN_IF_SUCCEEDED = "0x00004000";
    PERSIST_ON_WRITE_FILTER_DEVICES = "0x00008000";
    DONT_FALLBACK = "0x00020000";
    DP_ALLOW_METERED_NETWORK = "0x00040000";
}

$SMS_Advertisement_TimeFlags = @{
    ENABLE_PRESENT = '0x00000001';
    ENABLE_EXPIRATION = '0x00000002';
    ENABLE_AVAILABLE = '0x00000004';
    ENABLE_UNAVAILABLE = '0x00000008';
    ENABLE_MANDATORY = '0x00000010';
    GMT_PRESENT = '0x00000020';
    GMT_EXPIRATION = '0x00000040';
    GMT_AVAILABLE = '0x00000080';
    GMT_UNAVAILABLE = '0x00000100';
    GMT_MANDATORY = '0x00000200';
}

$SMS_Package_PkgFlags = @{
    COPY_CONTENT = '0x00000080';
    DO_NOT_DOWNLOAD = '0x01000000';
    PERSIST_IN_CACHE = '0x02000000';
    USE_BINARY_DELTA_REP = '0x04000000';
    NO_PACKAGE = '0x10000000';
    USE_SPECIAL_MIF = '0x20000000';
    DISTRIBUTE_ON_DEMAND = '0x40000000';
}

$SMS_Program_ProgramFlags = @{
    AUTHORIZED_DYNAMIC_INSTALL = '0x00000001';
    USECUSTOMPROGRESSMSG = '0x00000002';
    DEFAULT_PROGRAM = '0x00000010';
    DISABLEMOMALERTONRUNNING = '0x00000020';
    MOMALERTONFAIL = '0x00000040';
    RUN_DEPENDANT_ALWAYS = '0x00000080'
    WINDOWS_CE = '0x00000100';
    COUNTDOWN = '0x00000400';
    FORCERERUN = '0x00000800';
    DISABLED = '0x00001000';
    UNATTENDED = '0x00002000';
    USERCONTEXT = '0x00004000';
    ADMINRIGHTS = '0x00008000';
    EVERYUSER = '0x00010000';
    NOUSERLOGGEDIN = '0x00020000';
    OKTOQUIT = '0x00040000';
    OKTOREBOOT = '0x00080000';
    USEUNCPATH = '0x00100000';
    PERSISTCONNECTION = '0x00200000';
    RUNMINIMIZED = '0x00400000';
    RUNMAXIMIZED = '0x00800000';
    HIDEWINDOW = '0x01000000';
    OKTOLOGOFF = '0x02000000';
    RUNACCOUNT = '0x04000000';
    ANY_PLATFORM = '0x08000000';
    SUPPORT_UNINSTALL = '0x20000000';
}
