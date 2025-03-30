DECLARE @ProductName VARCHAR(255) 
DECLARE productcursor CURSOR FOR 
  SELECT DISTINCT productname0 
  FROM   v_gs_installed_software 
  WHERE  publisher0 LIKE '1E%' 
  ORDER  BY productname0 

OPEN productcursor 

FETCH next FROM productcursor INTO @ProductName 

WHILE @@FETCH_STATUS = 0 
  BEGIN 
      SELECT productname0      [Product], 
             productversion0   [Version], 
             Count(resourceid) AS Total 
      FROM   v_gs_installed_software 
      WHERE  productname0 = @ProductName 
      GROUP  BY productname0, 
                productversion0 
      ORDER  BY productname0, 
                productversion0 

      FETCH next FROM productcursor INTO @ProductName 
  END    
