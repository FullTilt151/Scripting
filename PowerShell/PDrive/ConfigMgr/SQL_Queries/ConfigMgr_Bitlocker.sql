/*
EncryptionMethod0
https://docs.microsoft.com/en-us/windows/win32/secprov/getencryptionmethod-win32-encryptablevolume
0 Not encrypted
1 AES_128_WITH_DIFFUSER
2 AES_256_WITH_DIFFUSER
3 AES_128
4 AES_256
5 Hardware
6 XTS_AES128
7 XTS_AES256

ProtectionStatus0
0 = Not protected
1 = Protected
2 = Protection unknown

OSDriveProtector0
1 TPM
4 TPM and PIN

ConversionStatus
https://docs.microsoft.com/en-us/windows/win32/secprov/getconversionstatus-win32-encryptablevolume
0 Fully decrypted
1 Fully encrypted
2 Encryption in progress
3 Decryption in progress
4 Encryption paused
5 Decryption paused

Keyprotectortypes
https://docs.microsoft.com/en-us/windows/win32/secprov/getkeyprotectortype-win32-encryptablevolume
0 = 'Unknown or other protector type'
1 = 'Trusted Platform Module (TPM)'
2 = 'External key'
3 = 'Numerical password'
4 = 'TPM And PIN'
5 = 'TPM And Startup Key'
6 = 'TPM And PIN And Startup Key'
7 = 'Public Key'
8 = 'Passphrase'
9 = 'TPM Certificate'
10 = 'CryptoAPI Next Generation (CNG) Protector'

Reasons for non-compliance
https://docs.microsoft.com/en-us/microsoft-desktop-optimization-pack/mbam-v25/determining-why-a-device-receives-a-noncompliance-message
0 Cipher strength not AES 256.
1 MBAM Policy requires this volume to be encrypted but it is not.
2 MBAM Policy requires this volume to NOT be encrypted, but it is.
3 MBAM Policy requires this volume use a TPM protector, but it does not.
4 MBAM Policy requires this volume use a TPM+PIN protector, but it does not.
5 MBAM Policy does not allow non TPM machines to report as compliant.
6 Volume has a TPM protector but the TPM is not visible (booted with recover key after disabling TPM in BIOS?).
7 MBAM Policy requires this volume use a password protector, but it does not have one.
8 MBAM Policy requires this volume NOT use a password protector, but it has one.
9 MBAM Policy requires this volume use an auto-unlock protector, but it does not have one.
10 MBAM Policy requires this volume NOT use an auto-unlock protector, but it has one.
11 Policy conflict detected preventing MBAM from reporting this volume as compliant.
12 A system volume is needed to encrypt the OS volume but it is not present.
13 Protection is suspended for the volume.
14 AutoUnlock unsafe unless the OS volume is encrypted.
15 Policy requires minimum cypher strength is XTS-AES-128 bit, actual cypher strength is weaker than that.
16 Policy requires minimum cypher strength is XTS-AES-256 bit, actual cypher strength is weaker than that.
*/

-- List of all Bitlocker machines
select sys.Netbios_Name0 [WKID], sys.Resource_Domain_OR_Workgr0 [Domain], cdr.PrimaryUser, cdr.CurrentLogonUser, usr.Full_User_Name0, usr.department0,
	   MBAMMachineError0, MBAMPolicyEnforced0, OsDriveEncryption0, 
	   case OsDriveProtector0
	   when 1 then 'TPM'
	   when 4 then 'TPM and PIN'
	   end [OS Drive Protector], 
	   case ConversionStatus0
	   when 0 then 'Decrypted'
	   when 1 then 'Encrypted'
	   when 2 then 'Encryption in progress'
	   when 3 then 'Decryption in progress'
	   when 4 then 'Encryption paused'
	   when 5 then 'Decryption paused'
	   end [Conversion Status], 
	   case bl.EncryptionMethod0 
	   when 0 then 'Not encrypted'
	   when 1 then 'AES128 w/Diffuser'
	   when 2 then 'AES256 w/Diffuser'
	   when 3 then 'AES128'
	   when 4 then 'AES256'
	   when 5 then 'Hardware'
	   when 6 then 'XTS AES128'
	   when 7 then 'XTS AES256'
	   end [OS drive encryption method], IsAutoUnlockEnabled0 [Network unlock enabled], KeyProtectorTypes0, 
	   case ProtectionStatus0
	   when 0 then 'Not protected'
	   when 1 then 'Protected'
	   when 2 then 'Unknown'
	   end [ProtectionStatus], 
	   case bl.compliant0 
	   when 0 then 'No'
	   when 1 then 'Yes'
	   when 2 then 'Unknown'
	   end [Compliant], ReasonsForNonCompliance0, 
	   cdr.LastActiveTime, cdr.CNLastOnlineTime, os.InstallDate0
