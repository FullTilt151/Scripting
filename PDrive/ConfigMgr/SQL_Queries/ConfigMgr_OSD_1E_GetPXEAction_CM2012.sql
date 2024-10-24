
/****** Object:  StoredProcedure [dbo].[1E_GetPXEAction]    Script Date: 12/05/2012 17:26:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[1E_GetPXEAction] (
	@SMBIOS_GUID VARCHAR(38),	-- e.g. '4C4C4544-0047-5610-8054-C2C04F43324A'
	@MACAddress VARCHAR(64)		-- e.g. '00:16:76:2F:05:42'
)
AS
BEGIN
	SET NOCOUNT ON 

	/* This part's taken from NBS_LookupDevice. It matches the SMBIOS GUID to
	 * the ItemKey (a resource ID), or if that's not possible, it uses the MAC
	 * address.
	 */
	DECLARE @itemKeyByGuid INT
	DECLARE @itemKeyByMac INT
	DECLARE @sitecode varchar(3)
	DECLARE @Itemkey1 INT

	--For unknown deployments, PXE Lite will update System_Aux_Info unknown record with target machine SMBIOS.
	--Identify unknown itemkey and remove this.
	SELECT @sitecode = string1 FROM SetupInfo WHERE id = 'SITECODE'

	CREATE TABLE #T (SMS_Unique_Identifier0 varchar(1000),itemkey varchar(1000))
	INSERT INTO #T EXECUTE dbo.PXE_GetUnknownMachineResource @sitecode, 'x86'
	SELECT @itemKey1 = CONVERT(INT,itemkey) FROM #T
	DROP TABLE #T

	SELECT
			@itemKeyByGuid = MAX(aux.ItemKey),
			@itemKeyByMac = MAX(mac.ItemKey)
		FROM MachineIdGroupXRef xref
		LEFT JOIN System_AUX_Info aux
		  ON xref.MachineID = aux.ItemKey AND aux.SMBIOS_GUID0 = @SMBIOS_GUID
		LEFT JOIN System_MAC_Addres_ARR mac 
		  ON xref.MachineID = mac.ItemKey AND mac.MAC_Addresses0 = @MACAddress
		INNER JOIN System_DISC disc
		  ON xref.MachineID = disc.ItemKey AND Disc.Decommissioned0 = 0

	--If target machine not found in CM, then use unknown machine itemkey
	IF (@itemKeyByGuid IS NULL AND @itemKeyByMac IS NULL) SET @itemKeyByMac = @itemkey1

	IF ( @SMBIOS_GUID = 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF' OR @SMBIOS_GUID = '00000000-0000-0000-0000-000000000000') SET @itemKeyByGuid = NULL

	/* Use the SMBIOS GUID if possible; if not, use the MAC */
	DECLARE @ItemKey INT
	SELECT @ItemKey = ISNULL(@itemKeyByGuid, @itemKeyByMac)

	--Clear any "unknown" entry in System_Aux_Info - inserted by default for every client booting by PXE Lite
--	UPDATE System_Aux_Info SET LastPXEAdvertisementTime = NULL, LastPXEAdvertisementID = NULL, SMBIOS_GUID0 = NULL WHERE ITEMKEY = @itemKey1
--	UPDATE LastPXEAdvertisement SET LastPXEAdvertisementTime = NULL, LastPXEAdvertisementID = NULL, SMBIOS_GUID = NULL WHERE MachineID = @itemKey1

	/*** At this point, we've figured out the resource ID ***/

	/* This part's taken from NBS_GetPXEAction, except that it doesn't care
	 * which DP has the content (we assume that it's already been distributed
	 * to a PXE Lite branch server).
	 */
	SELECT
			xref.MachineID     AS 'MachineID',
			mac.MAC_Addresses0 AS 'MACAddress',
			aux.SMBIOS_GUID0   AS 'SMBIOS_GUID',
			xref.GUID          AS 'SMS_UniqueIdentifier0',
			lpa.LastPXEAdvertisementID   AS 'LastPXEAdvertisementID',
			lpa.LastPXEAdvertisementTime AS 'LastPXEAdvertisementTime',
			sp.OfferID         AS 'OfferID',
			po.PresentTime     AS 'OfferIDTime',
			po.PkgID           AS 'PkgID',
			tspkg.Version      AS 'PackageVersion',
			tspkg.BootImageID  AS 'BootImageID',
			CASE
				WHEN ((po.OfferFlags & 0x00000620) != 0) THEN 1         -- 0x620 = AP_ON_LOGON | AP_ON_LOGOFF | AP_ASAP  
				WHEN (ISNULL(po.MandatorySched,'')!= '') THEN 1  
				ELSE 0
			END AS 'Mandatory'
		INTO #pxe_offers		-- use a temporary table; it makes the queries below much clearer.
		FROM MachineIdGroupXRef xref  
		LEFT JOIN ( SELECT LastPXEAdvertisementID as LastPXEAdvertisementID, 
LastPXEAdvertisementTime as LastPXEAdvertisementTime, @ItemKey as ItemKey 
                  FROM   LastPXEAdvertisement 
                  WHERE  MAC_Addresses = @MACAddress AND Temporary != 1) as lpa 
ON lpa.ItemKey = xref.MachineID 
		LEFT JOIN System_AUX_Info AS aux  
			ON xref.MachineID = aux.ItemKey  
		LEFT JOIN System_MAC_Addres_ARR AS mac   
			ON xref.MachineID  = mac.ItemKey  
		INNER JOIN ResPolicyMap AS rpm  
			ON xref.MachineID = rpm.MachineID 
		INNER JOIN SoftwarePolicy AS sp   
			ON (rpm.PADBID = sp.PADBID AND rpm.IsTombstoned != 1)  
		INNER JOIN ProgramOffers AS po    
			ON sp.OfferID = po.OfferID  
		INNER JOIN vSMS_TaskSequencePackage AS tspkg    
			ON (tspkg.PkgID = sp.PkgID AND (ISNULL(tspkg.BootImageID,'')!= ''))  
		WHERE xref.MachineID = @ItemKey AND
			(po.OfferFlags &  0x00040000) != 0   -- 0x00040000  = AP_ENABLE_TS_FROM_CD_AND_PXE 

	/* WDS appears to get the most-recent offer (based on OfferIDTime). If, in that, LastPXEAdvertisementID <> OfferID,
	 * then it boots into that.
	 */
	DECLARE @LastPXEAdvertisementID VARCHAR(8)
	DECLARE @OfferID VARCHAR(8)

	DECLARE @BootImageID VARCHAR(8)
	DECLARE @Mandatory BIT

	SELECT TOP 1
			@LastPXEAdvertisementID = ISNULL(LastPXEAdvertisementID, ''), @OfferID = OfferID,
			@BootImageID = BootImageID, @Mandatory = Mandatory
		FROM #pxe_offers
		WHERE Mandatory = 1
		ORDER BY OfferIDTime DESC

	IF @LastPXEAdvertisementID <> @OfferID
	BEGIN
		SELECT @ItemKey AS ItemKey, @OfferID AS OfferID, @BootImageID AS BootImageID, @Mandatory AS Mandatory
		DROP TABLE #pxe_offers
		RETURN
	END

	SET @OfferID = NULL
	SET @BootImageID = NULL
	SET @Mandatory = NULL

	/* The next bit looks easy: if there are any non-mandatory advertisements for this machine, then offer pxeboot.f12. */
	/* But: what if there are multiple non-mandatory advertisements, and they're using different boot images? */
	/* In that case, we pick the most-recently-offered. */
	SELECT TOP 1
			@OfferID = OfferID, @BootImageID = BootImageID, @Mandatory = Mandatory
		FROM #pxe_offers
		WHERE Mandatory = 0
		ORDER BY OfferIDTime DESC

	IF @BootImageID IS NOT NULL
	BEGIN
		SELECT @ItemKey AS ItemKey, @OfferID AS OfferID, @BootImageID AS BootImageID, @Mandatory AS Mandatory
		DROP TABLE #pxe_offers
		RETURN
	END

	DROP TABLE #pxe_offers
END
