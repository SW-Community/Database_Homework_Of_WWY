/**
 *数据库实验四
 *@author Steve
 *@version 1.0.0 2021-11-4
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
values('2000800099','刘明烨','男','2000-1-1','计合',0,null,null)/*我只是没数据不然我真给放上*/

insert 
into cj(学号,课程号,成绩)
values('2000800099','J005','0')/*取实际情况的后10位，谁的号谁心里清楚好自为之*/
--7.	创建网络工程专业的学生的选课信息的视图，要求视图包含，学号，姓名，专业，课程号，课程名，成绩
create view YourView(学号,姓名,专业,课程号,课程名,成绩)
as
select xs.学号,xs.姓名,xs.专业,kc.课程号,kc.课程名,cj.成绩
from xs left join cj on xs.学号=cj.学号 left join kc on cj.课程号=kc.课程号
where xs.专业='网络工程'
--8.	查询网络工程专业的各科的平均成绩，要求使用第7题创建的视图进行查询

--9.	查询被信息管理专业的学生都选修了的课程的课程号，课程名
--10.	显示选修课程数最多的学号及选修课程数最少的学号，姓名（使用派生表实现）
--11.	查询每个学生成绩高于自己的平均成绩的学号，姓名，课程号和成绩（使用派生表实现）
--12.	自己验证with check option的作用。
--13.	创建一个网络工程系的学生基本信息的视图MA_STUDENT，在此视图的基础上，再定义一个该专业女生信息的视图，然后再删除MA_STUDENT，观察执行情况。
--14.	查询和程明同龄的学生的学号和姓名以及年龄
--15.	查询没有被网络工程全部的学生都选修的课程的课程号和课程名（可以被网络工程专业的部分学生选修）
--16.	查询没有选修数据结构，操作系统和英语三门课的学生的学号，姓名，课程号，课程名和成绩
--17.	将没有选课的学生的总学分设置为0
--二、使用Northwind数据库完成下列操作
--1. 将员工lastname是: Peacock处理的订单中购买数量超过50的商品折扣改为七折
--2. 删除lastname是: Peacock处理的所有订单
--3. 将每个订单的订单编号，顾客编号，产品总数量，总金额插入到数据库中
--4. 插入一个新的订单，要求该订单购买了商品编号为5,7,9的商品。（5号商品买了10个，7号买了20个，9号买了15个，都没有折扣）
--5. 将每年每个员工处理订单的数量和订单的总金额创建为视图
--6. 购买了CustomerID是‘VINET’用户所购买的全部商品的用户的CustomerID和CompanyName。
--7. 将被全部顾客都购买过的商品的商品编号和商品名和单价创建为一个视图proa
--8. 将被全部顾客都购买过的商品的单价加上5元
--9. 删除订单总金额少于50元的订单明细

