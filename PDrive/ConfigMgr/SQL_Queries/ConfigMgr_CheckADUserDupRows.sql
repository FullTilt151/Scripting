-- Get extended AD attributes for all sites if AD user discovery is enabled
DECLARE ADAttributeCursor CURSOR LOCAL FOR SELECT scpl.Value FROM SC_Component sc 
INNER JOIN SC_Component_Property scp ON sc.ID = scp.ComponentID 
INNER JOIN SC_Component_PropertyList scpl ON sc.ID = scpl.ComponentID
WHERE ComponentName = 'SMS_AD_USER_DISCOVERY_AGENT' AND scp.Name = 'SETTINGS' AND Value1 = 'ACTIVE' AND scpl.Name = 'AD Attributes'

DECLARE @ADAttributes TABLE (Attribute NVARCHAR(MAX))
DECLARE @ADAttributesXML XML

OPEN ADAttributeCursor;     
FETCH NEXT FROM ADAttributeCursor INTO @ADAttributesXML;   
WHILE @@FETCH_STATUS = 0    
BEGIN 
    INSERT INTO @ADAttributes SELECT T.c.value('.', 'NVARCHAR(MAX)') AS ADAttribute FROM @ADAttributesXML.nodes('/PropList/Value') T(c)

    FETCH NEXT FROM ADAttributeCursor INTO @ADAttributesXML;    
END 
 
CLOSE ADAttributeCursor;  
DEALLOCATE ADAttributeCursor; 

-- Compare with User Discovery Schema to find out if all extended AD attributes are defined there and have case sensitive name difference
SELECT aa.Attribute AS ProposedAttribute, dpd.PropertyName AS ActualAttribute FROM (SELECT DISTINCT Attribute FROM @ADAttributes) aa
INNER JOIN DiscPropertyDefs dpd ON aa.Attribute = dpd.PropertyName AND dpd.DiscArchKey = 4
WHERE aa.Attribute <> dpd.PropertyName COLLATE SQL_Latin1_General_CP1_CS_AS
