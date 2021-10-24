--要问的问题：
--		一、7，10，14，17，20，21，23，24，25，26，27，30-34；
--		二、10；
--		三、全部（表没看懂，看文档还是有的地方不明白）

--一：对给定的xsgl数据库完成以下查询要求 ：
use xsgl
go
--对xs表增加身份证号码属性列，要求是18位的字符类型
alter table xs
add sfzh char(18)
--1．查询有直接先行课的课程的课号，课名和先行课号。
select kc.课程号,kc.课程名,kc.先行课号
from kc
where kc.先行课号 is not null
--2．查询先行课号是“J001”号课程的课号和课名
select kc.课程号,kc.课程名
from kc
where kc.先行课号='J001'
--3．	查询所有的网络工程系姓李，张，王的同学的学号和姓名
select xs.学号,xs.姓名
from xs
where xs.专业='网络工程' and xs.姓名 like '[李,张,王]%'
--4．	查询不在网络工程和信息管理专业学习的学生的学号和姓名，系别，并对查询结果按照专业的升序和学号的降序排序
select xs.学号,xs.姓名,xs.专业
from xs
where xs.专业 not in('网络工程','信息管理')
order by xs.专业 asc,xs.学号 desc
--5．	查询每门课不及格的学生的人数，显示课号和人数
select cj.课程号,COUNT(*)
from cj
where cj.成绩<60
group by cj.课程号
--6．	查询年龄不在30-35之间的网络工程系的学生的学号，姓名和年龄
select xs.学号,xs.姓名,DATEDIFF(yy,xs.出生时间,getdate()) as '年龄'
from xs
where xs.专业='网络工程' and DATEDIFF(yy,xs.出生时间,getdate()) not between 30 and 35
--7．	查询没有选修‘J001’号课程的学生的学号（注意去掉重复的元组）
select distinct xs.学号
from xs
where xs.学号 not in (select cj.学号 from cj where cj.课程号='J001')
--8．	查询每个学生的学号，姓名，出生年份，并给出生年份起别名为chusheng 
select xs.学号,xs.姓名,YEAR(xs.出生时间) as 'chusheng'
from xs
--9. 查询每个学生的学号，姓名和出生日期（出生日期根据身份证号码查询）
select xs.学号,xs.姓名,SUBSTRING(xs.sfzh,7,8) as '出生日期'
from xs--由于未导入身份证号码数据，所以最后一列全NULL（列本身已经添加最前面有代码）
--10.查询选修J001课程成绩排名第一的同学的学号和成绩
select cj.学号,cj.成绩
from cj
where cj.课程号='j001' and cj.成绩 in(
	select top 1 cj.成绩
	from cj
	where cj.课程号='j001'
	order by cj.成绩 desc
)
--11. 查询所有名字中含有’明’或者’丽’的同学的学号，姓名
select xs.学号,xs.姓名
from xs
where xs.姓名 like '%[明,丽]%'
--12. 查询信息管理专业年龄超过20岁的学生的人数
select COUNT(*)
from xs
where xs.专业='信息管理' and DATEDIFF(yy,xs.出生时间,getdate())>20
--13. 查询平均成绩超过80分的课程的课程号和平均成绩
select cj.课程号,AVG(cj.成绩)
from cj
group by cj.课程号
having AVG(cj.成绩)>80
--14. 查询每个专业所有姓张的人数
select xs.专业,COUNT(*) as '人数'
from xs
where xs.姓名 like '张%'
group by xs.专业--这种情况，对不包含姓张的无法输出
--以下是自己yy的一个方法：
select xs1.专业,COUNT(xs2.学号)
from xs as xs1 left outer join(select* from xs where xs.姓名 like '张%')as xs2 on xs1.学号=xs2.学号
group by xs1.专业
--15. 查询各种姓氏的人数（假设没有复姓）
select SUBSTRING(xs.姓名,1,1) as '姓氏',COUNT(*) as '人数'
from xs
group by SUBSTRING(xs.姓名,1,1)--gruopby的依据也可以是列被函数处理过的结果
--16.查询选修课程超过5门的学生的学号和选课门数，以及平均成绩
select cj.学号,COUNT(*) as '选课门数',AVG(cj.成绩) as '平均成绩'
from cj
group by cj.学号
having COUNT(*)>5
--17. 查询选修‘J001’课程的成绩排名前五的学生的学号和成绩
select top 5 with ties cj.学号,cj.成绩
from cj
order by cj.成绩 desc--排名前五怎么理解？
--如果相同名次顺延的话。top5+withties就可以搞定，如果要求并列，必须使用嵌套查询
--18.查询每个学生的最低分和选课门数
select cj.学号, MIN(cj.成绩) as '最低分',COUNT(cj.课程号) as '选课门数'
from cj
group by cj.学号
--19. 查询各个专业各种性别的人数
select xs.专业,xs.性别,COUNT(xs.学号) as '人数'
from xs
group by xs.专业,xs.性别
--20.查询各个专业男生的人数
select xs.专业,COUNT(xs.学号) as '人数'
from xs
where xs.性别='男'
group by xs.专业--和14一样的问题
--21. 列出有二门以上课程（含两门）不及格的学生的学号及该学生的平均成绩；
select cj.学号,AVG(cj.成绩)as'平均分'
from cj
where cj.学号 in(
	select cj.学号
	from cj
	where cj.成绩<60
	group by cj.学号
	having COUNT(cj.课程号)>=2
)
group by cj.学号
--22. 显示学号第五位或者第六位是1、2、3、4或者9的学生的学号、姓名、性别、年龄及专业；
select xs.学号,xs.姓名,xs.性别,DATEDIFF(yy,xs.出生时间,getdate()) as '年龄',xs.专业
from xs
where SUBSTRING(xs.学号,5,1) in('1','2','3','4','9') or SUBSTRING(xs.学号,6,1) in('1','2','3','4','9')
--23. 显示选修课程数最多的学号及选修课程数最少的学号；
select cj.学号,COUNT(cj.课程号)as'选课数量'
from cj
group by cj.学号
having COUNT(cj.课程号) in(
	select top 1 COUNT(cj.课程号)
	from cj
	group by cj.学号
	order by COUNT(cj.课程号) desc
)--一句话能搞定吗？
--24. 查询选修了A001或者A002或者J001或者J002课程的学生的学号和课程号
select cj.学号,cj.课程号
from cj
where cj.课程号 in('a001','a002','j001','j002')--这也行？
--25. 查询姓名为两个字的不同姓氏的人数，输出姓氏，人数。
select SUBSTRING(xs.姓名,1,1) as '姓氏',COUNT(xs.学号) as '人数'
from xs
where LEN(xs.姓名)=2--通配符问题还是有点不明白
group by SUBSTRING(xs.姓名,1,1) 
--26. 查询选修了A001或者A002或者J001或者J002课程的学生的课程号，课程名和选课人数
select cj.课程号,kc.课程名,COUNT(cj.学号)as'选课人数'
from cj inner join kc on cj.课程号=kc.课程号
where cj.课程号 in ('A001','A002','J001','J002')
group by cj.课程号,kc.课程名
having COUNT(cj.学号)>0--没看懂题意
--27.查询每个学生的学号，姓名以及成绩及格的课程门数
select xs.学号,xs.姓名,COUNT(cj1.课程号)as'及格门数'
from xs left outer join (select * from cj where cj.成绩>=60)as cj1 on xs.学号=cj1.学号
group by xs.学号,xs.姓名
--28. 查询每个学生的学号，姓名以及选课门数和平均成绩
select xs.学号,xs.姓名,COUNT(cj.课程号)as'选课门数',AVG(cj.成绩)as'平均成绩'
from xs left outer join cj on xs.学号=cj.学号
group by xs.学号,xs.姓名
--29. 查询选修选修数据结构和操作系统的课程名和选课人数
select kc.课程名,COUNT(cj.学号)as'选课人数'
from kc inner join cj on kc.课程号=cj.课程号
group by kc.课程名
having kc.课程名 in('数据结构','操作系统')
--30. 查询选课人数超过五人的课程号和课程名以及该课程的最高分
select kc.课程号,kc.课程名,MAX(cj.成绩) as '最高分'
from kc inner join cj on kc.课程号=cj.课程号
group by kc.课程号,kc.课程名
having COUNT(cj.学号)>5
--31.为kc表增加先行课号属性列，要求设置为kc表参考于主码的外码
alter table kc
add 先行课号 char(10)

