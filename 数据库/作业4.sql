/**
 *���ݿ�ʵ����
 *@author Steve
 *@version 1.0.1 2021-11-5
 */

--ʵ����Ҫ��
--һ����xsgl���ݿ�������в���Ҫ��
use xsgl
--1.	����ȫ��ѧ����ѡ���˵Ŀγ̵���ѧ�ָ�Ϊ4ѧ�֡�
update kc
set kc.ѧ��=4
where kc.�γ̺� in(/*һ��where�־�ӷ�Χ��ת��Ϊselect����*/
	select kc.�γ̺�
	from kc
	where not exists(
		select* from xs
		where not exists(
			select* 
			from cj
			where xs.ѧ��=cj.ѧ�� and cj.�γ̺�=kc.�γ̺�
		)
	)
)
--2.	��ѧ����ɾ��û��ѡ�ε�ѧ����
/*select xs.ѧ��
from xs
where xs.ѧ�� not in(
	select cj.ѧ�� from cj
)*/

delete 
from xs
where xs.ѧ�� not in(
	select cj.ѧ�� from cj
)
--3.	��ÿ��ѧ����ƽ���֣��ֺܷ�ѡ���������뵽���ݿ��У�ѧ�ţ�������ƽ���֣��ܷ֣�ѡ��������
/*�Ƚ���*/
create table mytable1(
	ѧ�� char(10) primary key,
	���� char(10),
	ƽ���� numeric(18,0),
	�ܷ� numeric(18,0),
	ѡ������ int
)
insert 
into mytable1(ѧ��,����,ƽ����,�ܷ�,ѡ������)
select xs.ѧ��,xs.����,AVG(cj.�ɼ�),SUM(cj.�ɼ�),COUNT(cj.�γ̺�)
from xs left join cj on xs.ѧ��=cj.ѧ��
group by xs.ѧ��,xs.����
--4.	����ÿ�ſγ̵�ƽ���ֺ�ѡ����������ͼ���γ̺ţ��γ�����ƽ���֣�������
create view MyView1(�γ̺�,�γ���,ƽ����,����)/*�����Ϊʲô��챨������û����*/
as
select kc.�γ̺�,kc.�γ���,AVG(cj.�ɼ�),COUNT(cj.ѧ��)
from kc left join cj on kc.�γ̺�=cj.�γ̺�
group by kc.�γ̺�,kc.�γ���
--5.	����ǿͬѧ��ѧ����ɾ������ʾӦ����ɾ����ǿͬѧ��ѡ�μ�¼��
delete
from cj
where cj.ѧ��=(
	select xs.ѧ��
	from xs
	where xs.����='��ǿ'
)
delete
from xs
where xs.����='��ǿ'
--6.	����һ��ѡ�μ�¼�����������Լ�ѡ��
insert
into xs(ѧ��,����,�Ա�,����ʱ��,רҵ,��ѧ��,��Ƭ,��ע)
values('2000800099','������','��','2000-1-1','�ƺ�',0,null,null)/*���±���гû�ҷŸ�����Ϣ*/

insert 
into cj(ѧ��,�γ̺�,�ɼ�)
values('2000800099','J005','0')/*ȡʵ������ĺ�10λ��˭�ĺ�˭�����������Ϊ֮*/
--7.	�������繤��רҵ��ѧ����ѡ����Ϣ����ͼ��Ҫ����ͼ������ѧ�ţ�������רҵ���γ̺ţ��γ������ɼ�
create view YourView(ѧ��,����,רҵ,�γ̺�,�γ���,�ɼ�)
as
select xs.ѧ��,xs.����,xs.רҵ,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from xs left join cj on xs.ѧ��=cj.ѧ�� left join kc on cj.�γ̺�=kc.�γ̺�
where xs.רҵ='���繤��'
--8.	��ѯ���繤��רҵ�ĸ��Ƶ�ƽ���ɼ���Ҫ��ʹ�õ�7�ⴴ������ͼ���в�ѯ
select YourView.�γ̺�,AVG(YourView.�ɼ�)
from YourView
group by YourView.�γ̺�
--9.	��ѯ����Ϣ����רҵ��ѧ����ѡ���˵Ŀγ̵Ŀγ̺ţ��γ���
select kc.�γ̺�,kc.�γ���
from kc
where not exists(
	select*
	from xs
	where xs.רҵ='��Ϣ����'
	and not exists(
		select *
		from cj
		where xs.ѧ��=cj.ѧ�� and cj.�γ̺�=kc.�γ̺�
	)
)
--10.	��ʾѡ�޿γ�������ѧ�ż�ѡ�޿γ������ٵ�ѧ�ţ�������ʹ��������ʵ�֣�
select top 1 with ties sublist.ѧ��
from (
	select xs.ѧ��,xs.����,COUNT(cj.�γ̺�)
	from  xs left join cj on xs.ѧ��=cj.ѧ��
	group by xs.ѧ��,xs.����
)
as sublist(ѧ��,����,ѡ����Ŀ)
order by sublist.ѡ����Ŀ desc

