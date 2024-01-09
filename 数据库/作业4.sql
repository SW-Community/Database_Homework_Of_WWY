/**
 *数据库实验四
 *@author Steve
 *@version 1.0.1 2021-11-5
 */

--实验四要求
--一、对xsgl数据库完成下列操作要求：
use xsgl
--1.	将被全部学生都选修了的课程的总学分改为4学分。
update kc
set kc.学分=4
where kc.课程号 in(/*一个where字句接范围，转换为select问题*/
	select kc.课程号
	from kc
	where not exists(
		select* from xs
		where not exists(
			select* 
			from cj
			where xs.学号=cj.学号 and cj.课程号=kc.课程号
		)
	)
)
--2.	从学生表删除没有选课的学生。
/*select xs.学号
from xs
where xs.学号 not in(
	select cj.学号 from cj
)*/

delete 
from xs
where xs.学号 not in(
	select cj.学号 from cj
)
--3.	将每个学生的平均分，总分和选课门数插入到数据库中（学号，姓名，平均分，总分，选课门数）
/*先建表*/
create table mytable1(
	学号 char(10) primary key,
	姓名 char(10),
	平均分 numeric(18,0),
	总分 numeric(18,0),
	选课门数 int
)
insert 
into mytable1(学号,姓名,平均分,总分,选课门数)
select xs.学号,xs.姓名,AVG(cj.成绩),SUM(cj.成绩),COUNT(cj.课程号)
from xs left join cj on xs.学号=cj.学号
group by xs.学号,xs.姓名
--4.	创建每门课程的平均分和选课人数的视图（课程号，课程名，平均分，人数）
create view MyView1(课程号,课程名,平均分,人数)/*不清楚为什么标红报错，运行没问题*/
as
select kc.课程号,kc.课程名,AVG(cj.成绩),COUNT(cj.学号)
from kc left join cj on kc.课程号=cj.课程号
group by kc.课程号,kc.课程名
--5.	将李强同学从学生表删除（提示应该先删除李强同学的选课记录）
delete
from cj
where cj.学号=(
	select xs.学号
	from xs
	where xs.姓名='李强'
)
delete
from xs
where xs.姓名='李强'
--6.	插入一条选课记录（具体内容自己选）
insert
into xs(学号,姓名,性别,出生时间,专业,总学分,照片,备注)
values('2000233666','张三','男','2000-1-1','计合',0,null,null)

insert 
into cj(学号,课程号,成绩)
values('2000233666','J005','100')
--7.	创建网络工程专业的学生的选课信息的视图，要求视图包含，学号，姓名，专业，课程号，课程名，成绩
create view YourView(学号,姓名,专业,课程号,课程名,成绩)
as
select xs.学号,xs.姓名,xs.专业,kc.课程号,kc.课程名,cj.成绩
from xs left join cj on xs.学号=cj.学号 left join kc on cj.课程号=kc.课程号
where xs.专业='网络工程'
--8.	查询网络工程专业的各科的平均成绩，要求使用第7题创建的视图进行查询
select YourView.课程号,AVG(YourView.成绩)
from YourView
group by YourView.课程号
--9.	查询被信息管理专业的学生都选修了的课程的课程号，课程名
select kc.课程号,kc.课程名
from kc
where not exists(
	select*
	from xs
	where xs.专业='信息管理'
	and not exists(
		select *
		from cj
		where xs.学号=cj.学号 and cj.课程号=kc.课程号
	)
)
--10.	显示选修课程数最多的学号及选修课程数最少的学号，姓名（使用派生表实现）
select top 1 with ties sublist.学号
from (
	select xs.学号,xs.姓名,COUNT(cj.课程号)
	from  xs left join cj on xs.学号=cj.学号
	group by xs.学号,xs.姓名
)
as sublist(学号,姓名,选课数目)
order by sublist.选课数目 desc

