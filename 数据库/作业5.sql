/**
 * 数据库实验五
 * @author Steve
 * @version 1.0.0 2021-11-20
 */

--1．创建一windows用户（名字自定），用sql语句建立windows验证模式的登录名。默认数据库为student
/* 先在cmd下输入：net user user1 /add */
create login [LAPTOP-VB0Q40F3\user1] from windows with default_database=student
--2．用sql语句和系统存储过程建立登录名sqluser,密码为1234 
create login sqluser with password='1234'
exec sp_addlogin 'sqluser','1234'
--3．为student数据库新建用户u1，其登录名为sqluser。
use student
create user u1 for login sqluser
--4．新建登录usersf，并将其加入到sysadmin固定服务器角色中。
use student
create login usersf with password=''
/* 请注意：创建用户或添加数据库角色必须指定use哪个数据库！*/
exec sp_addsrvrolemember usersf,sysadmin
--5．将student用户usersf（登录名为usersf）加入到db_owner角色中，使其全权负责该数据库,并验证其权限。
use student
create user usersf for login usersf
exec sp_addrolemember db_owner,usersf
--6．为SPJ数据库新建用户u2，u3，其登录名分别为u2，u3。
use spj
create login u2 with password='你贤惠我还贤惠呢',default_database=spj
create login u3 with password='你这瓜保熟吗',default_database=spj
create user u2 for login u2
create user u3 for login u3
--（1）授予用户u2对S表有SELECT 权，对P表颜色（COLOR）具有更新权限；
grant select
on s
to u2
with grant option
grant update
on p
to u2
with grant option
--（2）u2将其拥有的权限授予u3；
/* 用u2登录后执行下列sql语句 */
use spj
grant all
on s
to u3

grant all
on p
to u3
--（3）用sql语句逐一验证u2、u3所获得的权限。
/* 用u2，u3登录后分别运行下列SQL语句 */
select* from s
select* from p
update s
set s.city='x'
update p
set p.color='x'
/* 无论哪个用户，运行结果应当依次为：成功，失败，失败，成功 */
--（4）撤销用户u3所获得的权限，并验证。
revoke update
on p
from u3
/* 登录到u3后执行下列sql语句，如果失败说明权限已经收回 */
update p
set p.color='y'
--7.在student数据库中建立角色operate,该角色具有对student和course表的查询权限；具有对表sc的插入和修改权限。
use student
create user u3 for login u3
exec sp_addrole operate
grant select
on student
to operate
--8.拒绝用户u1对sc表的修改权限。
deny update
on sc
to u1
--9.使用存储过程将角色operate赋给用户u1,并用sql语句验证其权限。（特别验证u1对sc表的修改权限）
exec sp_addrolemember operate,u1
/* 用u1登录后执行下列sql语句 */
insert into sc(grade)
values (1)
update sc
set sc.grade=60
where sc.grade<60
/* 结果应当是两句话都可以走执行成功 */
--10. 在student数据库中创建架构（schema）teacher指定给用户teacher（也就是要先创建一个teacher用户）
create user teacher for login teacher
create schema teacher authorization teacher
--11.	在已创建的teacher架构中创建“tea”表，表结构为（tno(编号), tname(姓名), tsd（专业）,tphone, te_mail）
--(数据类型和长度自己定义)，
--通过teacher架构为teacher用户设置查询权限，
--验证teacher用户对表tea是否具有select权限和delete权限，为什么？
create table student.teacher.tea(
	tno int primary key,
	tname char(20) not null,
	tsd char (20),
	tphone char(11),
	te_mail char(20),
)
grant select,update
on schema :: teacher
to u1
/* u1现在应该可以更新tea表，因为拥有架构的权限相当于拥有架构里面所有对象的权限 */
--12.将对计算机系所有学生的 student表的所有操作权限授予给用户u1,。
create view MyView
as
select*
from student
where student.sdept='CS'
grant all
on MyView
to u1

/* 问：
   1.schema在授权过程当中到底起了什么样的作用
   2.default_database到底有什么用
*/