select top 1 with ties sublist.ѧ��,sublist.����
from (
	select xs.ѧ��,xs.����,COUNT(cj.�γ̺�)
	from  xs left join cj on xs.ѧ��=cj.ѧ��
	group by xs.ѧ��,xs.����
)
as sublist(ѧ��,����,ѡ����Ŀ)
order by sublist.ѡ����Ŀ
--11.	��ѯÿ��ѧ���ɼ������Լ���ƽ���ɼ���ѧ�ţ��������γ̺źͳɼ���ʹ��������ʵ�֣�
select xs.ѧ��,xs.����,kc.�γ̺�,cj.�ɼ�
from xs left join cj on xs.ѧ��=cj.ѧ�� left join kc on cj.�γ̺�=kc.�γ̺�
where cj.�ɼ�>(
	select sublist.ƽ����
	from(
		select cj1.ѧ��,AVG(cj1.�ɼ�)
		from cj as cj1
		group by cj1.ѧ��
	)as sublist(ѧ��,ƽ����)
	where xs.ѧ��=sublist.ѧ��
)
--12.	�Լ���֤with check option�����á�
/*����˵����Ĳ���*/
create view View2
as
select xs.ѧ��
from xs

create view V3
as
select xs.ѧ��,xs.����,xs.רҵ
from xs where xs.רҵ='�ƺ�'

insert into V3
values('2000800054','�ڷ���','��')/*�ųɹ���*/

create view V4
as
select xs.ѧ��,xs.����,xs.רҵ
from xs where xs.רҵ='�ƺ�'
with check option

insert into V4
values('��','���','����')/*ok�ɹ�����*/
--13.	����һ�����繤��ϵ��ѧ��������Ϣ����ͼMA_STUDENT���ڴ���ͼ�Ļ����ϣ��ٶ���һ����רҵŮ����Ϣ����ͼ��Ȼ����ɾ��MA_STUDENT���۲�ִ�������
create view MA_STUDENT
as
select*
from xs
where xs.רҵ='���繤��'

create view Girlfriends/*�Ǻǡ�����*/
as
select*
from MA_STUDENT
where MA_STUDENT.�Ա�='Ů'

