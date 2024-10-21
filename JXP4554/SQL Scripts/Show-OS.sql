Select *
from humana_os_caption_displayname

SELECT DISTINCT SYS.operating_system_name_and0 [Caption],
                OS.caption0                    [DisplayName]
FROM   v_r_system SYS
       JOIN v_gs_operating_system OS
         ON SYS.resourceid = OS.resourceid
WHERE  SYS.operating_system_name_and0 IS NOT NULL
       AND SYS.operating_system_name_and0 != ''
       AND OS.caption0 IS NOT NULL
       AND OS.caption0 != ''
ORDER  BY caption