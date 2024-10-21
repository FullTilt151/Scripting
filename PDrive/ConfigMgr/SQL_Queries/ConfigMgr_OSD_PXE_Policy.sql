/* Get list of devices and their Last PXE boot for (a) required deployments */
SELECT * FROM LastPXEAdvertisement order by MAC_Addresses

/* Get item key for unknown records */
select * from UnknownSystem_DISC
 
/* Is device known and a valid client on the site */
exec NBS_LookupPXEDevice N'05ce1bb7-6f03-4557-9af1-02d85cf2e1e7',N'00:15:5D:92:04:07'
exec NBS_LookupPXEDevice N'aefb1f88-adeb-4895-9726-44471c301d6b',N'00:15:5D:92:04:07'
 
/* Get list of deployments for device */
exec NBS_GetPXEBootAction N'16777278',N'2046820368',N'05ce1bb7-6f03-4557-9af1-02d85cf2e1e7',N'00:15:5D:92:04:07',N'louappwps1658.rsc.humad.com'
exec NBS_GetPXEBootAction N'16777279',N'2046820369',N'aefb1f88-adeb-4895-9726-44471c301d6b',N'00:15:5D:92:04:07',N'louappwps1658.rsc.humad.com'