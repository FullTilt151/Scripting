SELECT DISTINCT TOP 100
  NormalizedPublisher[Vendor],
  NormalizedName[Product],
  NormalizedVersion[Version],
  COUNT(DISTINCT ResourceID) AS 'Installs'
FROM 
  dbo.v_GS_INSTALLED_SOFTWARE_CATEGORIZED
  where NormalizedName NOT LIKE 'Microsoft Visual C++%'
GROUP BY
  NormalizedPublisher,
  NormalizedName,
  NormalizedVersion
ORDER BY 'Installs' DESC