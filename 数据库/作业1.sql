--针对xsgl数据库使用sql语句完成一下查询：
use xsgl
go
--查询总学分超过20学分的学生的人数
select count(*) 
from xs
where xs.总学分>20
--查询不是网络工程专业的学生的学号，姓名和专业
select xs.学号,xs.姓名,xs.专业
from xs
where xs.专业<>'网络工程'
--查询选修了‘A001’课程的学生的人数
select count(cj.学号) 
from cj
where cj.课程号='A001'
--查询选修了‘A001’课程的学生不及格的学生的学号，课程号和成绩
select cj.学号,cj.课程号,cj.成绩
from cj
where cj.课程号='A001' and cj.成绩<60--假设60分及格
--查询xs表里信息管理专业年龄最小的学生的学号，姓名和年龄
select top 1 xs.学号,xs.姓名,datediff(yy,xs.出生时间,getdate()) as 年龄
from xs
order by xs.出生时间 desc
--查询选修课程有不及格的学生的人数
select count(distinct cj.学号) from cj--有点疑问
where cj.成绩<60
--查询选修了A001，J001，J002，J003课程之一的学生的学号，课程好和成绩
select cj.学号,cj.课程号,cj.成绩
from cj
where cj.课程号 in('A001','J001','J002','J003')
--查询课程学分低于3分和高于5分的课程号，课程名以及学分
select kc.课程号,kc.课程名,kc.学分
from kc
where kc.学分 not between 3 and 5
--查询年龄超过35岁的姓张或者姓李的学生的学号，姓名和年龄
select xs.学号,xs.姓名,datediff(yy,xs.出生时间,GETDATE()) as 年龄
from xs
where (datediff(yy,xs.出生时间,GETDATE())>35) and (xs.姓名 like '张%' or xs.姓名 like '李%')
--查询姓张和姓李的男生和女生各有多少人，最后输出姓氏，性别和人数
select SUBSTRING(xs.姓名,1,1) as 姓氏, xs.性别,count(xs.学号) as 人数
from xs
where xs.姓名 like '张%' or xs.姓名 like '李%'
group by SUBSTRING(xs.姓名,1,1), xs.性别