from v_R_System_valid sys left join
	 v_GS_MBAM_POLICY mbam on sys.ResourceID = mbam.ResourceID left join
	 v_GS_BITLOCKER_DETAILS bl on sys.ResourceID = bl.ResourceID left join
	 v_CombinedDeviceResources cdr on sys.ResourceID = cdr.MachineID left join
	 v_R_User usr on REPLACE(cdr.CurrentLogonUser,'HUMAD\','') = usr.User_Name0 left join
	 v_GS_OPERATING_SYSTEM os on sys.ResourceID = os.ResourceID
where bl.EncryptionMethod0 is not null and Resource_Domain_OR_Workgr0 = 'HUMAD' 
	  --and compliant0 != 1
	  and ProtectionStatus0 != 1
	  --Netbios_Name0 = 'WKPC0KUM0N'
order by domain, WKID

-- Count of noncompliant WKIDs
select sys.Resource_Domain_OR_Workgr0 [Domain],compliant0,  count(*)
from v_R_System_valid sys inner join
	 v_GS_MBAM_POLICY mbam on sys.ResourceID = mbam.ResourceID left join
	 v_GS_BITLOCKER_DETAILS bl on sys.ResourceID = bl.ResourceID
where bl.EncryptionMethod0 is not null and Resource_Domain_OR_Workgr0 = 'HUMAD'
group by sys.Resource_Domain_OR_Workgr0, compliant0
order by domain

select * from v_GS_MBAM_POLICY where EncryptionMethod0 is not null
select count(*) from v_GS_MBAM_POLICY
select count(*) from v_GS_BITLOCKER_DETAILS

-- Bitlocker details for a WKID
select *
from v_GS_BITLOCKER_DETAILS
where resourceid in (select resourceid from v_r_system where netbios_name0 = 'WKMJ08NVVW')

-- Encrypted volumes
select * from v_GS_ENCRYPTABLE_VOLUME where ProtectionStatus0 != 0

-- Recovery keys
select * from  RecoveryAndHardwareCore_Keys
select * from  RecoveryAndHardwareCore_Machine_Types
select * from  RecoveryAndHardwareCore_Machines_Users
select * from  RecoveryAndHardwareCore_Machines_Volumes

-- TPM data
select resourceid, PhysicalPresenceVersionInfo0, IsActivated_InitialValue0, IsEnabled_InitialValue0, IsOwned_InitialValue0
from v_GS_TPM

select resourceid, Information0, IsApplicable0, IsReady0
from v_GS_TPM_STATUS

-- Secure boot
select sys.Netbios_Name0, UEFISecureBootEnabled0, len.CurrentSetting0
from v_R_System sys left join
	 v_GS_Secure_Boot_State0 sb on sys.ResourceID = sb.ResourceID left join
	 v_GS_LENOVO_BIOSSETTING len on sys.ResourceID = len.ResourceID and len.CurrentSetting0 like 'secure%boot%'
--where sys.resourceid in (select resourceid from v_cm_res_coll_WP106739) and sys.Is_Virtual_Machine0 = 0 and (UEFISecureBootEnabled0 is null or UEFISecureBootEnabled0 != 1) and
where Netbios_Name0 = 'WKPC169RDG'
order by sys.Netbios_Name0

-- Non-compliant SecureBoot
select sys.Netbios_Name0, scum.TopConsoleUser0, usr.Full_User_Name0, usr.Mail0, usr.title0, usr.department0, csp.Version0, bios.SMBIOSBIOSVersion0, bios.ReleaseDate0, sb.UEFISecureBootEnabled0, lbs.CurrentSetting0, PhysicalPresenceVersionInfo0, SpecVersion0,
	   (select top 1 ProductVersion0 from v_GS_INSTALLED_SOFTWARE sft where sft.resourceid = sys.resourceid and sft.ProductName0 like 'Securedoc disk encryption%') [WM version]
from v_r_system sys left join
	 v_GS_SYSTEM_CONSOLE_USAGE_MAXGROUP SCUM on sys.ResourceID = scum.ResourceID left join
	 v_R_User usr on SUBSTRING(scum.TopConsoleUser0, CHARINDEX('\', scum.TopConsoleUser0)+1, 8) = usr.user_name0 left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID left join
	 v_GS_PC_BIOS bios on sys.ResourceID = bios.ResourceID left join
	 v_GS_Secure_Boot_State0 sb on sys.ResourceID = sb.ResourceID left join
	 v_GS_LENOVO_BIOSSETTING lbs on sys.ResourceID = lbs.ResourceID left join
	 v_GS_TPM tpm on sys.ResourceID = tpm.ResourceID
where uefisecurebootenabled0 = 0 and CurrentSetting0 like 'Secure%boot%' and sys.Resource_Domain_OR_Workgr0 = 'HUMAD'
order by CurrentSetting0

-- SecureBoot counts
select UEFISecureBootEnabled0, count(*)
from v_gs_Secure_Boot_State0
group by UEFISecureBootEnabled0

-- TPM settings
select CurrentSetting0, Version0, count(*)
from v_gs_lenovo_biossetting bios join
	 v_GS_COMPUTER_SYSTEM_PRODUCT cs on bios.ResourceID = cs.ResourceID
where CurrentSetting0 like 'TCG%' or CurrentSetting0 like 'SecurityChip%'
group by CurrentSetting0, Version0
order by CurrentSetting0, Version0

-- TPM version counts
select PhysicalPresenceVersionInfo0, Specversion0, uefi.UEFISecureBootEnabled0, count(*)
from v_GS_TPM tpm inner join
	 v_GS_UEFI_SecureBootState0 uefi on tpm.ResourceID = uefi.ResourceID
group by PhysicalPresenceVersionInfo0, SpecVersion0, uefi.UEFISecureBootEnabled0
order by UEFISecureBootEnabled0, PhysicalPresenceVersionInfo0, SpecVersion0

-- Windows 10 with Legacy BIOS
select sys.Netbios_Name0, bios.CurrentSetting0
from v_R_System sys left join
	 v_GS_LENOVO_BIOSSETTING bios on sys.ResourceID = bios.ResourceID
where CurrentSetting0 in ('CSM,Enabled;[Optional:Disabled,Enabled]','Boot Mode,Legacy Only;[Optional:Auto,Legacy Only,UEFI Only][Status:ShowOnly]') and sys.Resource_Domain_OR_Workgr0 = 'HUMAD' and Operating_System_Name_and0 like 'Microsoft Windows NT Workstation 10.0%'
order by Netbios_Name0

-- TPM Counts
select IsActivated_InitialValue0, IsEnabled_InitialValue0, IsOwned_InitialValue0, count(*)
from v_GS_TPM
group by IsActivated_InitialValue0, IsEnabled_InitialValue0, IsOwned_InitialValue0
order by IsActivated_InitialValue0, IsEnabled_InitialValue0, IsOwned_InitialValue0

-- TPM status counts
select IsReady0, count(*)
from v_GS_TPM_STATUS
group by IsReady0

-- TPM settings - Lenovo
select sys.Netbios_Name0 [WKID], csp.Version0 [Model], IsReady0 [TPM],
	(select CurrentSetting0 from v_GS_LENOVO_BIOSSETTING bios
	where CurrentSetting0 in (
	'Security Chip 1.2,Inactive;[Optional:Disabled,Active,Inactive]',
	'Security Chip 2.0,Disabled;[Optional:Disabled,Enabled]',
	'Security Chip,Disabled;[Optional:Disabled,Enabled]',
	'Security Chip,Disabled;[Optional:Enabled,Disabled]',
	'Security Chip,Inactive;[Optional:Disabled,Active,Inactive]',
	'SecurityChip,Disable',
	'SecurityChip,Inactive',
	'TCG Security Feature,Disabled;[Optional:Disabled,Active,Inactive]',
	'TCG Security Feature,Inactive',
	'TCG Security Feature,Inactive;[Optional:Disabled,Active,Inactive]')
	and bios.ResourceID = sys.resourceid)
from v_R_System sys left join
	 v_GS_TPM_STATUS tpm on sys.ResourceID = tpm.ResourceID left join
	 v_GS_COMPUTER_SYSTEM_PRODUCT csp on sys.ResourceID = csp.ResourceID
where IsReady0 = 0 and Is_Virtual_Machine0 = 0 and Resource_Domain_OR_Workgr0 = 'HUMAD' 
	 and Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)')
order by Netbios_Name0