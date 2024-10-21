Select Distinct ARP.DisplayName0, ARP.Publisher0, ARP.Version0, ARP.ProdID0
from v_Add_Remove_Programs ARP
Where ARP.DisplayName0 not in (Select distinct GSIS.ARPDisplayName0 From dbo.v_GS_INSTALLED_SOFTWARE GSIS)
Order by ARP.DisplayName0, ARP.Publisher0, ARP.Version0, ARP.ProdID0