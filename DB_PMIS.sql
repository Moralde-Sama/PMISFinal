USE [master]
GO
/****** Object:  Database [PMIS]    Script Date: 8/25/2018 11:16:50 AM ******/
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
/****** Object:  User [pmis]    Script Date: 8/25/2018 11:16:56 AM ******/
CREATE USER [pmis] FOR LOGIN [pmis] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [pmis]
GO
/****** Object:  StoredProcedure [dbo].[spGetParticipants]    Script Date: 8/25/2018 11:16:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetParticipants]

as

begin
	SELECT
	p.projId,
	u.userId,
	CONCAT(u.firstname, ' ', u.lastname) as 'fullname',
	u.profpath
	FROM participant as p
	INNER JOIN [user] as u on u.userId = p.userId
	INNER JOIN project as pr on pr.projId = p.projId
end


GO
/****** Object:  StoredProcedure [dbo].[spGetParticipantsByProj]    Script Date: 8/25/2018 11:16:58 AM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjList]    Script Date: 8/25/2018 11:16:58 AM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjTask]    Script Date: 8/25/2018 11:16:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetProjTask]

	@projId int = null

as

begin

SELECT
	t.taskId,
	t.status,
	t.title,
	CONCAT(u.firstname, ' ' ,SUBSTRING(u.middlename, 1, 1), '. ' ,  u.lastname) as 'fullname',
	u.profpath,
	t.description
FROM task as t
INNER JOIN [user] as u ON u.userId = t.assignto
WHERE t.projId = @projId
ORDER BY case t.status when 'Available' then 1
					   when 'Pending' then 2
					   when 'Completed' then 3 end asc

end
GO
/****** Object:  StoredProcedure [dbo].[spgetTaskLog]    Script Date: 8/25/2018 11:16:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spgetTaskLog]

@taskId int = null

as

begin 

SELECT
	tl.taskId,
	tl.logcontent,
	tl.date,
	u.userId,
	CONCAT(u.firstname, ' ', u.lastname) as 'fullname',
	u2.userId as 'userId2',
	CONCAT(u2.firstname, ' ', u2.lastname) as 'fullname2'

FROM tasklog as tl
	INNER JOIN [user] as u2 ON tl.assignto = u2.userId
	INNER JOIN task as t ON t.taskId = tl.taskId
	INNER JOIN [user] as u ON t.createdby = u.userId
WHERE
	tl.taskId = @taskId
GROUP BY
	tl.taskId,
	tl.logcontent,
	tl.date,
	u.userId, u.firstname, u.lastname, u2.firstname, u2.lastname, u.userId, u2.userId
ORDER BY
	tl.date desc

end
GO
/****** Object:  StoredProcedure [dbo].[spGetUserTask]    Script Date: 8/25/2018 11:16:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spGetUserTask]

@userId int = null

as

begin
	SELECT
		t.taskId,
		t.projId,
		t.status,
		t.title,
		u.userId,
		CONCAT(u.firstname, ' ' ,SUBSTRING(u.middlename, 1, 1), '. ' ,  u.lastname) as 'fullname',
		u.profpath,
		t.description
	FROM task as t
	INNER JOIN [user] as u ON u.userId = t.assignto
	WHERE t.assignto = @userId
	ORDER BY case t.status when 'Available' then 1
						   when 'Pending' then 2
						   when 'Completed' then 3 end asc
end
GO
/****** Object:  StoredProcedure [dbo].[spProjectDetails]    Script Date: 8/25/2018 11:16:58 AM ******/
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
	p.userId,
	CONCAT(u.lastname, ', ', SUBSTRING(u.firstname, 1, 1), SUBSTRING(u.middlename, 1, 1)) as 'creator',
	p.version,
	p.lastupdated,
	p.createddate,
	p.projId as 'Percentage'

FROM project as p
INNER JOIN [user] as u ON u.userId = p.userId
WHERE p.projId = @projId
end
GO
/****** Object:  StoredProcedure [dbo].[spUserProjectList]    Script Date: 8/25/2018 11:16:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spUserProjectList]

@userId int = null

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
	INNER JOIN participant as pp ON pp.userId = @userId AND pp.projId = p.projId

	group by p.title, p.[status], p.projId, u.lastname, u.firstname, u.middlename
	order by p.title

end
GO
/****** Object:  Table [dbo].[participant]    Script Date: 8/25/2018 11:16:58 AM ******/
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
/****** Object:  Table [dbo].[projecmessage]    Script Date: 8/25/2018 11:16:58 AM ******/
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
/****** Object:  Table [dbo].[project]    Script Date: 8/25/2018 11:16:58 AM ******/
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
	[lastupdated] [varchar](50) NOT NULL,
	[version] [varchar](50) NOT NULL,
	[status] [varchar](50) NOT NULL,
	[createddate] [varchar](50) NOT NULL,
	[enddate] [varchar](50) NULL,
 CONSTRAINT [PK_project] PRIMARY KEY CLUSTERED 
