USE [master]
GO
/****** Object:  Database [PMIS]    Script Date: 9/16/2018 8:21:25 PM ******/
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
/****** Object:  User [pmis]    Script Date: 9/16/2018 8:21:25 PM ******/
CREATE USER [pmis] FOR LOGIN [pmis] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [pmis]
GO
/****** Object:  StoredProcedure [dbo].[spgetAllUserTask]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spgetAllUserTask]

@userId int = null

as

begin

SELECT
	t.taskId,
	t.status,
	p.title as 'Project',
	t.title as 'Task'
FROM task as t
INNER JOIN project as p ON p.projId = t.projId
WHERE t.assignto = @userId
GROUP BY p.title, t.taskId, t.status, p.title, t.title
ORDER BY case t.status when 'Available' then 1
					   when 'Pending' then 2
					   when 'Completed' then 3 end asc

end
GO
/****** Object:  StoredProcedure [dbo].[spGetParticipants]    Script Date: 9/16/2018 8:21:25 PM ******/
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
	u.profpath,
	p.status
	FROM participant as p
	INNER JOIN [user] as u on u.userId = p.userId
	INNER JOIN project as pr on pr.projId = p.projId
end


GO
/****** Object:  StoredProcedure [dbo].[spGetParticipantsByProj]    Script Date: 9/16/2018 8:21:25 PM ******/
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
		u.coverpath,
		COUNT(p.userId) as 'creator',
		u.firstname as 'position'
	
	FROM participant as pp
	INNER JOIN [user] as u ON u.userId = pp.userId
	LEFT JOIN project as p ON p.projId = pp.projId AND p.userId = u.userId
	WHERE pp.projId = @projId AND pp.status = 'Active'

	group by u.userId, u.firstname, u.middlename, u.lastname, u.profpath, u.coverpath
	ORDER BY creator desc, fullname asc
END
GO
/****** Object:  StoredProcedure [dbo].[spGetProjectActivity]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetProjectActivity]

@projId int = null

as

begin

SELECT 
	pa.status,
	t.title,
	pa.datetime,
	pa.logContent,
	u1.userId,
	CONCAT(u1.firstname, ' ', u1.lastname) as 'fullname',
	u2.userId as 'userId2',
	CONCAT(u2.firstname, ' ', u2.lastname) as 'fullname2'

FROM projectactivity as pa
INNER JOIN task as t ON t.taskId = pa.taskId
INNER JOIN [user] as u1 ON u1.userId = t.createdby
INNER JOIN [user] as u2 ON u2.userId = pa.assignto
WHERE pa.projId = @projId
ORDER BY pa.datetime desc

end
GO
/****** Object:  StoredProcedure [dbo].[spGetProjList]    Script Date: 9/16/2018 8:21:25 PM ******/
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
	COUNT(t.taskId) as Completed,
	COUNT(t2.taskId) as Pending,
	COUNT(t3.taskId) as Available

	FROM project as p

	INNER JOIN [user] as u ON u.userId = p.userId
	LEFT JOIN task as t ON t.projId = p.projId AND t.[status] = 'Completed'
	LEFT JOIN task as t2 ON t2.projId = p.projId AND t2.[status] = 'Pending'
	LEFT JOIN task as t3 ON t3.projId = p.projId AND t3.[status] = 'Available'
	
	group by p.title, p.[status], p.projId, u.lastname, u.firstname, u.middlename
	order by p.title
