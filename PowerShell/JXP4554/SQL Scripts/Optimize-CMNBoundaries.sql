Select *
from ADSites
order by SubnetID

Select *
from Boundaries
order by SubnetID

Select *
from CM_Boundaries
order by SubnetID

select *
from CM_Subnets
order by SubnetID

/* 
truncate table adsites
truncate table boundaries
truncate table CM_Boundaries
truncate table CM_Subnets
 */

--ADSites
USE [OptimizeBoundaries]
GO

/****** Object:  Table [dbo].[ADSites]    Script Date: 3/1/2019 2:55:13 PM ******/
DROP TABLE [dbo].[ADSites]
GO

/****** Object:  Table [dbo].[ADSites]    Script Date: 3/1/2019 2:55:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ADSites](
	[SiteKey] [int] IDENTITY(1,1) NOT NULL,
	[Site] [nvarchar](50) NOT NULL,
	[Subnet] [char](19) NOT NULL,
	[SubnetID] [nvarchar](50) NOT NULL,
	[BroadcastID] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_ADSites] PRIMARY KEY CLUSTERED 
(
	[SiteKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

--Boundaries
USE [OptimizeBoundaries]
GO

/****** Object:  Table [dbo].[Boundaries]    Script Date: 3/1/2019 2:56:56 PM ******/
DROP TABLE [dbo].[Boundaries]
GO

/****** Object:  Table [dbo].[Boundaries]    Script Date: 3/1/2019 2:56:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Boundaries](
	[BoundaryID] [int] IDENTITY(1,1) NOT NULL,
	[Subnet] [char](19) NOT NULL,
	[MinIP] [char](15) NOT NULL,
	[MaxIP] [char](15) NOT NULL,
    [SubnetID] [nvarchar](50) NOT NULL,
	[BroadcastID] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Boundaries_1] PRIMARY KEY CLUSTERED 
(
	[BoundaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

--CM_Boundaries
USE [OptimizeBoundaries]
GO

/****** Object:  Table [dbo].[CM_Boundaries]    Script Date: 3/1/2019 2:52:07 PM ******/
DROP TABLE [dbo].[CM_Boundaries]
GO

/****** Object:  Table [dbo].[CM_Boundaries]    Script Date: 3/1/2019 2:52:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CM_Boundaries](
	[BoundaryID] [int] NOT NULL,
	[BoundaryType] [int] NOT NULL,
	[DisplayName] [nvarchar](50) NOT NULL,
	[Value] [nvarchar](50) NOT NULL,
	[SubnetID] [nvarchar](50) NOT NULL,
	[BroadcastID] [nvarchar](50) NOT NULL
 CONSTRAINT [PK_Boundaries] PRIMARY KEY CLUSTERED 
(
	[BoundaryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

--CM_Subnets
USE [OptimizeBoundaries]
GO

/****** Object:  Table [dbo].[CM_Subnets]    Script Date: 3/1/2019 2:57:41 PM ******/
DROP TABLE [dbo].[CM_Subnets]
GO

/****** Object:  Table [dbo].[CM_Subnets]    Script Date: 3/1/2019 2:57:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CM_Subnets](
	[CMSubnetID] [int] IDENTITY(1,1) NOT NULL,
	[Domain] [nvarchar](50) NOT NULL,
	[Subnet] [char](19) NOT NULL,
	[SubnetID] [nvarchar](50) NOT NULL,
	[BroadcastID] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Subnets] PRIMARY KEY CLUSTERED 
(
	[SubnetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
