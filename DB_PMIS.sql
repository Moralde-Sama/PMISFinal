USE [master]
GO
/****** Object:  Database [PMIS]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  User [pmis]    Script Date: 9/6/2018 1:40:03 PM ******/
CREATE USER [pmis] FOR LOGIN [pmis] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [pmis]
GO
/****** Object:  StoredProcedure [dbo].[spgetAllUserTask]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetParticipants]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetParticipantsByProj]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjectActivity]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjList]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjTask]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spgetTaskLog]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetUserTask]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spgetUserTaskCount]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spProjectDetails]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spProjectStatCount]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spUserProjectList]    Script Date: 9/6/2018 1:40:03 PM ******/
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
	COUNT(t.taskId) as "Completed"

	FROM project as p

	INNER JOIN [user] as u ON u.userId = p.userId
	LEFT JOIN task as t ON t.projId = p.projId AND t.[status] = 'Completed'
	INNER JOIN participant as pp ON pp.userId = @userId AND pp.projId = p.projId AND pp.status = 'Active'

	group by p.title, p.[status], p.projId, u.lastname, u.firstname, u.middlename
	order by p.title

end
GO
/****** Object:  Table [dbo].[notification]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  Table [dbo].[participant]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  Table [dbo].[projecmessage]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  Table [dbo].[project]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  Table [dbo].[projectactivity]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  Table [dbo].[task]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  Table [dbo].[tasklog]    Script Date: 9/6/2018 1:40:03 PM ******/
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
/****** Object:  Table [dbo].[user]    Script Date: 9/6/2018 1:40:03 PM ******/
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
 CONSTRAINT [PK_user] PRIMARY KEY CLUSTERED 
