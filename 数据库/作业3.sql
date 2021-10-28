/*	实验三要求	*/
/*	@author Steve	*/
/*	@date 2021.10.17	*/

--一．	对xsgl数据库完成以下操作
use xsgl
--1.	查询没有选修英语的学生的学号，姓名和课程号，课程名，成绩
select xs.学号,xs.姓名,kc.课程号,kc.课程名,cj.成绩
from xs left outer join cj on xs.学号=cj.学号 left outer join kc on cj.课程号=kc.课程号
where xs.学号 not in (
	select cj1.学号
	from cj as cj1 inner join  kc as kc1 on cj1.课程号=kc1.课程号
	where kc1.课程名='英语'
)
--2.	查询英语成绩高于英语的平均成绩的学生的学号，姓名，成绩
select xs.学号,xs.姓名,cj.成绩
from xs inner join cj on xs.学号=cj.学号 inner join kc on cj.课程号=kc.课程号
where kc.课程名='英语'and cj.成绩>(
	select AVG(cj1.成绩)
	from cj as cj1 inner join kc as kc1 on cj1.课程号=kc1.课程号
	where kc1.课程名='英语'
)
--3.	查询选修了英语和高数的学生的学号和姓名（要求使用两种方法实现）
/*方法一*/
select xs.学号,xs.姓名
from xs
where xs.学号 in (
	select cj.学号
	from cj
	where cj.课程号 in(
		select kc.课程号
		from kc
		where kc.课程名 in('英语','高数')
	)
)
/*方法二*/
select xs.学号,xs.姓名
from xs inner join cj on xs.学号=cj.学号 inner join kc on cj.课程号=kc.课程号
where kc.课程名 in ('英语','高数')
--4.	查询没有选修程明所选修的全部课程的学生的姓名
select xs.学号,xs.姓名
from xs
where exists
(
	select* 
	from cj inner join xs as xs1 on cj.学号=xs1.学号
	where xs1.姓名='程明'--这个问题当中所有的课程就是这子表
	and
	not exists(
		select *
		from cj as cj1
		where xs.学号=cj1.学号 and cj1.课程号=cj.课程号
		)
)
--5.	查询每个专业年龄超过该专业平均年龄的学生的姓名和专业
select xs.姓名,xs.专业
from xs
where DATEDIFF(yy,xs.出生时间,GETDATE())>(
	select AVG(DATEDIFF(yy,xs1.出生时间,GETDATE()))
	from xs as xs1
	where xs.专业=xs1.专业
)
--6.	查询每个专业每门课程的专业，课程号，课程名，选课人数，平均分和最高分
select xs.专业,kc.课程号,kc.课程名,COUNT(distinct xs.学号),AVG(cj.成绩),MAX(cj.成绩)
from xs inner join cj on xs.学号=cj.学号 inner join kc on cj.课程号=kc.课程号
group by xs.专业,kc.课程号,kc.课程名
--7.	查询每个学生取得最高分的课程的课程号，课程名和成绩
select xs.学号,cj.课程号,kc.课程名,cj.成绩
from xs left join(kc inner join cj on kc.课程号=cj.课程号) on xs.学号=cj.学号
where cj.成绩>=all(
	select cj2.成绩
	from cj as cj2
	where cj2.学号=xs.学号
)
--8.	查询每个专业年龄最高的学生的学号，姓名，专业和年龄
select xs.学号,xs.姓名,xs.专业,DATEDIFF(YY,xs.出生时间,GETDATE())as'年龄'
from xs 
where DATEDIFF(YY,xs.出生时间,GETDATE())>=all(
	select DATEDIFF(YY,xs2.出生时间,GETDATE())
	from xs as xs2
	where xs.专业=xs2.专业
)
--9.	查询没有选修数据结构和操作系统的学生的学号和姓名。（使用存在量词实现）
select xs.学号,xs.姓名
from xs
where not exists
(
	select * from cj
	where cj.学号=xs.学号 and cj.课程号 in(
		select kc.课程号
		from  kc
		where kc.课程名 in ('数据结构','操作系统')
	)
)
--10.	查询网络工程专业年龄最小的学生的学号和姓名
select xs.学号,xs.姓名
from xs
where xs.专业='网络工程'
and
DATEDIFF(YY,xs.出生时间,GETDATE())<=all(
	select DATEDIFF(YY,xs2.出生时间,GETDATE())
	from xs as xs2
	where xs2.专业=xs.专业
)
--11.	查询选课人数超过5人的课程的课程号，课程名和成绩
select cj.课程号,kc.课程名,cj.成绩
from cj inner join kc on cj.课程号=kc.课程号
where (select COUNT(cj2.学号)from cj as cj2 where cj2.课程号=cj.课程号)>5
--12.	查询选修了信息管理专业所有学生选修的全部课程的学生的学号和姓名
select xs.学号,xs.姓名
from xs
where not exists
(
	select * 
	from cj inner join xs as xs2 on cj.学号=xs2.学号
	and xs2.专业='信息管理'
	and not exists
	(
		select* from cj as cj2
		where xs.学号=cj2.学号 and cj2.课程号=cj.课程号
	)
)
--13.	使用存在量词实现查询没有被学生选修的课程的课程号和课程名
select kc.课程号,kc.课程名
from kc
where not exists
(
	select *
	from xs
	where exists
	(
		select * from cj
		where xs.学号=cj.学号 and cj.课程号=kc.课程号
	)
)
--14.	查询选课人数最多和选课人数最少的课程的课程号，课程名和人数
/*好家伙真nm费劲*/
select kc.课程号,kc.课程名,COUNT(cj.学号)
from kc left outer join cj on kc.课程号=cj.课程号
group by kc.课程号,kc.课程名
having COUNT(cj.学号)>=all(select COUNT(cj2.学号) from kc as kc2 left outer join cj as cj2 on kc2.课程号=cj2.课程号 group by kc2.课程号)
or COUNT(cj.学号)<=all(select COUNT(cj2.学号) from kc as kc2 left outer join cj as cj2 on kc2.课程号=cj2.课程号 group by kc2.课程号)
--15.	查询选修英语的成绩高于英语课程的平均成绩的学生的学号，姓名和成绩
select xs.学号,xs.姓名,cj.成绩
from xs inner join cj on xs.学号=cj.学号 inner join kc on cj.课程号=kc.课程号
where kc.课程名='英语'
and
cj.成绩>(
	select AVG(cj2.成绩) from cj as cj2 where cj2.课程号=cj.课程号
)
--16.	查询各门课中成绩最高分的学生的学号，姓名，课程号，课程名，分数
select xs.学号,xs.姓名,kc.课程号,kc.课程名,cj.成绩
from kc left outer join cj on kc.课程号=cj.课程号 left outer join xs on cj.学号=xs.学号
where cj.成绩>=all(
	select cj2.成绩 from cj as cj2
	where cj2.课程号=kc.课程号
)
--17.	查询每门课中成绩低于该课程的平均成绩的学号，课程号，成绩
select cj.学号,cj.课程号,cj.成绩
from cj
where cj.成绩<(
	select AVG(cj2.成绩)from cj as cj2 where cj2.课程号=cj.课程号
)
--18.	查询各个专业每门课程取得最高分的学生的学号，姓名，专业，课程号，课程名，成绩
select xs.学号,xs.姓名,xs.专业,kc.课程号,kc.课程名,cj.成绩
from xs inner join cj on xs.学号=cj.学号 inner join kc on cj.课程号=kc.课程号
where cj.成绩>=all(
	select cj2.成绩
	from cj as cj2
	where cj2.课程号=kc.课程号/*没考虑没选课的和没被选的课，感觉这两种情况不太好给出语义解释*/
)
--19.	查询没有选修全部课程的学生的学号和姓名，
select xs.学号,xs.姓名
from xs
where exists(
	select * from kc
	where not exists(
		select* from cj
		where cj.学号=xs.学号 and cj.课程号=kc.课程号
	)
)
--20.	查询没有被全部学生都选修了的课程的课程号和课程名
select kc.课程号,kc.课程名
from kc
where exists(
	select* 
	from xs
	where not exists(
		select* from cj
		where cj.学号=xs.学号 and cj.课程号=kc.课程号
	)
)
--21.	查询选课门数少于网络工程专业某个学生的选课门数的学生的学号，姓名和选课门数

