select sys.Netbios_Name0, Name0, Description0, GracePeriodRemaining0, LicenseStatus0, PartialProductKey0
from v_R_System_Valid sys join 
	 v_GS_SOFTWARE_LICENSING_PRODUCT slp on sys.ResourceID = slp.ResourceID
where Operating_System_Name_and0 in ('Microsoft Windows NT Workstation 10.0','Microsoft Windows NT Workstation 10.0 (Tablet Edition)') and 
PartialProductKey0 is not null 
and LicenseStatus0 != 1
order by Netbios_Name0

/*
0 {"Unlicensed"}
1 {"Licensed"}
2 {"Out-of-Box Grace Period"}
3 {"Out-of-Tolerance Grace Period"}
4 {"Non-Genuine Grace Period"}
5 {"Notification"}
6 {"ExtendedGrace"}
*/