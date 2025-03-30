-- Patches missing from base image
select distinct UI.BulletinID, ui.ArticleID, ui.Title, cici.CategoryInstanceName [Product], ui.DateRevised, ucs.NumPresent, ui.IsSuperseded, ui.isdeployed,
	   case 
	   when ui.ci_id in (select Patch.UpdateID
from ImageServicingScheduledImage Image full join
	 ImageServicingScheduledUpdate Patch on Image.scheduleid = Patch.ScheduleID left join
	 v_Package PKG on image.ImagePackageID = PKG.PackageID
where ImagePackageID = 'CAS000D4')  then 'Base Image'
	   when ui.ci_id  in (select Patch.UpdateID
from ImageServicingScheduledImage Image full join
	 ImageServicingScheduledUpdate Patch on Image.scheduleid = Patch.ScheduleID left join
	 v_Package PKG on image.ImagePackageID = PKG.PackageID
where ImagePackageID = 'CAS00E32') then 'Humana Image'
	   else 'No'
	   end [Serviced],
	  (select AL1.Title
		from v_CIRelation CIR1 full join
		v_AuthListInfo AL1 on cir1.FromCIID = AL1.CI_ID
		where cir.ToCIID = cir1.ToCIID and
		cir1.FromCIID = 16871884) [2x Reboot]
from v_Update_ComplianceSummary UCS full join
	 v_UpdateInfo UI on UCS.CI_ID = UI.CI_ID full join
	 v_CIRelation CIR on UI.CI_ID = cir.ToCIID full join
	 v_AuthListInfo AL on CIR.FromCIID = al.CI_ID full join
	 v_CITypes CIT on ui.CIType_ID = cit.CIType_ID full join
	 v_CICategoryInfo CICI on ui.CI_ID = CICI.CI_ID