end
GO
/****** Object:  StoredProcedure [dbo].[spGetProjTask]    Script Date: 9/16/2018 8:21:25 PM ******/
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
	u.userId,
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
/****** Object:  StoredProcedure [dbo].[spgetTaskLog]    Script Date: 9/16/2018 8:21:25 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spgetuseractivites]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[spgetuseractivites]

@userId int = null

as

begin

SELECT 
	ua.*,
	CONCAT(u.firstname, ' ', u.lastname) as 'Fullname',
	p.title as 'projTitle',
	t.title as 'taskTitle'

FROM useractivities as ua
LEFT JOIN [user] as u ON u.userId = ua.assignto
LEFT JOIN project as p ON p.projId = ua.id
LEFT JOIN task as t ON t.taskId = ua.taskId
WHERE ua.userId = @userId
ORDER BY ua.date desc

end
GO
/****** Object:  StoredProcedure [dbo].[spGetUserTask]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spGetUserTask]

@projId int = null,
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
	WHERE t.assignto = @userId AND t.projId = @projId
	ORDER BY case t.status when 'Available' then 1
						   when 'Pending' then 2
						   when 'Completed' then 3 end asc
end
GO
/****** Object:  StoredProcedure [dbo].[spgetUserTaskCount]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[spgetUserTaskCount]

@userId int = null

as

begin

SELECT
	COUNT(t.status) as 'Completed',
	COUNT(t2.status) as 'Pending',
	COUNT(t2.status) as 'Available'
FROM [user] as u
LEFT JOIN task as t ON t.assignto = u.userId AND t.status = 'Completed'
LEFT JOIN task as t1 ON t.assignto = u.userId AND t1.status = 'Pending'
LEFT JOIN task as t2 ON t.assignto = u.userId AND t2.status = 'Available'
WHERE u.userId = @userId

end
GO
/****** Object:  StoredProcedure [dbo].[spProjectDetails]    Script Date: 9/16/2018 8:21:25 PM ******/
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
	0 as 'Percentage',
	0 as 'Percentage2',
	0 as 'Percentage3',
	0 as 'Completed',
	0 as 'Pending',
	0 as 'Available'

