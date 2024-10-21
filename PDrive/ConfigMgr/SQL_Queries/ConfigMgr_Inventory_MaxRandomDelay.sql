SELECT SD.SiteCode, SCC.ClientComponentName, SCP.Name, SCP.Value1, SCP.Value2, SCP.Value3 FROM SC_ClientComponent SCC
JOIN SC_SiteDefinition SD ON SD.SiteNumber = SCC.SiteNumber
JOIN SC_ClientComponent_Property SCP ON SCP.ClientComponentID = SCC.ID
WHERE SCP.Name like '%Inventory Max Random Delay%'