alter table kc
add constraint FK_KC foreign key(先行课号) references kc(课程号)
--32. 为选课表添加学号的升序索引，为选课表添加课程号的降序索引
create nonclustered index MY_INDEX_0000 on xs(学号)
create nonclustered index MY_INDEX_0001 on cj(课程号 desc)
exec sp_helpindex xs
exec sp_helpindex cj--存储过程的参数不需要放入括号里面
--33. 为xs表添加专业升序，学号降序的索引
create nonclustered index MY_INDEX_0520 on xs(专业,学号 desc)
exec sp_helpindex xs
--34. 为XS表添加专业的升序的聚集索引，注意如果已经有主码聚集索引请先删除，创建好聚集索引之后，再重新添加主码约束
exec sp_helpindex xs
--alter table xs drop constraint PK_xs--直接删除会报错“约束 'PK_xs' 正由表 'cj' 的外键约束 'FK_cj_xs' 引用。”
--drop index xs.PK_xs--直接删这个也会报错：不允许对索引 'xs.PK_xs' 显式地使用 DROP INDEX。该索引正用于 PRIMARY KEY 约束的强制执行。
--以下是解决方法：
exec sp_helpindex cj
exec sp_helpconstraint cj--这一句用来查询约束名称

alter table cj
drop constraint FK_cj_xs

exec sp_helpconstraint xs--同理

alter table xs
drop constraint PK_xs