drop view MA_STUDENT/*Ϊɶ���а�*/
--14.	��ѯ�ͳ���ͬ���ѧ����ѧ�ź������Լ�����
select xs.ѧ��,xs.����,DATEDIFF(YY,xs.����ʱ��,GETDATE())as '����'
from xs
where DATEDIFF(YY,xs.����ʱ��,GETDATE())=(
	select DATEDIFF(YY,xs1.����ʱ��,GETDATE())
	from xs as xs1
	where xs1.����='����'
)
--15.	��ѯû�б����繤��ȫ����ѧ����ѡ�޵Ŀγ̵Ŀγ̺źͿγ��������Ա����繤��רҵ�Ĳ���ѧ��ѡ�ޣ�
select kc.�γ̺�,kc.�γ���
from kc
where exists(
	select *
	from xs
	where xs.רҵ='���繤��'
	and
	not exists(
		select*
		from cj
		where xs.ѧ��=cj.ѧ�� and cj.�γ̺�=kc.�γ̺�
	)
)
--16.	��ѯû��ѡ�����ݽṹ������ϵͳ��Ӣ�����ſε�ѧ����ѧ�ţ��������γ̺ţ��γ����ͳɼ�
select xs.ѧ��,xs.����,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from xs left join cj on xs.ѧ��=cj.ѧ�� left join kc on cj.�γ̺�=kc.�γ̺�
where xs.ѧ�� not in(
	select cj1.ѧ��
	from cj as cj1
	where cj1.�γ̺� in(
		select kc1.�γ̺�
		from kc as kc1
		where kc1.�γ��� in('���ݽṹ','����ϵͳ','Ӣ��')
	)
)
--17.	��û��ѡ�ε�ѧ������ѧ������Ϊ0
update xs
set xs.��ѧ��=0
where xs.ѧ�� not in(
	select distinct cj.ѧ��
	from cj
)
--����ʹ��Northwind���ݿ�������в���
use Northwind
--1. ��Ա��lastname��: Peacock����Ķ����й�����������50����Ʒ�ۿ۸�Ϊ����
update [Order Details]
set Discount=0.3
where [Order Details].OrderID in(
 select [Order Details1].OrderID
 from [Order Details] as [Order Details1] inner join Orders on [Order Details].OrderID=Orders.OrderID inner join Employees on Orders.EmployeeID=Employees.EmployeeID
 where Employees.LastName='Peacock' and [Order Details1].Quantity>50
)
--2. ɾ��lastname��: Peacock��������ж���
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
--3. ��ÿ�������Ķ�����ţ��˿ͱ�ţ���Ʒ���������ܽ����뵽���ݿ���
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
--4. ����һ���µĶ�����Ҫ��ö�����������Ʒ���Ϊ5,7,9����Ʒ����5����Ʒ����10����7������20����9������15������û���ۿۣ�
insert into Orders(CustomerID,EmployeeID)
values('ALFKI',1)
/*�Ȳ��붩��������
��Ϣ 544������ 16��״̬ 1���� 256 ��
�� IDENTITY_INSERT ����Ϊ OFF ʱ������Ϊ�� 'Orders' �еı�ʶ�в�����ʽֵ��
���ʱ��: 2021-11-05T11:33:07.1005437+08:00*/

select* from Orders
where Orders.CustomerID='ALFKI'
/*�ҵĻ����Ͻ����11078*/
/*Ȼ���Ƕ���ϸ��*/
insert into [Order Details](OrderID,ProductID,UnitPrice,Quantity,Discount)
values(11078,5,0,10,0),
(11078,7,0,20,0),
(11078,9,0,15,0)
/*��ҪǮ���Ѫ(��y��,��)�q */
--5. ��ÿ��ÿ��Ա���������������Ͷ������ܽ���Ϊ��ͼ
create view HerView(EmployeeID,Years,OrderCnt,OrderSumPrice)
as
select Orders.EmployeeID,YEAR(Orders.OrderDate),COUNT(Orders.OrderID),SUM([Order Details].Quantity*[Order Details].UnitPrice*(1-[Order Details].discount))
from Orders inner join [Order Details] on Orders.OrderID=[Order Details].OrderID
group by Orders.EmployeeID,YEAR(Orders.OrderDate)
--6. ������CustomerID�ǡ�VINET���û��������ȫ����Ʒ���û���CustomerID��CompanyName��
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
--7. ����ȫ���˿Ͷ����������Ʒ����Ʒ��ź���Ʒ���͵��۴���Ϊһ����ͼproa
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
--8. ����ȫ���˿Ͷ����������Ʒ�ĵ��ۼ���5Ԫ
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
--9. ɾ�������ܽ������50Ԫ�Ķ�����ϸ
delete from [Order Details]
where [Order Details].OrderID in(
	select [Order Details].OrderID
	from [Order Details]
	group by [Order Details].OrderID
	having SUM([Order Details].UnitPrice*[Order Details].Quantity*(1-[Order Details].Discount))<50
)
