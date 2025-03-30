SELECT TOP 50 *
FROM v_GS_INSTALLED_SOFTWARE
WHERE ProductName0 IN ('Adobe Flash Player 24 ActiveX', 'Adobe Flash Player 23 ActiveX', 'Adobe Flash Player 22 ActiveX', 'Adobe Flash Player 21 ActiveX', 'Adobe Flash Player 20 ActiveX', 'Adobe Flash Player 19 ActiveX', 'Adobe Flash Player 18 ActiveX', 'Adobe Flash Player 17 ActiveX', 'Adobe Flash Player 16 ActiveX', 'Adobe Flash Player 15 ActiveX', 'Adobe Flash Player 24 NPAPI', 'Adobe Flash Player 23 NPAPI', 'Adobe Flash Player 22 NPAPI', 'Adobe Flash Player 21 NPAPI', 'Adobe Flash Player 20 NPAPI', 'Adobe Flash Player 19 NPAPI', 'Adobe Flash Player 18 NPAPI', 'Adobe Flash Player 17 NPAPI', 'Adobe Flash Player 16 NPAPI', 'Adobe Flash Player 25 ActiveX', 'Adobe Flash Player 25 NPAPI', 'Adobe Flash Player 26 ActiveX', 'Adobe Flash Player 26 NPAPI', 'Adobe Flash Player 27 ActiveX', 'Adobe Flash Player 27 NPAPI', 'Adobe Flash Player 28 NPAPI', 'Adobe Flash Player 28 ActiveX', 'Adobe Flash Player 29 ActiveX', 'Adobe Flash Player 29 NPAPI', 'Adobe Flash Player 30 NPAPI', 'Adobe Flash Player 30 ActiveX', 'Adobe Flash Player 31 ActiveX', 'Adobe Flash Player 32 ActiveX', 'Adobe Flash Player 31 NPAPI', 'Adobe Flash Player 32 NPAPI')

Select distinct ProductName0
from V_GS_Installed_Software
where ProductName0 like 'Adobe%'
order by ProductName0