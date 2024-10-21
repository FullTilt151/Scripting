-- Count of versions of System Update
select distinct Publisher0, ProductName0, ProductVersion0, sft.UninstallString0, count(*)
from v_R_System_Valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 = 'Lenovo System Update'
group by Publisher0, ProductName0, ProductVersion0, sft.UninstallString0
order by Publisher0, ProductName0, ProductVersion0, sft.UninstallString0

-- List of WKIDs with System Update
select sys.Netbios_Name0, sft.Publisher0, sft.ProductName0, sft.ProductVersion0, sft.UninstallString0
from v_R_System_Valid sys join
	 v_GS_INSTALLED_SOFTWARE sft on sys.ResourceID = sft.ResourceID
where ProductName0 = 'Lenovo System Update'
order by Netbios_Name0

-- Usage of System Update
select cdr.Name, ExplorerFileName0, LastUsedTime0, LastUserName0
from vSMS_CombinedDeviceResources cdr inner join
	 v_GS_CCM_RECENTLY_USED_APPS rua on cdr.MachineID = rua.ResourceID
where ExplorerFileName0 = 'tvsu.exe'
order by LastUsedTime0 desc

-- Top users
select LastUserName0, count(*)
from v_GS_CCM_RECENTLY_USED_APPS
where ExplorerFileName0 = 'tvsu.exe'
group by LastUserName0
order by count(*) desc

select Full_User_Name0, Mail0, title0, department0
from v_R_User
where Unique_User_Name0 in (
'HUMAD\TKP0794A',
'HUMAD\MAB0296A',
'HUMAD\VGY2796A',
'HUMAD\PXV0036A',
'HUMAD\JBU3495A',
'HUMAD\nxl2155a',
'HUMAD\MAS2356A',
'HUMAD\TXS5074A',
'HUMAD\LYS1592A',
'HUMAD\rxm5116a',
'HUMAD\adc8011a',
'HUMAD\kek4355a',
'HUMAD\JXW1692A',
'HUMAD\env9824a'
)