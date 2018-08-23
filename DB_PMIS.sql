USE [master]
GO
/****** Object:  Database [PMIS]    Script Date: 8/3/2018 8:40:10 AM ******/
CREATE DATABASE [PMIS]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'PMIS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\PMIS.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'PMIS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\PMIS_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [PMIS] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [PMIS].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [PMIS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [PMIS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [PMIS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [PMIS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [PMIS] SET ARITHABORT OFF 
GO
ALTER DATABASE [PMIS] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [PMIS] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [PMIS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [PMIS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [PMIS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [PMIS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [PMIS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [PMIS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [PMIS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [PMIS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [PMIS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [PMIS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [PMIS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [PMIS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [PMIS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [PMIS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [PMIS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [PMIS] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [PMIS] SET RECOVERY FULL 
GO
ALTER DATABASE [PMIS] SET  MULTI_USER 
GO
ALTER DATABASE [PMIS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [PMIS] SET DB_CHAINING OFF 
GO
ALTER DATABASE [PMIS] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [PMIS] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N'PMIS', N'ON'
GO
USE [PMIS]
GO
/****** Object:  User [pmis]    Script Date: 8/3/2018 8:40:10 AM ******/
CREATE USER [pmis] FOR LOGIN [pmis] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [pmis]
GO
/****** Object:  StoredProcedure [dbo].[spGetParticipants]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetParticipants]

as

begin
	SELECT
	p.projId,
	CONCAT(u.firstname, ' ', u.lastname) as 'fullname',
	u.profpath
	FROM participant as p
	INNER JOIN [user] as u on u.userId = p.userId
	INNER JOIN project as pr on pr.projId = p.projId
end


GO
/****** Object:  StoredProcedure [dbo].[spGetParticipantsByProj]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[spGetParticipantsByProj]

	@projId int = null
AS

BEGIN
	SELECT
		u.userId, 
		CONCAT(u.firstname, ' ' ,SUBSTRING(u.middlename, 1, 1), '. ' ,  u.lastname) as 'fullname',
		u.profpath,
		COUNT(p.userId) as 'creator',
		u.firstname as 'position'
	
	FROM participant as pp
	INNER JOIN [user] as u ON u.userId = pp.userId
	LEFT JOIN project as p ON p.projId = pp.projId AND p.userId = u.userId
	WHERE pp.projId = @projId

	group by u.userId, u.firstname, u.middlename, u.lastname, u.profpath
	ORDER BY creator desc, fullname asc
END
GO
/****** Object:  StoredProcedure [dbo].[spGetProjList]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetProjList]

as

begin
SELECT 
	p.projId,
	p.[status],
	p.title,
	CONCAT(u.lastname, ', ', SUBSTRING(u.firstname, 1, 1), SUBSTRING(u.middlename, 1, 1)) as 'creator',
	COUNT(t.taskId) as "Completed"

	FROM project as p

	INNER JOIN [user] as u ON u.userId = p.userId
	LEFT JOIN task as t ON t.projId = p.projId AND t.[status] = 'Completed'
	
	group by p.title, p.[status], p.projId, u.lastname, u.firstname, u.middlename
	order by p.title
end
GO
/****** Object:  StoredProcedure [dbo].[spGetWorkspace]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetWorkspace]

as

begin
SELECT 
	wp.wspaceId,
	wp.title,
	COUNT(wpm.userId) as 'Members',
	COUNT(wpm.userId) as 'Projects',
	wp.wspaceId as 'Percentage'

FROM
	workspace as wp
LEFT JOIN wspacemember as wpm ON wpm.wspaceId = wp.wspaceId
GROUP BY wp.wspaceId, wp.title
end
GO
/****** Object:  StoredProcedure [dbo].[spMyWorkspace]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spMyWorkspace]
	@userId int = null
as

begin
	SELECT 
	wp.wspaceId,
	wp.title,
	wp.created as 'Creator'

	FROM workspace as wp
	INNER JOIN wspacemember as wpm ON wpm.wspaceId = wp.wspaceId AND wpm.userId = @userId
	GROUP BY wp.wspaceId, wp.title, wp.created
end
GO
/****** Object:  StoredProcedure [dbo].[spProjectDetails]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spProjectDetails]
 @projId int = null
as

begin
	SELECT 
	p.projId,
	p.[status],
	p.title,
	CONCAT(u.lastname, ', ', SUBSTRING(u.firstname, 1, 1), SUBSTRING(u.middlename, 1, 1)) as 'creator',
	p.client,
	p.version,
	p.lastupdated,
	p.createddate,
	p.projId as 'Percentage'

FROM project as p
INNER JOIN [user] as u ON u.userId = p.userId
WHERE p.projId = @projId
end
GO
/****** Object:  Table [dbo].[participant]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[participant](
	[partId] [int] IDENTITY(1,1) NOT NULL,
	[projId] [int] NOT NULL,
	[userId] [int] NOT NULL,
 CONSTRAINT [PK_participant] PRIMARY KEY CLUSTERED 
(
	[partId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[projecmessage]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[projecmessage](
	[messId] [int] NOT NULL,
	[projId] [int] NOT NULL,
	[message] [varchar](50) NOT NULL,
	[date] [varchar](50) NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[project]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[project](
	[projId] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](50) NOT NULL,
	[userId] [int] NOT NULL,
	[client] [varchar](50) NOT NULL,
	[lastupdated] [varchar](50) NOT NULL,
	[version] [varchar](50) NOT NULL,
	[status] [varchar](50) NOT NULL,
	[createddate] [varchar](50) NOT NULL,
	[enddate] [varchar](50) NOT NULL,
	[wspaceId] [int] NULL,
 CONSTRAINT [PK_project] PRIMARY KEY CLUSTERED 
(
	[projId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[task]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[task](
	[taskId] [int] IDENTITY(1,1) NOT NULL,
	[projId] [int] NOT NULL,
	[title] [varchar](50) NOT NULL,
	[description] [varchar](200) NOT NULL,
	[createdby] [int] NOT NULL,
	[assignto] [int] NOT NULL,
	[startdate] [varchar](50) NOT NULL,
	[enddate] [varchar](50) NOT NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_task] PRIMARY KEY CLUSTERED 
(
	[taskId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[user]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[user](
	[userId] [int] IDENTITY(1,1) NOT NULL,
	[username] [varchar](50) NOT NULL,
	[password] [varchar](50) NOT NULL,
	[firstname] [varchar](50) NOT NULL,
	[middlename] [varchar](50) NOT NULL,
	[lastname] [varchar](50) NOT NULL,
	[profpath] [varchar](50) NOT NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[workspace]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[workspace](
	[wspaceId] [int] IDENTITY(1,1) NOT NULL,
	[title] [varchar](50) NOT NULL,
	[created] [varchar](50) NOT NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_workspace] PRIMARY KEY CLUSTERED 
(
	[wspaceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[wspacemember]    Script Date: 8/3/2018 8:40:10 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wspacemember](
	[wmemId] [int] IDENTITY(1,1) NOT NULL,
	[wspaceId] [int] NOT NULL,
	[userId] [int] NOT NULL,
 CONSTRAINT [PK_wspacemember] PRIMARY KEY CLUSTERED 
(
	[wmemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET IDENTITY_INSERT [dbo].[participant] ON 

INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (1, 2, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (2, 2, 3)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (3, 5, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (4, 2, 9)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (5, 2, 10)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (6, 2, 8)
SET IDENTITY_INSERT [dbo].[participant] OFF
SET IDENTITY_INSERT [dbo].[project] ON 

INSERT [dbo].[project] ([projId], [title], [userId], [client], [lastupdated], [version], [status], [createddate], [enddate], [wspaceId]) VALUES (2, N'Project Management Information System', 1, N'ako', N'2018-07-24', N'V1', N'Active', N'2018-07-24', N'2018-07-24', 1)
INSERT [dbo].[project] ([projId], [title], [userId], [client], [lastupdated], [version], [status], [createddate], [enddate], [wspaceId]) VALUES (5, N'Odong nga lami System', 1, N'ako', N'2018-07-24', N'V1', N'Completed', N'2018-07-24', N'2018-07-24', 1)
SET IDENTITY_INSERT [dbo].[project] OFF
SET IDENTITY_INSERT [dbo].[task] ON 

INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (1, 2, N'Interface', N'OO', 1, 1, N'safd', N'sdf', N'Completed')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (2, 2, N'Login Interface', N'sdf', 1, 1, N'sdf', N'sdf', N'Ongoing')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (3, 2, N'Register Interface', N'sdf', 1, 2, N'sdf', N'sdf', N'Ongoing')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (5, 5, N'Interface Design', N'Oh part', 1, 9, N'sdf', N'sdf', N'Completed')
SET IDENTITY_INSERT [dbo].[task] OFF
SET IDENTITY_INSERT [dbo].[user] ON 

INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (1, N'admin', N'232f297a57a5a743894a0e4a801fc3', N'Emmanuel Paul', N'Gabionza', N'Moralde', N'/uploads/Moralde.png', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (3, N'Kasumeme', N'232f297a57a5a743894a0e4a801fc3', N'Kasumi', N'Yuki', N'Toyama', N'/uploads/Kasumeme.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (6, N'Yume', N'232f297a57a5a743894a0e4a801fc3', N'Yume', N'Mirai', N'Nijino', N'/uploads/Yume.png', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (7, N'neko', N'96d05fd5e74bcf6d1d0249a863954f', N'neko', N'neko', N'neko', N'/uploads/neko.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (8, N'trufflesky', N'26b91752fb9549c9e6f8ff5f5dfb0b', N'Xylee Pearl', N'Seprado', N'Bagsican', N'/uploads/trufflesky.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (9, N'bryan', N'4ef62de50874a4db33e6da3ff79f75', N'Bryan Jhons', N'Arado', N'Garces', N'/uploads/bryan.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (10, N'Jayson20', N'7ccb0eea8a706c4c34a16891f84e7b', N'Jayson', N'Princillo', N'Rojo', N'/uploads/Jayson20.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (11, N'Yukinos', N'admin', N'Yukino', N'Yukinoshita', N'Hachiman', N'/uploads/Yukinos.png', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [status]) VALUES (12, N'ellamae', N'3f2b0a4d2e0e7b3f6795bb1ccdf87a', N'Ella Mae', N'Avila', N'Montilla', N'/uploads/ellamae.jpg', N'Active')
SET IDENTITY_INSERT [dbo].[user] OFF
SET IDENTITY_INSERT [dbo].[workspace] ON 

INSERT [dbo].[workspace] ([wspaceId], [title], [created], [status]) VALUES (1, N'HRIS', N'9', N'Active')
INSERT [dbo].[workspace] ([wspaceId], [title], [created], [status]) VALUES (2, N'Pado IT', N'1', N'Active')
SET IDENTITY_INSERT [dbo].[workspace] OFF
SET IDENTITY_INSERT [dbo].[wspacemember] ON 

INSERT [dbo].[wspacemember] ([wmemId], [wspaceId], [userId]) VALUES (1, 1, 1)
INSERT [dbo].[wspacemember] ([wmemId], [wspaceId], [userId]) VALUES (2, 1, 3)
SET IDENTITY_INSERT [dbo].[wspacemember] OFF
USE [master]
GO
ALTER DATABASE [PMIS] SET  READ_WRITE 
GO
