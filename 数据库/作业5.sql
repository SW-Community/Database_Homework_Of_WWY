/**
 * ���ݿ�ʵ����
 * @author Steve
 * @version 1.0.0 2021-11-20
 */

--1������һwindows�û��������Զ�������sql��佨��windows��֤ģʽ�ĵ�¼����Ĭ�����ݿ�Ϊstudent
/* ����cmd�����룺net user user1 /add */
create login [LAPTOP-VB0Q40F3\user1] from windows with default_database=student
--2����sql����ϵͳ�洢���̽�����¼��sqluser,����Ϊ1234 
create login sqluser with password='1234'
exec sp_addlogin 'sqluser','1234'
--3��Ϊstudent���ݿ��½��û�u1�����¼��Ϊsqluser��
use student
create user u1 for login sqluser
--4���½���¼usersf����������뵽sysadmin�̶���������ɫ�С�
use student
create login usersf with password=''
/* ��ע�⣺�����û���������ݿ��ɫ����ָ��use�ĸ����ݿ⣡*/
exec sp_addsrvrolemember usersf,sysadmin
--5����student�û�usersf����¼��Ϊusersf�����뵽db_owner��ɫ�У�ʹ��ȫȨ��������ݿ�,����֤��Ȩ�ޡ�
use student
create user usersf for login usersf
exec sp_addrolemember db_owner,usersf
--6��ΪSPJ���ݿ��½��û�u2��u3�����¼���ֱ�Ϊu2��u3��
use spj
create login u2 with password='���ͻ��һ��ͻ���',default_database=spj
create login u3 with password='����ϱ�����',default_database=spj
create user u2 for login u2
create user u3 for login u3
--��1�������û�u2��S����SELECT Ȩ����P����ɫ��COLOR�����и���Ȩ�ޣ�
grant select
on s
to u2
with grant option
grant update
on p
to u2
with grant option
--��2��u2����ӵ�е�Ȩ������u3��
/* ��u2��¼��ִ������sql��� */
use spj
grant all
on s
to u3

grant all
on p
to u3
--��3����sql�����һ��֤u2��u3����õ�Ȩ�ޡ�
/* ��u2��u3��¼��ֱ���������SQL��� */
select* from s
select* from p
update s
set s.city='x'
update p
set p.color='x'
/* �����ĸ��û������н��Ӧ������Ϊ���ɹ���ʧ�ܣ�ʧ�ܣ��ɹ� */
--��4�������û�u3����õ�Ȩ�ޣ�����֤��
revoke update
on p
from u3
/* ��¼��u3��ִ������sql��䣬���ʧ��˵��Ȩ���Ѿ��ջ� */
update p
set p.color='y'
--7.��student���ݿ��н�����ɫoperate,�ý�ɫ���ж�student��course��Ĳ�ѯȨ�ޣ����жԱ�sc�Ĳ�����޸�Ȩ�ޡ�
use student
create user u3 for login u3
exec sp_addrole operate
grant select
on student
to operate
--8.�ܾ��û�u1��sc����޸�Ȩ�ޡ�
deny update
on sc
to u1
--9.ʹ�ô洢���̽���ɫoperate�����û�u1,����sql�����֤��Ȩ�ޡ����ر���֤u1��sc����޸�Ȩ�ޣ�
exec sp_addrolemember operate,u1
/* ��u1��¼��ִ������sql��� */
insert into sc(grade)
values (1)
update sc
set sc.grade=60
where sc.grade<60
/* ���Ӧ�������仰��������ִ�гɹ� */
--10. ��student���ݿ��д����ܹ���schema��teacherָ�����û�teacher��Ҳ����Ҫ�ȴ���һ��teacher�û���
create user teacher for login teacher
create schema teacher authorization teacher
--11.	���Ѵ�����teacher�ܹ��д�����tea������ṹΪ��tno(���), tname(����), tsd��רҵ��,tphone, te_mail��
--(�������ͺͳ����Լ�����)��
--ͨ��teacher�ܹ�Ϊteacher�û����ò�ѯȨ�ޣ�
--��֤teacher�û��Ա�tea�Ƿ����selectȨ�޺�deleteȨ�ޣ�Ϊʲô��
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
/* u1����Ӧ�ÿ��Ը���tea����Ϊӵ�мܹ���Ȩ���൱��ӵ�мܹ��������ж����Ȩ�� */
--12.���Լ����ϵ����ѧ���� student������в���Ȩ��������û�u1,��
create view MyView
as
select*
from student
where student.sdept='CS'
grant all
on MyView
to u1

/* �ʣ�
   1.schema����Ȩ���̵��е�������ʲô��������
   2.default_database������ʲô��
*/