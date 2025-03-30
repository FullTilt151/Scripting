SELECT DISTINCT sys.netbios_name0                            [Name], 
                CASE 
                  WHEN netbios_name0 LIKE '%WP[SLCBGUVM]%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WQ[SLC]%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WA[GSL]%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WD[LGS]%' THEN 'Dev' 
                  WHEN netbios_name0 LIKE '%PDW%' THEN 'Dev' 
                  WHEN netbios_name0 LIKE '%WT[SCLGX]%' THEN 'Test' 
                  WHEN netbios_name0 LIKE '%WE[CLS]%' THEN 'Education' 
                  WHEN netbios_name0 LIKE '%WI[SL]%' THEN 'Intermediate' 
                  WHEN netbios_name0 LIKE '%WR[LSC]%' THEN 'Recovery' 
                  WHEN netbios_name0 LIKE '%WS[LCS]%' THEN 'Staging' 
                  ELSE 'Unknown' 
                END                                          [Environment], 
                sys.resource_domain_or_workgr0               [Domain], 
                os.caption0                                  [OS], 
                os.csdversion0                               [Service Pack], 
                sys.client_version0                          [Client Version], 
                net.ipaddress0                               [IP], 
                cs.manufacturer0                             [Mfg], 
                cs.model0                                    [Model], 
                csp.version0                                 [Model Number], 
                BIOS.SerialNumber0                           [Serial Number],
                cs.systemtype0                               [System], 
                bios.smbiosbiosversion0                      [BIOS], 
                cpu.name0                                    [CPU], 
                cpu.normspeed0                               [CPU Speed], 
                (SELECT Count(cpu1.deviceid0) 
                 FROM   v_gs_processor CPU1 
                 WHERE  sys.resourceid = cpu1.resourceid)    [CPU Count], 
                cpu.numberofcores0                           [CPU Core Count], 
                cpu.numberoflogicalprocessors0               [CPU Logical Count] 
                , 
                ( (SELECT Count(cpu1.deviceid0) 
                   FROM   v_gs_processor CPU1 
                   WHERE  sys.resourceid = cpu1.resourceid) * 
                  cpu.numberoflogicalprocessors0 ) 
                [Total CPU Logical Count], 
                cpu.ishyperthreadcapable0                    [HT Capable], 
                cpu.ishyperthreadenabled0                    [HT Enabled], 
                CS.TotalPhysicalMemory0                                                                                          [RAM],
                ch.lastactivetime                            [Last Active], 
                Datediff(day, os.lastbootuptime0, Getdate()) [Uptime in Days] 
FROM   v_r_system SYS 
       LEFT JOIN v_gs_operating_system OS 
              ON sys.resourceid = os.resourceid 
       LEFT JOIN v_gs_network_adapter_configuration NET 
              ON sys.resourceid = net.resourceid 
       LEFT JOIN v_gs_computer_system CS 
              ON sys.resourceid = cs.resourceid 
       LEFT JOIN v_gs_computer_system_product CSP 
              ON sys.resourceid = csp.resourceid 
       LEFT JOIN v_gs_pc_bios BIOS 
              ON SYS.resourceid = BIOS.resourceid 
       LEFT JOIN v_gs_processor CPU 
              ON sys.resourceid = CPU.resourceid 
       LEFT JOIN v_ch_clientsummary CH 
              ON sys.resourceid = ch.resourceid 
WHERE  sys.client0 = 1 
       AND net.macaddress0 IS NOT NULL 
       AND net.ipaddress0 IS NOT NULL 
       AND sys.operating_system_name_and0 IN 
           (SELECT DISTINCT operating_system_name_and0 
            FROM   v_r_system 
            WHERE 
               SYS.operating_system_name_and0 LIKE '%server%') 
ORDER  BY NAME