where ui.CIType_ID != 9 and 
	 ucs.NumPresent > 5000 and
	 cici.CategoryTypeName = 'Product' and
	 cici.CategoryInstanceName not in (
	 'Windows Server 2003',
	 'Windows Server 2003, Datacenter Edition',
	 'Windows Server 2008',
	 'Windows Server 2008 R2',
	 'Windows Server 2012',
	 'Windows Embedded Standard 7',
	 'Microsoft Application Virtualization 4.6',
	 'Visual Studio 2008',
	 'Visual Studio 2010',
	 'Visual Studio 2012',
	 'Visual Studio 2013',
	 'Office 2007',
	 'Office 2016',
	 'ASP.NET Web Frameworks',
	 'SQL Server 2008',
	 'Microsoft SQL Server 2012',
	 'Microsoft SQL Server 2014',
	 'Silverlight',
	 'Windows Vista',
	 'Windows 8',
	 'Windows XP x64 Edition'
	 ) and
	   ui.CI_ID not in (
	   select ToCIID
		from v_CIRelation
		where FromCIID = 16871166) and 
		UI.title not like 'Security Update for Microsoft .NET Framework 4.5 %' and -- SUPERSEDED by .NET 4.5.2
		ui.title not like 'Cumulative Security Update for Internet Explorer 9 for Windows 7 for x64-based Systems%' and -- SUPERSEDED by IE11
		ui.title not in (
		'Internet Explorer 11 for Windows 7 for x64-based Systems', -- PACKAGE
		'Microsoft .NET Framework 4.5.2 for Windows 7 x64-based Systems (KB2901983)', -- PACKAGE
		'Service Pack 1 for Microsoft Office 2010 (KB2510690) 32-bit Edition', -- PACKAGE
		'Update for Microsoft Lync 2013 (KB2889860) 32-Bit Edition', -- PACKAGE
		'Update for Microsoft Visual Studio 2010 Tools for Office Runtime (KB2796590)', -- PACKAGE
		'Internet Explorer 11 for Windows 7 for x64-based Systems',
		'Microsoft .NET Framework 4.5.2 for Windows 7 x64-based Systems (KB2901983)',
		'Microsoft SQL Server 2008 R2 Service Pack 3 (KB2979597)',
		'Microsoft SQL Server 2008 R2 Service Pack 3 (KB2979597)',
		'Microsoft SQL Server 2012 Service Pack 1 (KB2674319)',
		'Microsoft SQL Server 2012 Service Pack 3 (KB3072779)',
		'Security Update for Microsoft .NET Framework 3.5.1 on Windows 7 and Windows Server 2008 R2 SP1 for x64 (KB3142042)',
		'Security Update for Microsoft .NET Framework 4.5 and 4.5.1 on Windows 7, Vista, Server 2008, Server 2008 R2 x64 (KB2894854)',
		'Security Update for Microsoft .NET Framework 4.5 on Windows 7, Vista, Server 2008, and Server 2008 R2 for x64 (KB2737083)',
		'Security Update for Microsoft .NET Framework 4.5 on Windows 7, Vista, Windows Server 2008, Windows Server 2008 R2 for x64 (KB2742613)',
		'Security Update for Microsoft .NET Framework 4.5 on Windows 7, Vista, Windows Server 2008, Windows Server 2008 R2 for x64 (KB2840642)',
		'Security Update for Microsoft .NET Framework 4.5 on Windows 7, Vista, Windows Server 2008, Windows Server 2008 R2 for x64 (KB2861208)',
		'Security Update for Microsoft .NET Framework 4.5 on Windows 7, Vista, Windows Server 2008, Windows Server 2008 R2 for x64 (KB2898864)',
		'Security Update for Microsoft .NET Framework 4.5 on Windows 7, Vista, Windows Server 2008, Windows Server 2008 R2 for x64 (KB2901118)',
		'Security Update for Microsoft Excel 2010 (KB3115322) 32-Bit Edition',
		'Security Update for Microsoft Excel 2013 (KB3118284) 32-Bit Edition',
		'Security Update for Microsoft Filter Pack 2.0 (KB2553501) 64-Bit Edition',
		'Security Update for Microsoft Office 2010 (KB2553154) 32-Bit Edition',
		'Security Update for Microsoft Office 2010 (KB2956076) 32-Bit Edition',
		'Security Update for Microsoft Office 2010 (KB3114400) 32-Bit Edition',
		'Security Update for Microsoft Office 2010 (KB3114869) 32-Bit Edition',
		'Security Update for Microsoft Office 2013 (KB2880463) 32-Bit Edition',
		'Security Update for Microsoft Office 2013 (KB3118268) 32-Bit Edition',
		'Security Update for Microsoft Outlook 2010 (KB3115474) 32-Bit Edition',
		'Security Update for Microsoft Outlook 2013 (KB3118280) 32-Bit Edition',
		'Security Update for Microsoft PowerPoint 2010 (KB2920812) 32-Bit Edition',
		'Security Update for Microsoft PowerPoint 2010 (KB3115118) 32-Bit Edition',
		'Security Update for Microsoft Project 2013 (KB3101506) 32-Bit Edition',
		'Security Update for Microsoft Visio 2010 (KB3114872) 32-Bit Edition',
		'Security Update for Microsoft Visual Studio 2008 Service Pack 1 (KB2669970)',
		'Security Update for Microsoft Visual Studio 2008 Service Pack 1 (KB972222)',
		'Security Update for Microsoft Visual Studio 2008 Service Pack 1 XML Editor (KB2251487)',
		'Security Update for Microsoft Visual Studio 2008 Service Pack 1 XML Editor (KB2251487)',
		'Security Update for Microsoft Visual Studio 2008 Service, Pack 1 (KB2669970)',
		'Security Update for Microsoft Visual Studio 2010 Service Pack 1 (KB2645410)',
		'Security Update for Microsoft Visual Studio 2010 Service Pack 1 (KB2645410)',
		'Security Update for Microsoft Word 2010 (KB2965313) 32-Bit Edition',
		'Security Update for Microsoft Word 2010 (KB3115471) 32-Bit Edition',
		'Security Update for Microsoft Word 2013 (KB3115449) 32-Bit Edition',
		'Security Update for Skype for Business 2015 (KB3039779) 32-Bit Edition',
		'Security Update for Skype for Business 2015 (KB3115431) 32-Bit Edition',
		'Security Update for SQL Server 2012 Service Pack 2 (KB3045321)',
		'Security Update for Windows 7 for x64-based Systems (KB2536275)',
		'Security Update for Windows 7 for x64-based Systems (KB2544893)',
		'Security Update for Windows 7 for x64-based Systems (KB2868626)',
		'Security Update for Windows 7 for x64-based Systems (KB3000483)',
		'Security Update for Windows 7 for x64-based Systems (KB3005607)',
		'Security Update for Windows 7 for x64-based Systems (KB3033929)',
		'Security Update for Windows 7 for x64-based Systems (KB3076949)',
		'Security Update for Windows 7 for x64-based Systems (KB3124280)',
		'Security Update for Windows 7 for x64-based Systems (KB3138962)',
		'Security Update for Windows 7 for x64-based Systems (KB3145739)',
		'Service Pack 1 for Microsoft Office 2010 (KB2510690) 32-bit Edition',
		'Service Pack 1 for Microsoft Office 2013 (KB2850036) 32-Bit Edition',
		'Service Pack 2 for Microsoft Office 2010 (KB2687455) 32-Bit Edition',
		'Update for Microsoft Visual Studio 2008 Service Pack 1 (KB2938806)',
		'Update for Microsoft Visual Studio 2010 Tools for Office Runtime (KB2796590)',
		'Update for Microsoft Visual Studio 2012 (KB2781514)',
		'Update for Microsoft Visual Studio 2012 (KB3002339)',
		'Update for Skype for Business 2015 (KB3115033) 32-Bit Edition',
		'Update for Windows 7 for x64-based Systems (KB2718704)',
		'Update for Windows 7 for x64-based Systems (KB3020369)',
		'Windows 7 Service Pack 1 for x64-based Systems (KB976932)')
order by cici.CategoryInstanceName, ui.ArticleID, UI.Title