select top 1 with ties sublist.学号,sublist.姓名
from (
	select xs.学号,xs.姓名,COUNT(cj.课程号)
	from  xs left join cj on xs.学号=cj.学号
	group by xs.学号,xs.姓名
)
as sublist(学号,姓名,选课数目)
order by sublist.选课数目
--11.	查询每个学生成绩高于自己的平均成绩的学号，姓名，课程号和成绩（使用派生表实现）
select xs.学号,xs.姓名,kc.课程号,cj.成绩
from xs left join cj on xs.学号=cj.学号 left join kc on cj.课程号=kc.课程号
where cj.成绩>(
	select sublist.平均分
	from(
		select cj1.学号,AVG(cj1.成绩)
		from cj as cj1
		group by cj1.学号
	)as sublist(学号,平均分)
	where xs.学号=sublist.学号
)
--12.	自己验证with check option的作用。
/*比如说下面的操作*/
create view View2
as
select xs.学号
from xs

create view V3
as
select xs.学号,xs.姓名,xs.专业
from xs where xs.专业='计合'

insert into V3
values('2300900043','王五','软工')/*嗯成功了*/

create view V4
as
select xs.学号,xs.姓名,xs.专业
from xs where xs.专业='计合'
with check option

insert into V4
values('？','李四','计普')/*ok成功被拦*/
--13.	创建一个网络工程系的学生基本信息的视图MA_STUDENT，在此视图的基础上，再定义一个该专业女生信息的视图，然后再删除MA_STUDENT，观察执行情况。
create view MA_STUDENT
as
select*
from xs
where xs.专业='网络工程'

create view Girlfriends/*呵呵。。。*/
as
select*
from MA_STUDENT
where MA_STUDENT.性别='女'

drop view MA_STUDENT/*为啥还行啊*/
--14.	查询和程明同龄的学生的学号和姓名以及年龄
select xs.学号,xs.姓名,DATEDIFF(YY,xs.出生时间,GETDATE())as '年龄'
from xs
where DATEDIFF(YY,xs.出生时间,GETDATE())=(
	select DATEDIFF(YY,xs1.出生时间,GETDATE())
	from xs as xs1
	where xs1.姓名='程明'
)
--15.	查询没有被网络工程全部的学生都选修的课程的课程号和课程名（可以被网络工程专业的部分学生选修）
select kc.课程号,kc.课程名
from kc
where exists(
	select *
	from xs
	where xs.专业='网络工程'
	and
	not exists(
		select*
		from cj
		where xs.学号=cj.学号 and cj.课程号=kc.课程号
	)
)
--16.	查询没有选修数据结构，操作系统和英语三门课的学生的学号，姓名，课程号，课程名和成绩
select xs.学号,xs.姓名,kc.课程号,kc.课程名,cj.成绩
from xs left join cj on xs.学号=cj.学号 left join kc on cj.课程号=kc.课程号
where xs.学号 not in(
	select cj1.学号
	from cj as cj1
	where cj1.课程号 in(
		select kc1.课程号
		from kc as kc1
		where kc1.课程名 in('数据结构','操作系统','英语')
	)
)
--17.	将没有选课的学生的总学分设置为0
update xs
set xs.总学分=0
where xs.学号 not in(
	select distinct cj.学号
	from cj
)
--二、使用Northwind数据库完成下列操作
use Northwind
--1. 将员工lastname是: Peacock处理的订单中购买数量超过50的商品折扣改为七折
update [Order Details]
set Discount=0.3
where [Order Details].OrderID in(
 select [Order Details1].OrderID
 from [Order Details] as [Order Details1] inner join Orders on [Order Details].OrderID=Orders.OrderID inner join Employees on Orders.EmployeeID=Employees.EmployeeID
 where Employees.LastName='Peacock' and [Order Details1].Quantity>50
)
--2. 删除lastname是: Peacock处理的所有订单
delete from [Order Details]
where [Order Details].OrderID in (
	select o1.OrderID
	from Orders as o1
	where o1.EmployeeID =(
		select Employees.EmployeeID
		from Employees
		where Employees.LastName='Peacock'
	)
)

