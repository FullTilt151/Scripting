SELECT DISTINCT DisplayName + ' (' + Caption + ')' [Label], 
                DisplayName                        [Value] 
FROM   Humana_Client_Versions HCV 
       JOIN v_R_System SYS 
         ON SYS.Client_Version0 = HCV.DisplayName 
ORDER  BY DisplayName 

SELECT Netbios_Name0 [Name], 
       HCV.Caption   [Client Version] 
FROM   v_R_System_Valid SYS 
       JOIN Humana_Client_Versions HCV 
         ON SYS.Client_Version0 = HCV.DisplayName 
WHERE  Client_Version0 IN ( @ClientVersion )  