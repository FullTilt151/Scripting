-- List of Boundary Groups
select * from BoundaryGroup

-- Boundary Groups without site assignment
select * from BoundaryGroup where LEN(DefaultSiteCode) > 0 and isnull(IsBuiltIn,0) != 1

-- List of Boundaries with Numeric values
select * from BoundaryEx

-- MPLocation SPs (# of rows per MP increases exponentially with # of MPs)
exec GetMPLocationForIPSubnet N'193.51.87.0'
exec GetMPLocationForIPAddressAndADSite N'3241367296',N'LOUISVILLE'

-- Site control file
select SiteControl from vSMS_SC_SiteControlXML where sitecode = 'WP1'