--22.	查询选课人数超过英语的选课人数的课程的课程号，课程名和人数

--23.	查询成绩高于选修英语的某个学生的成绩的学生的学号，姓名，课程号，课程名，成绩

--24.	查询选修了程明和方可以同学所选修的全部课程的学生的学号和姓名

--25.	查询选课学生包含了选修英语的全部学生的课程的课程号和课程名

--26.	查询每门课程成绩倒数两名的同学的学号，姓名和课程号，课程名，成绩

--27.	查询每门课程里成绩排名在前10%的同学的学号，姓名和课程号，课程名，成绩

--28.	查询没有选修全部课程的学生的学号和姓名

--29.	查询选课门数高于网络工程专业每个学生的选课门数的其他专业的学生的学号，姓名和选课人数

--30.	查询学生人数最少的专业名和专业人数

--二、	对books数据库完成以下操作

--31.	查询各种类别的图书的类别和数量（包含目前没有图书的类别）

--32.	查询借阅了‘数据库基础’的读者的卡编号和姓名

--33.	查询各个出版社的图书价格超过这个出版社图书的平均价格的图书的编号和名称。

--34.	查询没有借过图书的读者的编号和姓名

--35.	查询借阅次数超过2次的读者的编号和姓名

--36.	查询借阅卡的类型为老师和研究生的读者人数

