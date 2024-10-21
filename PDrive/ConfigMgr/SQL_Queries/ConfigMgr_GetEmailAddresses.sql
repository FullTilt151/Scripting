/* Drop WKIDs into the parentheses. Use UltraEdit to format. Find/Replace ^p with ',' */ 
SELECT UMR.MachineResourceName, UMR.UniqueUserName, Mail0
FROM v_R_User U
JOIN v_UserMachineRelationship UMR ON UMR.UniqueUserName = U.Unique_User_Name0
where MachineResourceName in ()