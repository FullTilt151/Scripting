CREATE INDEX CMN_missing_index_35_34 ON [SUSDB].[dbo].[tbRevisionSupersedesUpdate] ([SupersededUpdateID])
CREATE INDEX CMN_missing_index_32_31 ON [CM_MT1].[dbo].[System_DISC] ([ManagementAuthority]) INCLUDE ([SMS_Unique_Identifier0])
CREATE INDEX CMN_missing_index_12_11 ON [SUSDB].[dbo].[tbRevision] ([State]) INCLUDE ([LocalUpdateID])
CREATE INDEX CMN_missing_index_44_43 ON [SUSDB].[dbo].[tbDeployment] ([TargetGroupTypeID]) INCLUDE ([ActionID], [RevisionID])
CREATE INDEX CMN_missing_index_46_45 ON [SUSDB].[dbo].[tbDeployment] ([TargetGroupTypeID],[ActionID]) INCLUDE ([RevisionID])
CREATE INDEX CMN_missing_index_14_13 ON [SUSDB].[dbo].[tbDeployment] ([DeploymentStatus], [TargetGroupTypeID],[LastChangeNumber], [UpdateType]) INCLUDE ([GoLiveTime], [RevisionID], [TargetGroupID])
CREATE INDEX CMN_missing_index_229_228 ON [DBATools].[ParaMain].[ObjectGroup] ([SPID]) INCLUDE ([ObjectGroupID])
CREATE INDEX CMN_missing_index_71_70 ON [CM_MT1].[dbo].[CI_ConfigurationItems] ([IsHidden]) INCLUDE ([CI_ID], [ModelId], [CIType_ID], [MinRequiredVersion])
CREATE INDEX CMN_missing_index_73_72 ON [SUSDB].[dbo].[tbRevision] ([State]) INCLUDE ([RevisionID], [LocalUpdateID], [RowID])
CREATE INDEX CMN_missing_index_75_74 ON [CM_MT1].[dbo].[CI_UpdateCIs] ([UpdateSource_ID]) INCLUDE ([CI_ID], [DateRevised], [RevisionNumber])
CREATE INDEX CMN_missing_index_569_568 ON [CM_MT1].[dbo].[CI_ConfigurationItems] ([IsTombstoned]) INCLUDE ([ConfigurationFlags])
CREATE INDEX CMN_missing_index_103_102 ON [CM_MT1].[dbo].[System_DISC] ([Decommissioned0],[ItemKey]) INCLUDE ([SMS_Unique_Identifier0], [Creation_Date0])
CREATE INDEX CMN_missing_index_349_348 ON [CM_MT1].[dbo].[LU_SoftwareList] ([SourceSite],[LastUpdated])
CREATE INDEX CMN_missing_index_41_40 ON [SUSDB].[dbo].[ivwApiUpdateRevision] ([IsLatestRevision]) INCLUDE ([RevisionID])
CREATE INDEX CMN_missing_index_225_224 ON [DBATools].[ParaMain].[CommandLog] ([DatabaseName], [SchemaName], [ObjectName], [ObjectType], [EndTime]) INCLUDE ([conversation_handle])
CREATE INDEX CMN_missing_index_20_19 ON [CM_MT1].[dbo].[CI_ConfigurationItems] ([IsTombstoned], [IsExpired], [SourceSite],[CIType_ID]) INCLUDE ([CI_ID], [DateCreated], [DateLastModified])
CREATE INDEX CMN_missing_index_351_350 ON [CM_MT1].[dbo].[LU_SoftwareHash] ([SourceSite],[LastUpdated])
CREATE INDEX CMN_missing_index_353_352 ON [CM_MT1].[dbo].[LU_SoftwareCode] ([SoftwareCode]) INCLUDE ([SoftwareID])
CREATE INDEX CMN_missing_index_105_104 ON [ReportServer].[dbo].[Catalog] ([Type]) INCLUDE ([ParentID])
CREATE INDEX CMN_missing_index_66_65 ON [SUSDB].[dbo].[tbDeployment] ([TargetGroupTypeID], [UpdateType],[LastChangeNumber]) INCLUDE ([DeploymentID], [RevisionID])
CREATE INDEX CMN_missing_index_107_106 ON [ReportServer].[dbo].[Catalog] ([Type]) INCLUDE ([ItemID], [Path], [ParentID], [Description], [Hidden], [CreationDate])
CREATE INDEX CMN_missing_index_100_99 ON [CM_MT1].[dbo].[Update_ComplianceStatus] ([EnforcementSource],[LastEnforcementMessageID], [LastEnforcementMessageTime]) INCLUDE ([CI_ID], [MachineID])
CREATE INDEX CMN_missing_index_155_154 ON [CM_MT1].[dbo].[StatusMessages] ([DeleteTime]) INCLUDE ([RecordID])
CREATE INDEX CMN_missing_index_62_61 ON [SUSDB].[dbo].[tbRevision] ([IsLeaf]) INCLUDE ([RevisionID], [LocalUpdateID])
CREATE INDEX CMN_missing_index_80_79 ON [CM_MT1].[dbo].[AttributeMap] ([GroupKey], [IsKey])
CREATE INDEX CMN_missing_index_82_81 ON [CM_MT1].[dbo].[AttributeMap] ([IsKey]) INCLUDE ([GroupKey])
CREATE INDEX CMN_missing_index_556_555 ON [CM_MT1].[dbo].[System_DISC] ([Client_Type0]) INCLUDE ([ItemKey], [DiscArchKey], [Decommissioned0])
CREATE INDEX CMN_missing_index_560_559 ON [CM_MT1].[dbo].[System_DISC] ([AADDeviceID]) INCLUDE ([Client0])
CREATE INDEX CMN_missing_index_558_557 ON [CM_MT1].[dbo].[System_DISC] ([AADTenantID])
CREATE INDEX CMN_missing_index_355_354 ON [CM_MT1].[dbo].[System_DISC] ([Unknown0], [Decommissioned0],[ItemKey], [Creation_Date0])
CREATE INDEX CMN_missing_index_22_21 ON [CM_MT1].[dbo].[PolicyAssignment] ([PolicyAssignmentID])
CREATE INDEX CMN_missing_index_157_156 ON [CM_MT1].[dbo].[SCCM_Audit] ([ChangeTime]) INCLUDE ([ID])
CREATE INDEX CMN_missing_index_554_553 ON [CM_MT1].[dbo].[System_DISC] ([Build01]) INCLUDE ([Obsolete0], [Decommissioned0], [OSBranch01])
CREATE INDEX CMN_missing_index_64_63 ON [SUSDB].[dbo].[tbProperty] ([ExplicitlyDeployable],[UpdateType]) INCLUDE ([RevisionID])
CREATE INDEX CMN_missing_index_346_345 ON [CM_MT1].[dbo].[DiscItemAgents] ([DiscArchKey]) INCLUDE ([ItemKey], [AgentTime])
CREATE INDEX CMN_missing_index_24_23 ON [CM_MT1].[dbo].[PolicyAssignment] ([IsTombstoned]) INCLUDE ([PADBID])
CREATE INDEX CMN_missing_index_26_25 ON [CM_MT1].[dbo].[PolicyAssignment] ([IsTombstoned]) INCLUDE ([PADBID], [PolicyAssignmentID])
CREATE INDEX CMN_missing_index_8_7 ON [SUSDB].[dbo].[tbFileOnServer] ([ActualState]) INCLUDE ([RowID])
CREATE INDEX CMN_missing_index_198_197 ON [CM_MT1].[dbo].[DBSchema] ([SiteNumber], [ObjectHash])
CREATE INDEX CMN_missing_index_562_561 ON [CM_MT1].[dbo].[CI_ConfigurationItems] ([IsHidden], [IsTombstoned],[CIType_ID]) INCLUDE ([CI_ID])
CREATE INDEX CMN_missing_index_28_27 ON [CM_MT1].[dbo].[PolicyAssignment] ([PolicyAssignmentID]) INCLUDE ([PADBID])
CREATE INDEX CMN_missing_index_16_15 ON [SUSDB].[dbo].[tbDeadDeployment] ([TargetGroupTypeID],[LastChangeNumber], [UpdateType]) INCLUDE ([TargetGroupID], [UpdateID], [RevisionNumber])
CREATE INDEX CMN_missing_index_159_158 ON [CM_MT1].[dbo].[CollectionNotifications] ([TableName],[RecordID], [MachineID])
CREATE INDEX CMN_missing_index_69_68 ON [SUSDB].[dbo].[tbDeadDeployment] ([TargetGroupTypeID],[LastChangeNumber], [UpdateType]) INCLUDE ([DeploymentID], [RevisionID])
CREATE INDEX CMN_missing_index_162_161 ON [CM_MT1].[dbo].[CollectionNotifications] ([Group_ObjectGUID],[RecordID]) INCLUDE ([MachineID])
CREATE INDEX CMN_missing_index_567_566 ON [CM_MT1].[dbo].[ADDiscoveryStats] ([StartTime]) INCLUDE ([AgentID], [IsFullSync], [DDRCount], [CompleteTime])
CREATE INDEX CMN_missing_index_565_564 ON [CM_MT1].[dbo].[System_DISC] ([AADTenantID]) INCLUDE ([Client0], [AADDeviceID])
CREATE INDEX CMN_missing_index_680_679 ON [ReportServer].[dbo].[Catalog] ([PolicyID]) INCLUDE ([ItemID])
CREATE INDEX CMN_missing_index_374_373 ON [DBATools].[ParaMain].[ObjectGroup] ([SPID]) INCLUDE ([ObjectGroupID], [DatabaseName], [SchemaName], [ObjectName], [ObjectType])
CREATE INDEX CMN_missing_index_196_195 ON [CM_MT1].[dbo].[Update_ComplianceStatus] ([LastStatusCheckTime]) INCLUDE ([CI_ID], [MachineID])