(
	[projId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[task]    Script Date: 8/25/2018 11:16:58 AM ******/
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
	[startdate] [datetime] NOT NULL,
	[enddate] [varchar](50) NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_task] PRIMARY KEY CLUSTERED 
(
	[taskId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[tasklog]    Script Date: 8/25/2018 11:16:58 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[tasklog](
	[tasklogId] [int] IDENTITY(1,1) NOT NULL,
	[taskId] [int] NOT NULL,
	[logcontent] [varchar](100) NOT NULL,
	[date] [datetime] NOT NULL,
	[assignto] [int] NOT NULL,
 CONSTRAINT [PK_tasklog] PRIMARY KEY CLUSTERED 
(
	[tasklogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[user]    Script Date: 8/25/2018 11:16:58 AM ******/
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
	[profpath] [varchar](max) NOT NULL,
	[coverpath] [varchar](max) NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[participant] ON 

INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (16, 16, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (17, 16, 9)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (18, 16, 10)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (19, 16, 12)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (20, 17, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (21, 18, 3)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (22, 19, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (23, 19, 8)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (24, 19, 9)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (25, 19, 10)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (26, 19, 12)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (27, 19, 7)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (32, 21, 3)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (33, 21, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (34, 21, 10)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (35, 21, 8)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (36, 21, 7)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (37, 22, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (38, 22, 3)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (39, 22, 6)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (40, 23, 1)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (41, 23, 3)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (42, 23, 6)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (43, 23, 7)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (44, 23, 8)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (45, 23, 9)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (46, 23, 10)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (47, 23, 11)
INSERT [dbo].[participant] ([partId], [projId], [userId]) VALUES (48, 23, 12)
SET IDENTITY_INSERT [dbo].[participant] OFF
SET IDENTITY_INSERT [dbo].[project] ON 

INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (16, N'Garces Gaming', 1, N'Friday, 03 August 2018 10:41 AM', N'1.1', N'Active', N'Friday, 03 August 2018 10:41 AM', NULL)
INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (17, N'PMIS', 1, N'Friday, 03 August 2018 10:42 AM', N'1', N'Active', N'Friday, 03 August 2018 10:42 AM', NULL)
INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (18, N'Project Bang Dream!', 3, N'Saturday, 04 August 2018 09:29 AM', N'1', N'Active', N'Saturday, 04 August 2018 09:29 AM', NULL)
INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (19, N'Project Management Information System', 1, N'Saturday, 04 August 2018 09:34 AM', N'1', N'Active', N'Saturday, 04 August 2018 09:34 AM', NULL)
INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (21, N'SDF', 3, N'Saturday, 04 August 2018 02:34 PM', N'1', N'Active', N'Saturday, 04 August 2018 02:34 PM', NULL)
INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (22, N'new', 1, N'Thursday, 09 August 2018 10:28 AM', N'1', N'Active', N'Thursday, 09 August 2018 10:28 AM', NULL)
INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (23, N'asd', 1, N'Thursday, 09 August 2018 10:29 AM', N'asd', N'Active', N'Thursday, 09 August 2018 10:29 AM', NULL)
SET IDENTITY_INSERT [dbo].[project] OFF
SET IDENTITY_INSERT [dbo].[task] ON 

INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (1, 19, N'Login Form', N'design ug function', 1, 1, CAST(0x0000A944008D05ED AS DateTime), NULL, N'Completed')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (2, 16, N'Create Button', N'Pag design lang', 1, 10, CAST(0x0000A944008698DC AS DateTime), NULL, N'Available')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (3, 21, N'Create Login Form', N'Design lang', 3, 1, CAST(0x0000A94400C3BE10 AS DateTime), NULL, N'Pending')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (4, 23, N'sdf', N'sdf', 1, 9, CAST(0x0000A94600B17072 AS DateTime), NULL, N'Available')
SET IDENTITY_INSERT [dbo].[task] OFF
SET IDENTITY_INSERT [dbo].[tasklog] ON 

INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (1, 1, N'created the task', CAST(0x0000A9420152FCDE AS DateTime), 12)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (2, 1, N'assigned task to', CAST(0x0000A9420152FCE6 AS DateTime), 12)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (3, 1, N'assigned task to', CAST(0x0000A94300C3C5AA AS DateTime), 9)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (4, 1, N'assigned task to', CAST(0x0000A94300E9B98F AS DateTime), 12)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (5, 2, N'created the task', CAST(0x0000A944007CC3F7 AS DateTime), 10)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (6, 2, N'assigned task to', CAST(0x0000A944007CC416 AS DateTime), 10)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (7, 2, N'assigned task to', CAST(0x0000A94400865474 AS DateTime), 12)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (8, 2, N'assigned task to', CAST(0x0000A94400867EA0 AS DateTime), 9)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (9, 2, N'assigned task to', CAST(0x0000A94400868B64 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (10, 2, N'assigned task to', CAST(0x0000A944008698DD AS DateTime), 10)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (11, 1, N'assigned task to', CAST(0x0000A944008D0620 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (12, 3, N'created the task', CAST(0x0000A94400C3BE69 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (13, 3, N'assigned task to', CAST(0x0000A94400C3BE6C AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (14, 3, N'submitted the task', CAST(0x0000A94400F665F4 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (15, 3, N'canceled the submission', CAST(0x0000A9440148C5A4 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (16, 3, N'canceled the submission', CAST(0x0000A944014A7DC6 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (17, 3, N'canceled the submission', CAST(0x0000A944014B0E46 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (18, 3, N'canceled the submission', CAST(0x0000A944014B1990 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (19, 3, N'submitted the task', CAST(0x0000A944014BA5B5 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (20, 3, N'canceled the submission', CAST(0x0000A944014C25FE AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (21, 3, N'canceled the submission', CAST(0x0000A944014C9362 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (22, 3, N'submitted the task', CAST(0x0000A944014C9D76 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (23, 3, N'canceled the submission', CAST(0x0000A944014DA2EA AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (24, 3, N'submitted the task', CAST(0x0000A944014DBA05 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (25, 3, N'canceled the submission', CAST(0x0000A944014DE0D0 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (26, 3, N'submitted the task', CAST(0x0000A944014E0706 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (27, 3, N'canceled the submission', CAST(0x0000A944014F12D6 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (28, 3, N'submitted the task', CAST(0x0000A944014F2D6E AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (29, 3, N'canceled the submission', CAST(0x0000A944014F74C4 AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (30, 3, N'submitted the task', CAST(0x0000A944014F782D AS DateTime), 1)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (31, 4, N'created the task', CAST(0x0000A94600B1709E AS DateTime), 9)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (32, 4, N'assigned task to', CAST(0x0000A94600B170A0 AS DateTime), 9)
SET IDENTITY_INSERT [dbo].[tasklog] OFF
SET IDENTITY_INSERT [dbo].[user] ON 

INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (1, N'admin', N'232f297a57a5a743894a0e4a801fc3', N'Emmanuel Paul', N'Gabionza', N'Moralde', N'/uploads/admin_pp_08_25_2018_11_13_15.png', N'/uploads/admin_cv_08_25_2018_11_10_44.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (3, N'Kasumeme', N'232f297a57a5a743894a0e4a801fc3', N'Kasumi', N'Yuki', N'Toyama', N'/uploads/Kasumeme.jpg', N'/uploads/default_cover.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (6, N'Yume', N'232f297a57a5a743894a0e4a801fc3', N'Yume', N'Mirai', N'Nijino', N'/uploads/Yume.png', N'/uploads/default_cover.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (7, N'neko', N'96d05fd5e74bcf6d1d0249a863954f', N'neko', N'neko', N'neko', N'/uploads/neko.jpg', N'/uploads/default_cover.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (8, N'trufflesky', N'26b91752fb9549c9e6f8ff5f5dfb0b', N'Xylee Pearl', N'Seprado', N'Bagsican', N'/uploads/trufflesky.jpg', N'/uploads/default_cover.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (9, N'bryan', N'4ef62de50874a4db33e6da3ff79f75', N'Bryan Jhons', N'Arado', N'Garces', N'/uploads/bryan.jpg', N'/uploads/default_cover.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (10, N'Jayson20', N'7ccb0eea8a706c4c34a16891f84e7b', N'Jayson', N'Princillo', N'Rojo', N'/uploads/Jayson20.jpg', N'/uploads/default_cover.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (11, N'Yukinos', N'232f297a57a5a743894a0e4a801fc3', N'Yukino', N'Yukinoshita', N'Hachiman', N'/uploads/Yukinos.png', N'/uploads/default_cover.jpg', N'Active')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [status]) VALUES (12, N'ellamae', N'3f2b0a4d2e0e7b3f6795bb1ccdf87a', N'Ella Mae', N'Avila', N'Montilla', N'/uploads/ellamae.jpg', N'/uploads/default_cover.jpg', N'Active')
SET IDENTITY_INSERT [dbo].[user] OFF
USE [master]
GO
ALTER DATABASE [PMIS] SET  READ_WRITE 
GO
