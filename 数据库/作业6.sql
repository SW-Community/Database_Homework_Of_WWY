/**
 * 数据库实验六
 * @author Steve
 * @version 1.0.0 2021-11-16
 */

--对xsgl数据库完成以下操作：
use xsgl
--1.	为xs表的学分列设置默认值为18
alter table xs
add constraint C1 default 18 for 总学分
--2.	为cj表设置标识列（列名自己起），起始行为2001，步长为1
alter table cj
add 标识列 int identity(2001,1)
select* from cj
--3.	为xs表的性别列增加约束，让性别取值为男或者女
alter table xs
add constraint C2 check (性别 in('男','女'))
--4.	定义check约束，要求学生学号sno必须为9位数字字符，且不能以0开头，第二三位皆为0
alter table xs
with nocheck /* 表里面学号全是10位的，所以被迫with nocheck了 */
add constraint C3 check (学号 like '[1-9]00[0-9][0-9][0-9][0-9][0-9][0-9]')

/* 验证一下 */
insert into xs(学号,姓名)
values('100333333','东惜雪')

insert into xs(学号,姓名,总学分)
values('03','？？',20)
--5.	要求学生表的学生姓名长度在2-8之间
alter table xs
add constraint C4 check(len(姓名)between 2 and 8)
--6.	给xs表添加属性列“身份证号码”，并为其添加约束为18位（首字符不能为0的数字，最后一位可以是1-9数字或者X，其余位均为0-9的数字）
alter table xs
add 身份证号码 char(18) check(身份证号码 like'[^0][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9,X,x]')
--7.	给cj表增加级联删除和拒绝修改的学号和课程号的外码约束。
alter table cj
add constraint C5 foreign key(学号)references xs(学号)
on delete cascade
alter table cj
add constraint C6 foreign key(课程号)references kc(课程号)
on delete cascade
--8.	创建借书表：lendt(bno（索书号）,sno（学号）,ldate（借阅日期）,rdate（应还日期），relend（是否续借）
create table lendt(
	bno int not null,
	sno char(10) not null,
	ldate datetime,
	rdate datetime,
	relend bit
)
--请为该表增加四个约束条件：
--（1）增加主码约束（bno,sno）
alter table lendt
add constraint C7 primary key(bno,sno)
--（2）为借阅日期增加默认值约束，默认值为当前日期
alter table lendt
add constraint C8 default getdate() for ldate
--（3）为应还日期增加默认值约束，默认值为当前日期+30天
alter table lendt
add constraint C9 default getdate()+convert(datetime,30) for rdate
--（4）为是否续借增加默认值约束，默认值为否
alter table lendt
add constraint C10 default 0 for relend
go
--9.	参照书上167页的5.6节断言完成下列操作：
/* 
   由于MSSQLSERVER不支持断言，因此很可惜这些操作一个也做不了
   但是可以用触发器替代实现相同效果
*/
--（1）	限定每个专业的选课门数不能超过10门
create trigger T1 on cj
after insert
as
if 10<(
	select COUNT(cj.课程号)
	from xs inner join cj on xs.学号=cj.学号
	where xs.学号=inserted.学号
)
	rollback transaction
go
--（2）	限定每个学生至少要选修6门课程
create trigger T2 on cj
after delete
as
if 6>(
	select COUNT(cj.课程号)
	from xs left join cj on xs.学号=cj.学号
	where xs.学号=deleted.学号
)
	rollback transaction
go
--10.	设计触发器实现：如果一个学生的专业是网络工程专业，那么他的总学分不得少于22分，
--也就是如果你插入一个新的网络工程专业的学生或者更新这个专业的学生的学分少于22分的话，
--就将其改为22学分。
create trigger T3 on xs
after insert,update
as
if exists (
	select* from inserted
	where inserted.专业='网络工程' and inserted.总学分<22
)
begin
	update xs
	set xs.总学分=22
	where xs.学号 in (
		select inserted.学号
		from inserted
		where inserted.专业='网络工程' and inserted.总学分<22
	)
end
go
--11.	建立教师表（教工编号，姓名，专业，职称，工资）和
--工资变化表（教工编号，原工资，新工资），设计触发器实现教授的工资不得低于4000元，
--如果低于4000元则自动改为4000元。
--并且所有员工如果员工的工资发生变化则向工资变化表插入一条记录，
--包含教工编号，原工资，新工资。
create table js(
	教工编号 char(10),
	姓名 nchar(10),
	专业 char(16),
	职称 char(16),
	工资 int
)

create table gzbh(
	教工编号 char(10),
	原工资 int,
	新工资 int
)
go

create trigger T4 on js
after insert,update
as
if exists(
	select* from inserted
	where inserted.工资<4000
)
begin
	update js
	set js.工资=4000
	where js.教工编号 in(
		select inserted.教工编号 from inserted
		where inserted.工资<4000
	)
end
go

create trigger T5 on js
after update
as
begin
	insert into gzbh(教工编号,原工资,新工资)
	select inserted.教工编号,deleted.工资,inserted.工资
	from inserted inner join deleted on inserted.教工编号=deleted.教工编号
end
go
--12.	设计触发器实现如果一个学生转专业了，那么输出一条信息显示该学生各门课程的平均分，
--但是如果该学生是计算机中澳专业则不允许转专业。
create trigger T7 on xs
after update
as
begin
	if UPDATE(专业) 
	begin
		if exists(select * from deleted where deleted.专业='计算机中澳')
		begin
			print 'ERROR OCCURRED！'
			rollback transaction
		end
		else
		begin
			declare @pjf numeric(18,0)
			select @pjf=AVG(cj.成绩)
			from xs left join cj on xs.学号=cj.学号
			where xs.学号 in 
			(
				select deleted.学号
				from deleted
			)
			print '你的平均分是'+str(@pjf)+'，真的很棒，恭喜你顺利完成转专业！'
		end
	end
end
go
--13.	设计触发器实现每门课的选课人数不能超过60人，只考虑插入一行
create trigger T8 on cj
after insert,update
as
begin
	if 60<(
		select COUNT(cj.学号)
		from cj
		group by cj.课程号
		having cj.课程号 in	(
			select inserted.课程号
			from inserted
		)
	)
	begin
		rollback transaction
	end
end
go
--14.	设计触发器实现如果成绩被修改了20分以上，则输出提示信息“修改成绩超过20分，请慎重”，
--并输出该学生的选课记录。
create trigger T9 on cj
after update
as
begin
	if(UPDATE(成绩))
	begin
		declare @xgq numeric(18,0)
		declare @xgh numeric(18,0)
		select @xgq=deleted.成绩
		from deleted
		select @xgh=inserted.成绩
		from inserted
		if @xgh-@xgq>20 or @xgh-@xgq<-20
			print'修改成绩超过20分，请慎重。捞学生是积德行善，但若被教务处发现，您可能需要承担责任'
	end
end
go
--15.	如果一门课的学分发生了修改， 则所有选修该课程并且及格的学生的总学分要做相应的修改，
--并输出学号，姓名，原总学分，新总学分。
create trigger T520 on xs
after update
as
begin
	if(update(总学分))
	begin
		select deleted.学号,deleted.姓名,deleted.总学分,inserted.总学分
		from inserted inner join deleted on inserted.学号=deleted.学号
	end
end

create trigger T10 on kc
after update
as
begin
	if(UPDATE(学分))
	begin
		declare @yxf smallint
		declare @xxf smallint
		declare @kch char(10)
		select @xxf=inserted.学分
		from inserted
		select @yxf=deleted.学分
		from deleted
		select @kch=inserted.课程号
		from inserted
		declare @delta smallint
		set @delta=@xxf-@yxf
		update xs
		set xs.总学分=xs.总学分+@delta
		where xs.学号 in(
			select cj.学号
			from cj
			where cj.成绩>=60 and cj.课程号=@kch
		)
	end
end
go
--16.	针对northwind数据库实现触发器：每个员工每天处理订单的数量不能超过100，
--如果超出100个则拒绝处理，并提示“处理订单数量超出限额”
use Northwind
go
create trigger T11 on Orders
after insert
as
begin
	declare @tot int
	declare @emid int
	declare @day varchar(20)
	select @emid=EmployeeID from inserted
	select @day=CONVERT(varchar(100), OrderDate, 2) from inserted
	select @tot=COUNT(*) from Orders
	where CONVERT(varchar(100), Orders.OrderDate, 2)=@day and Orders.EmployeeID=@emid
	if(@tot>100)
	begin
		print'处理订单数量超出限额'
		rollback transaction
	end
end
--17.	针对northwind数据库实现触发器：给orders表添加zje（订单总金额）属性列，
--要求保留两位小数，设置触发器实现当产生了新的订单明细之后将总金额更新到到订单表里。
alter table Orders
add zje numeric(18,2)
go

create trigger T12 on [Order Details]
after insert
as
begin
	declare @OrderID int
	declare @zje numeric(18,2)
	select @OrderID=OrderID from inserted
	select @zje = sum(UnitPrice*Quantity*(1-Discount)) from inserted group by OrderID,ProductID
	update Orders
	set zje=zje+@zje
	where Orders.OrderID=@OrderID
end
go
--18.	在课程表里添加一列：选课人数，设置触发器每门课如果有人选修了，
--那么课程表里的选课人数相应修改，考虑批量插入选课记录的情况。
use xsgl
go
alter table kc
add 选课人数 int
go

create trigger T13 on cj
after insert
as
begin
	update kc
	set 选课人数=(
		select COUNT(*)
		from cj
		where cj.课程号=kc.课程号
		group by cj.课程号
	)
	where kc.课程号 in
	(select distinct cj.课程号 from cj)
end
go
--19.	设置触发器实现如果学生表发生了插入、更新或者删除操作，请输出插入、更新或者删除的行数。
create trigger T14 on xs
after insert,update,delete
as
begin
	declare @cnt1 int
	declare @cnt2 int
	set @cnt1= (select COUNT(*) from inserted)
	set @cnt2= (select COUNT(*) from deleted)
	if(@cnt1<>0 and @cnt2<>0)
		print '更新'+str(@cnt1)+'行'
	else if (@cnt1<>0 and @cnt2=0)
		print '添加'+str(@cnt1)+'行'
	else if(@cnt1=0 and @cnt2<>0)
		print '删除'+str(@cnt2)+'行'
end
go
/* 
  道路千万条，
  安全第一条，
  行车不规范，
  亲人两行泪！
*/
