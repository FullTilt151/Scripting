SELECT        SYS.Netbios_Name0, OS.Caption0, IPSUB.IP_Subnets0
FROM            dbo.v_R_System AS SYS INNER JOIN
                         dbo.v_GS_OPERATING_SYSTEM AS OS ON SYS.ResourceID = OS.ResourceID INNER JOIN
                         dbo.v_RA_System_IPSubnets AS IPSUB ON SYS.ResourceID = IPSUB.ResourceID INNER JOIN
                         dbo.v_GS_INSTALLED_SOFTWARE AS SOFT ON SOFT.ResourceID = SYS.ResourceID
WHERE        (IPSUB.IP_Subnets0 = '193.81.112.0') AND (SYS.Client0 = '1') AND (SOFT.ARPDisplayName0 = '1E PXE Lite Local') AND (SYS.ResourceID NOT IN
                             (SELECT        ResourceID
                               FROM            dbo.v_R_System AS SYS
                               WHERE        (Netbios_Name0 LIKE '%PXE%')))
ORDER BY IPSUB.IP_Subnets0
