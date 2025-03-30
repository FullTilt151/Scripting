-- View all OS
select *
from Humana_OS_Caption_DisplayName

-- View missing OS
select distinct Operating_System_Name_and0
from v_r_system
where Operating_System_Name_and0 not in (select Caption from Humana_OS_Caption_DisplayName)

-- Insert new OS
/*
INSERT INTO Humana_OS_Caption_DisplayName (Caption, DisplayName)
VALUES ('Microsoft Windows NT Workstation 10.0 (Tablet Edition)', 'Windows 10');

INSERT INTO Humana_OS_Caption_DisplayName (Caption, DisplayName)
VALUES ('Microsoft Windows NT Workstation 10.0', 'Windows 10');
*/