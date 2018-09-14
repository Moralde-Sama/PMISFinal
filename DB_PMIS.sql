USE [master]
GO
/****** Object:  Database [PMIS]    Script Date: 9/14/2018 7:47:15 PM ******/
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
/****** Object:  User [pmis]    Script Date: 9/14/2018 7:47:16 PM ******/
CREATE USER [pmis] FOR LOGIN [pmis] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [pmis]
GO
/****** Object:  StoredProcedure [dbo].[spgetAllUserTask]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetParticipants]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetParticipantsByProj]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjectActivity]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjList]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetProjTask]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spgetTaskLog]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spGetUserTask]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spgetUserTaskCount]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spProjectDetails]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spProjectStatCount]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  StoredProcedure [dbo].[spUserProjectList]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[notification]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[participant]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[projecmessage]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[project]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[projectactivity]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[task]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[tasklog]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[user]    Script Date: 9/14/2018 7:47:16 PM ******/
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
/****** Object:  Table [dbo].[useractivities]    Script Date: 9/14/2018 7:47:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[useractivities](
	[activityId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NULL,
	[type] [varchar](50) NULL,
	[actcontent] [varchar](max) NULL,
	[date] [datetime] NULL,
	[id] [int] NULL,
 CONSTRAINT [PK_useractivities] PRIMARY KEY CLUSTERED 
(
	[activityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[notification] ADD  CONSTRAINT [DF_notification_seen]  DEFAULT ((0)) FOR [seen]
GO
ALTER TABLE [dbo].[participant] ADD  CONSTRAINT [DF_participant_status]  DEFAULT ('Active') FOR [status]
GO
USE [master]
GO
ALTER DATABASE [PMIS] SET  READ_WRITE 
GO