SELECT DISTINCT sys.netbios_name0                            [Name], 
                CASE 
                  WHEN netbios_name0 LIKE '%WPS%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WPL%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WPC%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WPB%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WPG%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WPU%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WPV%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WPM%' THEN 'Prod' 
                  WHEN netbios_name0 LIKE '%WQS%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WQL%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WQC%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WAG%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WAS%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WAL%' THEN 'QA' 
                  WHEN netbios_name0 LIKE '%WDL%' THEN 'Dev' 
                  WHEN netbios_name0 LIKE '%WDG%' THEN 'Dev' 
                  WHEN netbios_name0 LIKE '%WDS%' THEN 'Dev' 
                  WHEN netbios_name0 LIKE '%PDW%' THEN 'Dev' 
                  WHEN netbios_name0 LIKE '%WTS%' THEN 'Test' 
                  WHEN netbios_name0 LIKE '%WTC%' THEN 'Test' 
                  WHEN netbios_name0 LIKE '%WTL%' THEN 'Test' 
                  WHEN netbios_name0 LIKE '%WTG%' THEN 'Test' 
                  WHEN netbios_name0 LIKE '%WTX%' THEN 'Test' 
                  WHEN netbios_name0 LIKE '%WEC%' THEN 'Education' 
                  WHEN netbios_name0 LIKE '%WEL%' THEN 'Education' 
                  WHEN netbios_name0 LIKE '%WES%' THEN 'Education' 
                  WHEN netbios_name0 LIKE '%WIS%' THEN 'Intermediate' 
                  WHEN netbios_name0 LIKE '%WIL%' THEN 'Intermediate' 
                  WHEN netbios_name0 LIKE '%WRL%' THEN 'Recovery' 
                  WHEN netbios_name0 LIKE '%WRS%' THEN 'Recovery' 
                  WHEN netbios_name0 LIKE '%WRC%' THEN 'Recovery' 
                  WHEN netbios_name0 LIKE '%WSL%' THEN 'Staging' 
                  WHEN netbios_name0 LIKE '%WSC%' THEN 'Staging' 
                  WHEN netbios_name0 LIKE '%WSS%' THEN 'Staging' 
                  ELSE 'Unknown' 
                END                                          [Environment], 
                sys.resource_domain_or_workgr0               [Domain], 
                os.caption0                                  [OS], 
                os.csdversion0                               [Service Pack], 
                sys.client_version0                          [Client Version], 
                net.ipaddress0                               [IP], 
                cs.manufacturer0                             [Mfg], 
                cs.model0                                    [Model], 
                csp.version0                                 [Model Number], 
                BIOS.SerialNumber0                           [Serial Number],
                cs.systemtype0                               [System], 
                bios.smbiosbiosversion0                      [BIOS], 
                cpu.name0                                    [CPU], 
                cpu.normspeed0                               [CPU Speed], 
                (SELECT Count(cpu1.deviceid0) 
                 FROM   v_gs_processor CPU1 
                 WHERE  sys.resourceid = cpu1.resourceid)    [CPU Count], 
                cpu.numberofcores0                           [CPU Core Count], 
                cpu.numberoflogicalprocessors0               [CPU Logical Count] 
                , 
                ( (SELECT Count(cpu1.deviceid0) 
                   FROM   v_gs_processor CPU1 
                   WHERE  sys.resourceid = cpu1.resourceid) * 
                  cpu.numberoflogicalprocessors0 ) 
                [Total CPU Logical Count], 
                cpu.ishyperthreadcapable0                    [HT Capable], 
                cpu.ishyperthreadenabled0                    [HT Enabled], 
                CS.TotalPhysicalMemory0                                                                                          [RAM],
                ch.lastactivetime                            [Last Active], 
                Datediff(day, os.lastbootuptime0, Getdate()) [Uptime in Days] 
FROM   v_r_system SYS 
       LEFT JOIN v_gs_operating_system OS 
              ON sys.resourceid = os.resourceid 
       LEFT JOIN v_gs_network_adapter_configuration NET 
              ON sys.resourceid = net.resourceid 
       LEFT JOIN v_gs_computer_system CS 
              ON sys.resourceid = cs.resourceid 
       LEFT JOIN v_gs_computer_system_product CSP 
              ON sys.resourceid = csp.resourceid 
       LEFT JOIN v_gs_pc_bios BIOS 
              ON SYS.resourceid = BIOS.resourceid 
       LEFT JOIN v_gs_processor CPU 
              ON sys.resourceid = CPU.resourceid 
       LEFT JOIN v_ch_clientsummary CH 
              ON sys.resourceid = ch.resourceid 
WHERE  sys.client0 = 1 
       AND net.macaddress0 IS NOT NULL 
       AND net.ipaddress0 IS NOT NULL 
       AND sys.operating_system_name_and0 IN 
           (SELECT DISTINCT operating_system_name_and0 
            FROM   v_r_system 
            WHERE 
               SYS.operating_system_name_and0 LIKE '%server%') 
ORDER  BY NAME