delete from Orders
where Orders.OrderID in (
	select o1.OrderID
	from Orders as o1
	where o1.EmployeeID =(
		select Employees.EmployeeID
		from Employees
		where Employees.LastName='Peacock'
	)
)
--3. 将每个订单的订单编号，顾客编号，产品总数量，总金额插入到数据库中
create table Mytable2
(
	OrderID int,
	CustomerID nchar(5),
	Quantity smallint,
	SummPrice money
)

insert into Mytable2(OrderID,CustomerID,Quantity,SummPrice)
select Orders.OrderID,Orders.CustomerID,[Order Details].Quantity,SUM((1-[Order Details].Discount)*[Order Details].Quantity*[Order Details].UnitPrice)
from [Order Details]inner join Orders on [Order Details].OrderID=Orders.OrderID
group by Orders.OrderID,Orders.CustomerID,[Order Details].Quantity
--4. 插入一个新的订单，要求该订单购买了商品编号为5,7,9的商品。（5号商品买了10个，7号买了20个，9号买了15个，都没有折扣）
insert into Orders(CustomerID,EmployeeID)
values('ALFKI',1)
/*先插入订单，根据
消息 544，级别 16，状态 1，第 256 行
当 IDENTITY_INSERT 设置为 OFF 时，不能为表 'Orders' 中的标识列插入显式值。
完成时间: 2021-11-05T11:33:07.1005437+08:00*/

select* from Orders
where Orders.CustomerID='ALFKI'
/*我的机器上结果是11078*/
/*然后是订单细节*/
insert into [Order Details](OrderID,ProductID,UnitPrice,Quantity,Discount)
values(11078,5,0,10,0),
(11078,7,0,20,0),
(11078,9,0,15,0)
/*不要钱大放血(￣y▽,￣)╭ */
--5. 将每年每个员工处理订单的数量和订单的总金额创建为视图
create view HerView(EmployeeID,Years,OrderCnt,OrderSumPrice)
as
select Orders.EmployeeID,YEAR(Orders.OrderDate),COUNT(Orders.OrderID),SUM([Order Details].Quantity*[Order Details].UnitPrice*(1-[Order Details].discount))
from Orders inner join [Order Details] on Orders.OrderID=[Order Details].OrderID
group by Orders.EmployeeID,YEAR(Orders.OrderDate)
--6. 购买了CustomerID是‘VINET’用户所购买的全部商品的用户的CustomerID和CompanyName。
select Customers.CustomerID,Customers.CompanyName
from Customers
where not exists(
	select bb.ProductID
	from (Orders as aa inner join [Order Details] as bb on aa.OrderID=bb.OrderID)
	where aa.CustomerID='VINET'
	and not exists(
		select *
		from Orders inner join [Order Details] on Orders.OrderID=[Order Details].OrderID
		where Customers.CustomerID=Orders.CustomerID and  [Order Details].OrderID=bb.ProductID
	)
)
--7. 将被全部顾客都购买过的商品的商品编号和商品名和单价创建为一个视图proa
create view proa
as
select Products.ProductID,Products.ProductName,Products.UnitPrice
from Products
where not exists(
	select*
	from Customers
	where not exists(
		select*
		from Orders inner join [Order Details] on Orders.OrderID=[Order Details].OrderID
		where Customers.CustomerID=Orders.CustomerID and [Order Details].ProductID=Products.ProductID
	)
)
--8. 将被全部顾客都购买过的商品的单价加上5元
update Products
set UnitPrice=Products.UnitPrice+5
where ProductID in (
	select Products.ProductID
from Products
where not exists(
	select*
	from Customers
	where not exists(
		select*
		from Orders inner join [Order Details] on Orders.OrderID=[Order Details].OrderID
		where Customers.CustomerID=Orders.CustomerID and [Order Details].ProductID=Products.ProductID
	)
)
)
--9. 删除订单总金额少于50元的订单明细
delete from [Order Details]
where [Order Details].OrderID in(
	select [Order Details].OrderID
	from [Order Details]
	group by [Order Details].OrderID
	having SUM([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount))<50
)