--37.	查询没有被借过的图书的编号和名称

--38.	查询没有借阅过英语类型的图书的教师的编号和姓名

--39.	查询借阅了‘计算机应用’类别的‘数据库基础’课程的读者的编号，读者姓名以及该读者的借阅卡的类型。

--40.	查询没有被全部的读者都借阅过的图书的编号和图书名称

--41.	查询借阅过清华大学出版社的所有图书的读者编号和姓名

--42.	查询借阅过王明所借阅过的全部图书的读者编号和姓名

--43.	查询每种类型的借阅者借阅过的图书的次数

--44.	查询价格高于清华大学出版社的所有图书价格的图书的编号，图书名称和价格，出版社

--45.	查询没有借阅过王明所借过的所有图书的借阅者的编号姓名

--三、对商场数据库完成以下操作
--Market (mno, mname, city)
--Item (ino, iname, type, color)
--Sales (mno, ino, price)
--其中，market表示商场，它的属性依次为商场号、商场名和所在城市；item表示商品，它的属性依次为商品号、商品名、商品类别和颜色；sales表示销售，它的属性依次为商场号、商品号和售价。

--用SQL语句实现下面的查询要求：
--1.	列出北京各个商场都销售，且售价均超过10000 元的商品的商品号和商品名

--2.	列出在不同商场中最高售价和最低售价只差超过100 元的商品的商品号、最高售价和最低售价

--3.	列出售价超过该商品的平均售价的各个商品的商品号和售价

--4.	查询每个每个城市各个商场售价最高的商品的商场名，城市，商品号和商品名

--5.	查询销售商品数量最多的商场的商场号，商场名和城市

--6.	查询销售了冰箱和洗衣机的商场号，商场名和城市

--7.	查询销售过海尔品牌的所有商品的商场编号和商场名称

--8.	查询销售了所有商品的商场编号和商场名称

--9.	查询在北京的各个商场都有销售的商品的编号和商品名称

--10.	查询价格高于北京的所有商场所销售的产品的价格的商品编号和商品名称。