FROM project as p
INNER JOIN [user] as u ON u.userId = p.userId
WHERE p.projId = @projId
end
GO
/****** Object:  StoredProcedure [dbo].[spProjectStatCount]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[spProjectStatCount]

@userId int = null

as

begin

SELECT 
	COUNT(p2.status) as 'Completed',
	COUNT(p3.status) as 'Active',
	COUNT(p4.status) as 'Cancelled'
FROM participant as pp
LEFT JOIN project as p2 ON pp.projId = p2.projId AND p2.status = 'Completed'
LEFT JOIN project as p3 ON pp.projId = p3.projId AND p3.status = 'Active'
LEFT JOIN project as p4 ON pp.projId = p4.projId AND p4.status = 'Cancelled'
WHERE pp.userId = @userId

end
GO
/****** Object:  StoredProcedure [dbo].[spUserProjectList]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[spUserProjectList]

@userId int = null

as

begin

SELECT 
	p.projId,
	p.[status],
	p.title,
	CONCAT(u.lastname, ', ', SUBSTRING(u.firstname, 1, 1), SUBSTRING(u.middlename, 1, 1)) as 'creator',
	COUNT(t.taskId) as Completed,
	COUNT(t2.taskId) as Pending,
	COUNT(t3.taskId) as Available

	FROM project as p

	INNER JOIN [user] as u ON u.userId = p.userId
	LEFT JOIN task as t ON t.projId = p.projId AND t.[status] = 'Completed'
	LEFT JOIN task as t2 ON t2.projId = p.projId AND t2.[status] = 'Pending'
	LEFT JOIN task as t3 ON t3.projId = p.projId AND t3.[status] = 'Available'
	INNER JOIN participant as pp ON pp.userId = @userId AND pp.projId = p.projId AND pp.status = 'Active'

	group by p.title, p.[status], p.projId, u.lastname, u.firstname, u.middlename
	order by p.title

end
GO
/****** Object:  Table [dbo].[notification]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[notification](
	[notifId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[notifcontent] [varchar](max) NOT NULL,
	[date] [datetime] NOT NULL,
	[id] [int] NOT NULL,
	[seen] [tinyint] NOT NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_notification] PRIMARY KEY CLUSTERED 
(
	[notifId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[participant]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[participant](
	[partId] [int] IDENTITY(1,1) NOT NULL,
	[projId] [int] NOT NULL,
	[userId] [int] NOT NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_participant] PRIMARY KEY CLUSTERED 
(
	[partId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[projecmessage]    Script Date: 9/16/2018 8:21:25 PM ******/
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
/****** Object:  Table [dbo].[project]    Script Date: 9/16/2018 8:21:25 PM ******/
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
/****** Object:  Table [dbo].[projectactivity]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[projectactivity](
	[activityId] [int] IDENTITY(1,1) NOT NULL,
	[projId] [int] NOT NULL,
	[taskId] [int] NOT NULL,
	[logContent] [varchar](200) NOT NULL,
	[datetime] [datetime] NOT NULL,
	[assignto] [int] NOT NULL,
	[status] [varchar](50) NOT NULL,
 CONSTRAINT [PK_projectactivity] PRIMARY KEY CLUSTERED 
(
	[activityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[task]    Script Date: 9/16/2018 8:21:25 PM ******/
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
/****** Object:  Table [dbo].[tasklog]    Script Date: 9/16/2018 8:21:25 PM ******/
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
/****** Object:  Table [dbo].[user]    Script Date: 9/16/2018 8:21:25 PM ******/
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
	[coverpath] [varchar](max) NOT NULL,
	[connectionid] [varchar](200) NULL,
	[status] [varchar](50) NOT NULL,
	[role] [varchar](50) NULL,
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[useractivities]    Script Date: 9/16/2018 8:21:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[useractivities](
	[activityId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NOT NULL,
	[type] [varchar](50) NOT NULL,
	[actcontent] [varchar](max) NOT NULL,
	[date] [datetime] NOT NULL,
	[id] [int] NOT NULL,
	[taskId] [int] NULL,
	[assignto] [int] NULL,
 CONSTRAINT [PK_useractivities] PRIMARY KEY CLUSTERED 
(
	[activityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[notification] ON 

INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (1, 6, N'Project', N'Kasumi Toyama2 added you in Project Management Information System Project', CAST(0x0000A95B00EC9B64 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (2, 6, N'Task', N'Kasumi Toyama2 assigned you a task in Project Management Information System Project', CAST(0x0000A95B00ED5C51 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (3, 6, N'Task', N'Kasumi Toyama2 assigned you a task in Project Management Information System Project', CAST(0x0000A95C00C8C445 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (4, 6, N'Task', N'Kasumi Toyama2 assigned you a task in Project Management Information System Project', CAST(0x0000A95C00D3BF50 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (5, 6, N'Task', N'Kasumi Toyama2 assigned you a task in Project Management Information System Project', CAST(0x0000A95C00DC6733 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (6, 3, N'Task', N'Yume Nijino finished a task in Project Management Information System Project', CAST(0x0000A95C00F05131 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (7, 6, N'Task', N'Kasumi Toyama2 approved the submission of your task in Project Management Information System Project', CAST(0x0000A95C00F34C03 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (8, 6, N'Task', N'Kasumi Toyama2 returned your task in Project Management Information System Project', CAST(0x0000A95C00F41E93 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (9, 6, N'Task', N'Kasumi Toyama assigned you a task in Project Management Information System Project', CAST(0x0000A95D00A03E2F AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (10, 3, N'Task', N'Yume Nijino finished a task in Project Management Information System Project', CAST(0x0000A95D00F1AD67 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (11, 6, N'Task', N'Kasumi Toyama approved the submission of your task in Project Management Information System Project', CAST(0x0000A95D00F9086B AS DateTime), 1, 1, N'New')
SET IDENTITY_INSERT [dbo].[notification] OFF
SET IDENTITY_INSERT [dbo].[participant] ON 

INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (1, 1, 3, N'Active')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (2, 1, 6, N'Active')
SET IDENTITY_INSERT [dbo].[participant] OFF
SET IDENTITY_INSERT [dbo].[project] ON 

INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (1, N'Project Management Information System', 3, N'Sunday, 16 September 2018 03:06 PM', N'1.1', N'Active', N'Friday, 14 September 2018 02:21 PM', NULL)
SET IDENTITY_INSERT [dbo].[project] OFF
SET IDENTITY_INSERT [dbo].[projectactivity] ON 

INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (1, 1, 1, N'created a task and assign to', CAST(0x0000A95B00ED5C39 AS DateTime), 6, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (2, 1, 2, N'created a task and assign to', CAST(0x0000A95C00C8C411 AS DateTime), 6, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (3, 1, 3, N'created a task and assign to', CAST(0x0000A95C00D3BF39 AS DateTime), 6, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (4, 1, 4, N'created a task and assign to', CAST(0x0000A95C00DC6729 AS DateTime), 6, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (5, 1, 1, N'finished the task.', CAST(0x0000A95C00F0511A AS DateTime), 6, N'Pending')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (6, 1, 1, N'approved the submission of', CAST(0x0000A95C00F34BEF AS DateTime), 6, N'Completed')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (7, 1, 1, N'returned the task of', CAST(0x0000A95C00F41E8B AS DateTime), 6, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (8, 1, 5, N'created a task and assign to', CAST(0x0000A95D00A03E0B AS DateTime), 6, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (9, 1, 3, N'finished the task.', CAST(0x0000A95D00F1AD56 AS DateTime), 6, N'Pending')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (10, 1, 3, N'approved the submission of', CAST(0x0000A95D00F90864 AS DateTime), 6, N'Completed')
SET IDENTITY_INSERT [dbo].[projectactivity] OFF
SET IDENTITY_INSERT [dbo].[task] ON 

INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (1, 1, N'adf', N'asdf', 3, 6, CAST(0x0000A95C00F41E8A AS DateTime), NULL, N'Available')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (2, 1, N'hahaha', N'asd', 3, 6, CAST(0x0000A95C00C8C411 AS DateTime), NULL, N'Available')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (3, 1, N'hahahahahahaaha', N'hahaha', 3, 6, CAST(0x0000A95D00F90860 AS DateTime), NULL, N'Completed')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (4, 1, N'hahahahahahahaha', N'sdf', 3, 6, CAST(0x0000A95C00DC6729 AS DateTime), NULL, N'Available')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (5, 1, N'aaaaay', N'asdf', 3, 6, CAST(0x0000A95D00A03E0B AS DateTime), NULL, N'Available')
SET IDENTITY_INSERT [dbo].[task] OFF
SET IDENTITY_INSERT [dbo].[tasklog] ON 

INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (1, 1, N'created the task', CAST(0x0000A95B00ED5C46 AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (2, 1, N'assigned task to', CAST(0x0000A95B00ED5C48 AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (3, 2, N'created the task', CAST(0x0000A95C00C8C435 AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (4, 2, N'assigned task to', CAST(0x0000A95C00C8C437 AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (5, 3, N'created the task', CAST(0x0000A95C00D3BF3A AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (6, 3, N'assigned task to', CAST(0x0000A95C00D3BF3F AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (7, 4, N'created the task', CAST(0x0000A95C00DC672A AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (8, 4, N'assigned task to', CAST(0x0000A95C00DC672D AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (9, 1, N'finished the task', CAST(0x0000A95C00F05108 AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (10, 1, N'approved the submission', CAST(0x0000A95C00F34BF8 AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (11, 1, N'returned your task', CAST(0x0000A95C00F41E8E AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (12, 5, N'created the task', CAST(0x0000A95D00A03E1A AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (13, 5, N'assigned task to', CAST(0x0000A95D00A03E1D AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (14, 3, N'finished the task', CAST(0x0000A95D00F1AD4C AS DateTime), 6)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (15, 3, N'approved the submission', CAST(0x0000A95D00F90867 AS DateTime), 6)
SET IDENTITY_INSERT [dbo].[tasklog] OFF
SET IDENTITY_INSERT [dbo].[user] ON 

INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (1, N'admin', N'232f297a57a5a743894a0e4a801fc3', N'Emmanuel Paul', N'Gabionza', N'Moralde', N'/uploads/admin_pp_09_01_2018_07_50_43.png', N'/uploads/admin_cv_09_09_2018_07_54_51.jpg', N'2e85b2cd-3336-4ccd-9b2a-e36e8289ebde', N'offline', N'Super Admin')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (3, N'Kasumeme', N'232f297a57a5a743894a0e4a801fc3', N'Kasumi', N'Yuki', N'Toyama', N'/uploads/Kasumeme_pp_09_05_2018_10_02_15.png', N'/uploads/Kasumeme_cv_08_27_2018_07_27_25cover.jpg', N'7eb6930f-d00d-4faf-aeaa-fe90bbe2e9a8', N'online', N'User')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (6, N'Yume', N'232f297a57a5a743894a0e4a801fc3', N'Yume', N'Mirai', N'Nijino', N'/uploads/Yume.png', N'/uploads/defaultcover.jpg', N'a60040cf-af92-49c6-8e66-be65845c8d5c', N'offline', N'User')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (7, N'neko', N'96d05fd5e74bcf6d1d0249a863954f', N'neko', N'neko', N'neko', N'/uploads/neko.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline', N'User')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (8, N'trufflesky', N'26b91752fb9549c9e6f8ff5f5dfb0b', N'Xylee Pearl', N'Seprado', N'Bagsican', N'/uploads/trufflesky.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline', N'User')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (9, N'bryan', N'4ef62de50874a4db33e6da3ff79f75', N'Bryan Jhons', N'Arado', N'Garces', N'/uploads/bryan.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline', N'User')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (10, N'Jayson20', N'7ccb0eea8a706c4c34a16891f84e7b', N'Jayson', N'Princillo', N'Rojo', N'/uploads/Jayson20.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline', N'User')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (11, N'Yukinos', N'232f297a57a5a743894a0e4a801fc3', N'Yukino', N'Yukinoshita', N'Hachiman', N'/uploads/Yukinos.png', N'/uploads/defaultcover.jpg', N'46f1a687-c783-4053-9f21-ad0f58db3879', N'offline', N'User')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status], [role]) VALUES (12, N'ellamae', N'3f2b0a4d2e0e7b3f6795bb1ccdf87a', N'Ella Mae', N'Avila', N'Montilla', N'/uploads/ellamae.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline', N'User')
SET IDENTITY_INSERT [dbo].[user] OFF
SET IDENTITY_INSERT [dbo].[useractivities] ON 

INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (1, 3, N'Project', N'You created a project named Project Management Information System', CAST(0x0000A95B00EC9B5B AS DateTime), 1, 1, NULL)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (2, 3, N'Task', N'You created a task and assign to', CAST(0x0000A95C00C8C438 AS DateTime), 1, 2, 6)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (3, 3, N'Task', N'You created a task and assign to', CAST(0x0000A95C00D3BF40 AS DateTime), 1, 3, 6)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (4, 3, N'Task', N'You created a task and assign to', CAST(0x0000A95C00DC672E AS DateTime), 1, 4, 6)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (5, 6, N'Task', N'You finished the task', CAST(0x0000A95C00F05108 AS DateTime), 1, 4, NULL)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (6, 3, N'Task', N'You approved the submission of', CAST(0x0000A95C00F34BEE AS DateTime), 1, 4, 6)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (7, 3, N'Task', N'You returned the task of', CAST(0x0000A95C00F41E8B AS DateTime), 1, 4, 6)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (8, 3, N'Task', N'You created a task and assign to', CAST(0x0000A95D00A03E1E AS DateTime), 1, 5, 6)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (9, 6, N'Task', N'You finished the task ', CAST(0x0000A95D00F1AD4C AS DateTime), 1, 3, NULL)
INSERT [dbo].[useractivities] ([activityId], [userId], [type], [actcontent], [date], [id], [taskId], [assignto]) VALUES (10, 3, N'Task', N'You approved the submission of ', CAST(0x0000A95D00F90864 AS DateTime), 1, 3, 6)
SET IDENTITY_INSERT [dbo].[useractivities] OFF
ALTER TABLE [dbo].[notification] ADD  CONSTRAINT [DF_notification_seen]  DEFAULT ((0)) FOR [seen]
GO
ALTER TABLE [dbo].[participant] ADD  CONSTRAINT [DF_participant_status]  DEFAULT ('Active') FOR [status]
GO
USE [master]
GO
ALTER DATABASE [PMIS] SET  READ_WRITE 
GO
