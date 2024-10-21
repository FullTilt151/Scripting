/* Get list of devices and their Last PXE boot for (a) required deployments */
SELECT * FROM LastPXEAdvertisement order by MAC_Addresses
  
/* Get item key for unknown records */
select * from UnknownSystem_DISC
  
/* Is device known and a valid client on the site */
exec NBS_LookupPXEDevice N'5a5fb002-482e-4344-9756-7ce0a655ba58',N'C8:5B:76:A1:CA:0C'

exec NBS_LookupPXEDevice N'45A74041-2F02-4A5E-B413-CD35DDE47123',N'C8:5B:76:A1:CA:0C'
exec NBS_LookupPXEDevice N'2DCFD0F8-9134-44A3-84BB-0BFC114ADD87',N'C8:5B:76:A1:CA:0C'

/* Get list of deployments for device */
exec NBS_GetPXEBootAction N'16777279',N'2046820353',N'5a5fb002-482e-4344-9756-7ce0a655ba58',N'C8:5B:76:A1:CA:0C',N'LOUAPPWPS1658.rsc.humad.com'

exec NBS_GetPXEBootAction N'16777278',N'2046820352',N'45A74041-2F02-4A5E-B413-CD35DDE47123',N'C8:5B:76:A1:CA:0C',N'LOUAPPWPS1658.rsc.humad.com'
exec NBS_GetPXEBootAction N'16777279',N'2046820353',N'2DCFD0F8-9134-44A3-84BB-0BFC114ADD87',N'C8:5B:76:A1:CA:0C',N'LOUAPPWPS1658.rsc.humad.com'