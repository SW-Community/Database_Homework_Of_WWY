/**
 * *�յ� ANU����ҵ
 * @description ��ֱ�����У�һ���Եõ����н��������Ҫ����ѡ�н���
 * @author Steve
 * @version 1.0.0 2021-11-19
 */


--�������ݿ�
create database ANUProj
on primary
(
	name='ANUProj',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ANUProj.mdf',
	size=10mb,
	filegrowth=10%
)
log on
(
	name='ANUProj_log',
	filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\ANUProj_log.ldf',
	size=1mb,
	maxsize=20mb,
	filegrowth=1mb
)
go

use ANUProj
go

--������
create table UserGroup
(
	Groupid int primary key identity(0,1),
	Groupname char(30),
	Grouptype int,
	Groupnumber int,
	Groupdescripition varchar(255)
)
go

create table Users
(
	Userid int primary key identity(1,1),
	Username char(20),
	Useremail char(30) check (Useremail like '%@%.%'),
	Userage smallint check (Userage between 0 and 100),
	Company char(30),
	CompanyTitle char(30),
	Groupid int,
	
	foreign key(Groupid) references UserGroup(Groupid)
	on delete set null
)
go

create table Admins
(
	Adminid int primary key identity(0,1), 
	Adminname char(20),
	Adminpassword char(20)
)
go

create table QuestionSheets
(
	Sheetid int primary key identity(0,1),
	SheetTittle char(30),
	SheetDsicripition varchar(255),
	Answernums int check(Answernums>0),
	Adminid int,
	Groupid int,
	CreateDate datetime default getdate(),
	StartDate datetime default getdate(),
	EndDate datetime default dateadd(day,30,getdate()),

	foreign key(Adminid) references Admins(Adminid)
	on delete set null,
	foreign key(Groupid) references UserGroup(Groupid)
)
go

create table Questions
(
	Queid int primary key identity(0,1),
	Qcontent varchar(255),
	Qtype smallint check(QType between 1 and 5),
	Sheetid int,

	foreign key(Sheetid) references QuestionSheets(Sheetid)
	on delete cascade
)
go

create table Answers
(
	FlowSN int primary key identity(0,1),
	Userid int,
	Sheetid int,
	Answer varchar(255),
	StartTime datetime default getdate(),
	EndTime datetime,
	ClientIP int,--��������û�IDΪ0�������û�

	foreign key(Userid) references Users(Userid)
	on delete cascade,
	foreign key(Sheetid) references QuestionSheets(Sheetid)
	on delete cascade
)
go

create table AnswerDetails
(
	FlowSN int,
	Queid int,
	AnswerContent varchar(255),
	
	primary key(FlowSN,Queid),
	foreign key(FlowSN) references Answers(FlowSN)
	on delete cascade,
	foreign key(Queid) references Questions(Queid)
)
go

--������һЩSQL��䣬����������й��ܣ�
--д�ɴ洢���̻��ߺ����ˣ��������

--��ѯÿ���û����յ����ʾ�
create function dbo.GruopsAndSheets()
returns  table
as
return 
(
	select UserGroup.Groupid as '�û���ID',QuestionSheets.Sheetid as '�յ����ʾ�ID'
	from UserGroup left outer join QuestionSheets on UserGroup.Groupid=QuestionSheets.Groupid
)
go
--��ѯĳ���ʾ�û��������û�
create function WhoNotAnswer(@Sheetid int)
returns table
as
return
(
	select Users.Userid as '�û�ID',Users.Username as '�û���'
	from Users
	where Users.Userid not in(
		select Answers.Userid
		from Answers
		where Answers.Sheetid=@Sheetid
	)
)
go
--��ѯû�����κ��û�����û�
create function WhoIsSingle()
returns table
as
return
(
	select Users.Userid as '�û�ID',Users.Username as '�û���'
	from Users
	where Users.Groupid is null
)
go
--ɾ��ָ��ʱ�䴴�����ʾ�
create procedure DeleteSheets @when datetime
as
begin
	delete from QuestionSheets
	where QuestionSheets.CreateDate=@when
end
go

create login system_admin with password='1234'
go
create user system_admin from login system_admin
go
grant all on Admins to system_admin
grant all on AnswerDetails to system_admin
grant all on Answers to system_admin
grant all on Questions to system_admin
grant all on QuestionSheets to system_admin
grant all on UserGroup to system_admin
grant all on Users to system_admin

create login survey_creator with password='1234'
go

create user survey_creator for login survey_creator
go

grant select on UserGroup to survey_creator
grant insert on Questions to survey_creator
grant insert,select on QuestionSheets to survey_creator
go

create login data_analyst with password='1234'
go

create user data_analyst for login data_analyst
go

grant select on Answers to data_analyst
grant select on AnswerDetails to data_analyst
grant select on	Questions to data_analyst
go