SELECT csp.Vendor0 [Vendor], csp.Version0 [Model_Name], csp.Name0 [Model_Number], COUNT(*) AS [Count]
FROM            v_R_System_valid sys INNER JOIN
                v_GS_COMPUTER_SYSTEM_PRODUCT csp ON sys.ResourceID = csp.ResourceID
GROUP BY csp.Vendor0, csp.Version0, csp.Name0
ORDER BY Model_Name, Model_Number