(
	[userId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
SET IDENTITY_INSERT [dbo].[notification] ON 

INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (1, 3, N'Task', N'Emmanuel Paul Moralde assigned you a task in Project Management Information System Project', CAST(0x0000A95200A4394E AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (2, 1, N'Task', N'Kasumi Toyama2 finished the task in Project Management Information System Project', CAST(0x0000A95200A46BCF AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (7, 3, N'Project', N'Emmanuel Paul Moralde added you in Garces Gaming Project', CAST(0x0000A953008EA275 AS DateTime), 6, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (8, 9, N'Project', N'Emmanuel Paul Moralde added you in Garces Gaming Project', CAST(0x0000A953008EA3A6 AS DateTime), 6, 0, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (14, 3, N'Task', N'Emmanuel Paul Moralde assigned you a task in Project Management Information System Project', CAST(0x0000A95300A7AAA1 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (15, 1, N'Task', N'Kasumi Toyama2 finished the task in Project Management Information System Project', CAST(0x0000A95300A7C2A9 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (16, 3, N'Task', N'Emmanuel Paul Moralde returned your task in Project Management Information System Project', CAST(0x0000A95300A7F484 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (17, 1, N'Task', N'Kasumi Toyama2 finished the task in Project Management Information System Project', CAST(0x0000A95300A80F7A AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (18, 3, N'Task', N'Emmanuel Paul Moralde approved the submission of your task in Project Management Information System Project', CAST(0x0000A95300A83007 AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (19, 7, N'Project', N'Emmanuel Paul Moralde added you in Project Management Information System Project', CAST(0x0000A95300D67EA1 AS DateTime), 1, 0, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (20, 7, N'Project', N'Emmanuel Paul Moralde added you in Project Management Information System Project', CAST(0x0000A95300D6E3A1 AS DateTime), 1, 0, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (21, 7, N'Project', N'Emmanuel Paul Moralde added you in Project Management Information System Project', CAST(0x0000A95300D88A51 AS DateTime), 1, 0, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (22, 3, N'Project', N'Emmanuel Paul Moralde added you in Project Management Information System Project', CAST(0x0000A95300DF416A AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (23, 3, N'Project', N'Emmanuel Paul Moralde added you in Project Management Information System Project', CAST(0x0000A95300DFE59C AS DateTime), 1, 1, N'New')
INSERT [dbo].[notification] ([notifId], [userId], [type], [notifcontent], [date], [id], [seen], [status]) VALUES (24, 3, N'Project', N'Emmanuel Paul Moralde removed you in Project Management Information System Project', CAST(0x0000A95300E02244 AS DateTime), 1, 1, N'New')
SET IDENTITY_INSERT [dbo].[notification] OFF
SET IDENTITY_INSERT [dbo].[participant] ON 

INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (1, 1, 1, N'Active')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (2, 1, 3, N'Removed')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (5, 1, 7, N'Removed')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (6, 1, 12, N'Active')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (7, 1, 9, N'Active')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (8, 1, 10, N'Active')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (13, 6, 1, N'Active')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (21, 6, 3, N'Active')
INSERT [dbo].[participant] ([partId], [projId], [userId], [status]) VALUES (22, 6, 9, N'Active')
SET IDENTITY_INSERT [dbo].[participant] OFF
SET IDENTITY_INSERT [dbo].[project] ON 

INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (1, N'Project Management Information System', 1, N'Thursday, 06 September 2018 10:12 AM', N'1', N'Active', N'Wednesday, 05 September 2018 09:44 AM', NULL)
INSERT [dbo].[project] ([projId], [title], [userId], [lastupdated], [version], [status], [createddate], [enddate]) VALUES (6, N'Garces Gaming', 1, N'Wednesday, 05 September 2018 11:19 AM', N'1', N'Active', N'Wednesday, 05 September 2018 11:19 AM', NULL)
SET IDENTITY_INSERT [dbo].[project] OFF
SET IDENTITY_INSERT [dbo].[projectactivity] ON 

INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (1, 1, 1, N'created a task and assign to', CAST(0x0000A95200A4393F AS DateTime), 3, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (2, 1, 1, N'finished the task.', CAST(0x0000A95200A46BCA AS DateTime), 3, N'Pending')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (3, 1, 1, N'approved the submission of', CAST(0x0000A95200A49147 AS DateTime), 3, N'Completed')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (4, 1, 2, N'created a task and assign to', CAST(0x0000A95300A7AA6B AS DateTime), 3, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (5, 1, 2, N'finished the task.', CAST(0x0000A95300A7C2A4 AS DateTime), 3, N'Pending')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (6, 1, 2, N'returned the task of', CAST(0x0000A95300A7F477 AS DateTime), 3, N'Available')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (7, 1, 2, N'finished the task.', CAST(0x0000A95300A80F76 AS DateTime), 3, N'Pending')
INSERT [dbo].[projectactivity] ([activityId], [projId], [taskId], [logContent], [datetime], [assignto], [status]) VALUES (8, 1, 2, N'approved the submission of', CAST(0x0000A95300A82FF5 AS DateTime), 3, N'Completed')
SET IDENTITY_INSERT [dbo].[projectactivity] OFF
SET IDENTITY_INSERT [dbo].[task] ON 

INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (1, 1, N'asdf', N'asd', 1, 3, CAST(0x0000A95200A49144 AS DateTime), NULL, N'Completed')
INSERT [dbo].[task] ([taskId], [projId], [title], [description], [createdby], [assignto], [startdate], [enddate], [status]) VALUES (2, 1, N'Jajajajaja', N'Hou', 1, 3, CAST(0x0000A95300A82FF4 AS DateTime), NULL, N'Completed')
SET IDENTITY_INSERT [dbo].[task] OFF
SET IDENTITY_INSERT [dbo].[tasklog] ON 

INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (1, 1, N'created the task', CAST(0x0000A95200A43941 AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (2, 1, N'assigned task to', CAST(0x0000A95200A43944 AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (3, 1, N'finished the task', CAST(0x0000A95200A46BCA AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (4, 1, N'approved the submission', CAST(0x0000A95200A49149 AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (5, 2, N'created the task', CAST(0x0000A95300A7AA6F AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (6, 2, N'assigned task to', CAST(0x0000A95300A7AA7E AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (7, 2, N'finished the task', CAST(0x0000A95300A7C2A3 AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (8, 2, N'returned your task', CAST(0x0000A95300A7F478 AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (9, 2, N'finished the task', CAST(0x0000A95300A80F75 AS DateTime), 3)
INSERT [dbo].[tasklog] ([tasklogId], [taskId], [logcontent], [date], [assignto]) VALUES (10, 2, N'approved the submission', CAST(0x0000A95300A82FF6 AS DateTime), 3)
SET IDENTITY_INSERT [dbo].[tasklog] OFF
SET IDENTITY_INSERT [dbo].[user] ON 

INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (1, N'admin', N'232f297a57a5a743894a0e4a801fc3', N'Emmanuel Paul', N'Gabionza', N'Moralde', N'/uploads/admin_pp_09_01_2018_07_50_43.png', N'/uploads/admin_cv_09_01_2018_07_50_59.jpg', N'ac7531f9-cc0e-4958-a2ad-d3893c462462', N'offline')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (3, N'Kasumeme', N'232f297a57a5a743894a0e4a801fc3', N'Kasumi', N'Yuki2', N'Toyama2', N'/uploads/Kasumeme_pp_09_05_2018_10_02_15.png', N'/uploads/Kasumeme_cv_08_27_2018_07_27_25cover.jpg', N'05a7e1fc-d9c7-493a-948a-65a540f797fd', N'online')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (6, N'Yume', N'232f297a57a5a743894a0e4a801fc3', N'Yume', N'Mirai', N'Nijino', N'/uploads/Yume.png', N'/uploads/defaultcover.jpg', NULL, N'offline')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (7, N'neko', N'96d05fd5e74bcf6d1d0249a863954f', N'neko', N'neko', N'neko', N'/uploads/neko.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (8, N'trufflesky', N'26b91752fb9549c9e6f8ff5f5dfb0b', N'Xylee Pearl', N'Seprado', N'Bagsican', N'/uploads/trufflesky.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (9, N'bryan', N'4ef62de50874a4db33e6da3ff79f75', N'Bryan Jhons', N'Arado', N'Garces', N'/uploads/bryan.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (10, N'Jayson20', N'7ccb0eea8a706c4c34a16891f84e7b', N'Jayson', N'Princillo', N'Rojo', N'/uploads/Jayson20.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (11, N'Yukinos', N'232f297a57a5a743894a0e4a801fc3', N'Yukino', N'Yukinoshita', N'Hachiman', N'/uploads/Yukinos.png', N'/uploads/defaultcover.jpg', N'1ac9d931-c03f-406e-a7db-492952e58470', N'offline')
INSERT [dbo].[user] ([userId], [username], [password], [firstname], [middlename], [lastname], [profpath], [coverpath], [connectionid], [status]) VALUES (12, N'ellamae', N'3f2b0a4d2e0e7b3f6795bb1ccdf87a', N'Ella Mae', N'Avila', N'Montilla', N'/uploads/ellamae.jpg', N'/uploads/defaultcover.jpg', NULL, N'offline')
SET IDENTITY_INSERT [dbo].[user] OFF
ALTER TABLE [dbo].[notification] ADD  CONSTRAINT [DF_notification_seen]  DEFAULT ((0)) FOR [seen]
GO
ALTER TABLE [dbo].[participant] ADD  CONSTRAINT [DF_participant_status]  DEFAULT ('Active') FOR [status]
GO
USE [master]
GO
ALTER DATABASE [PMIS] SET  READ_WRITE 
GO