create clustered index myindex on xs(专业)--OK一路顺风
alter table xs
add constraint myzm primary key(学号)--这样就没有任何问题啦吖
--PS：索引和约束：不是一个东西，前者用户无感（速度方面除外），后者限制内容
--创建主码（约束）的时候如果还没有聚集索引则自动创建聚集索引，而且不能单独删除，只能删除主码约束
--可以先创建聚集索引，再创建主码约束
--自动创建的索引名称和约束名称与具体的软件版本有关，分别用系统存储过程SC_HELPINDEX,SC_HELPCONSTRAINT查看
--35. 查询与李强不在同一个专业学习的学生的学号，姓名和专业
select xs1.学号,xs1.姓名,xs1.专业
from xs as xs1 inner join xs as xs2 on xs1.专业<>xs2.专业--好好想想这个内连接的过程是怎么执行的，xs1和xs2的作用又是什么！！！！！
where xs2.姓名='李强'

--二：对书上第二章课后习题的4的SPJ数据库各表查询： 
use spj
go
--1．	求供应工程J1零件的供应商号码SNO
select distinct spj.sno
from spj
where spj.jno='j1'
--2．	求查询每个工程使用不同供应商的零件的个数
select j.jno,spj.sno,COUNT(SPJ.qty)as'个数'
from j left outer join spj on j.jno=spj.jno
group by j.jno,spj.sno
--3．	求供应工程使用零件P3数量超过200的工程号JNO
select spj.jno--此例说明如果想把聚合函数结果当作查询条件，那么只能用groupby啦
from spj
where spj.pno='p3'
group by spj.jno 
having SUM(spj.qty)>200
--4．	求颜色为红色和蓝色的零件的零件号和名称
select p.pno,p.pname
from p
where p.color in('红','蓝')
--5．	求使用零件数量在200-400之间的工程号
select spj.jno--此例说明如果想把聚合函数结果当作查询条件，那么只能用groupby啦
from spj
group by spj.jno
having SUM(spj.qty) between 200 and 400
--6．	查询每种零件的零件号，以及使用该零件的工程数。
select spj.pno,COUNT(distinct jno)as'使用的工程数目'
from spj
group by spj.pno
--7．	查询每个工程所使用的不同供应商供应的零件数量，输出工程号，供应商号和零件零件数量
select spj.jno,spj.sno,SUM(spj.qty)as'零件数量'
from spj
group by spj.jno,spj.sno
--8．	查询没有供应任何零件的供应商号，供应商名称
select s.sno,s.sname
from s left outer join spj on s.sno=spj.sno
where spj.pno is null
--9．	查询使用了S1供应商供应的红色零件的工程号和工程名
select j.jno,j.jname
from s inner join spj on s.sno=spj.sno inner join p on spj.pno=p.pno inner join j on spj.jno=j.jno
where s.sname='s1' and p.color='红'

select j.jno,j.jname
from s , spj,p,j 
where s.sno=spj.sno and  spj.pno=p.pno and  spj.jno=j.jno
 and s.sno='s1' and p.color='红'
--10.	查询各个工程的工程号，工程名以及所使用的的零件数量
select j.jno,j.jname,ISNULL(SUM(spj.qty),'0')as'使用零件数量'
from j left outer join spj on j.jno=spj.jno
group by j.jno,j.jname
--经测试发现以下问题
--sum(column) 是对所有列的值求和。
--如果没查到数据，sum的值为null
--如果查到的数据这一列值为null，sum的值为null
--如果查到数据有null，也有不是null的，那么sum的值为所有非空值的和。

--三．对Northwind数据库完成一下查询
--传送门：https://www.cnblogs.com/camelroyu/p/4284274.html
use Northwind
go
--1.查询每个订单购买产品的数量和总金额，显示订单号，数量，总金额
select [Order Details].OrderID,COUNT([Order Details].ProductID),SUM([Order Details].UnitPrice*[Order Details].Quantity*[Order Details].Discount)
from [Order Details]
group by [Order Details].OrderID--这行么
--2. 查询每个员工在7月份处理订单的数量
select Orders.EmployeeID,COUNT(Orders.OrderID)as'订单数量'
from Orders
where MONTH(Orders.ShippedDate)=7
group by Orders.EmployeeID
--3. 查询每个顾客的订单总数，显示顾客ID，订单总数
select Orders.CustomerID,COUNT(Orders.OrderID)as'订单总数'
from Orders
group by Orders.CustomerID
--4. 查询每个顾客的订单总数和订单总金额
select Customers.CustomerID,COUNT(Orders.OrderID)as'订单总数',SUM([Order Details].UnitPrice*[Order Details].Quantity*[Order Details].Discount)
from Customers left outer join Orders on Customers.CustomerID=Orders.CustomerID full outer join [Order Details] on Orders.OrderID=[Order Details].OrderID
group by Customers.CustomerID
--5. 查询每种产品的卖出总数和总金额
select Categories.CategoryID,SUM([Order Details].Quantity)
from Categories left outer join Products on Categories.CategoryID=Products.CategoryID left outer join [Order Details] on Products.ProductID=[Order Details].ProductID
group by Categories.CategoryID
--后记：打工苦打工累，CRUD不偿命啊。。。
--小声bb：听说外包公司就是干这个的。。。可怕