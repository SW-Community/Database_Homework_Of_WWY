/**
 * ���ݿ�ʵ����
 * @author Steve
 * @version 1.0.0 2021-11-16
 */

--��xsgl���ݿ�������²�����
use xsgl
--1.	Ϊxs���ѧ��������Ĭ��ֵΪ18
alter table xs
add constraint C1 default 18 for ��ѧ��
--2.	Ϊcj�����ñ�ʶ�У������Լ��𣩣���ʼ��Ϊ2001������Ϊ1
alter table cj
add ��ʶ�� int identity(2001,1)
select* from cj
--3.	Ϊxs����Ա�������Լ�������Ա�ȡֵΪ�л���Ů
alter table xs
add constraint C2 check (�Ա� in('��','Ů'))
--4.	����checkԼ����Ҫ��ѧ��ѧ��sno����Ϊ9λ�����ַ����Ҳ�����0��ͷ���ڶ���λ��Ϊ0
alter table xs
with nocheck /* ������ѧ��ȫ��10λ�ģ����Ա���with nocheck�� */
add constraint C3 check (ѧ�� like '[1-9]00[0-9][0-9][0-9][0-9][0-9][0-9]')

/* ��֤һ�� */
insert into xs(ѧ��,����)
values('100333333','������')

insert into xs(ѧ��,����,��ѧ��)
values('03','����',20)
--5.	Ҫ��ѧ�����ѧ������������2-8֮��
alter table xs
add constraint C4 check(len(����)between 2 and 8)
--6.	��xs����������С����֤���롱����Ϊ�����Լ��Ϊ18λ�����ַ�����Ϊ0�����֣����һλ������1-9���ֻ���X������λ��Ϊ0-9�����֣�
alter table xs
add ���֤���� char(18) check(���֤���� like'[^0][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9][1-9,X,x]')
--7.	��cj�����Ӽ���ɾ���;ܾ��޸ĵ�ѧ�źͿγ̺ŵ�����Լ����
alter table cj
add constraint C5 foreign key(ѧ��)references xs(ѧ��)
on delete cascade
alter table cj
add constraint C6 foreign key(�γ̺�)references kc(�γ̺�)
on delete cascade
--8.	���������lendt(bno������ţ�,sno��ѧ�ţ�,ldate���������ڣ�,rdate��Ӧ�����ڣ���relend���Ƿ����裩
create table lendt(
	bno int not null,
	sno char(10) not null,
	ldate datetime,
	rdate datetime,
	relend bit
)
--��Ϊ�ñ������ĸ�Լ��������
--��1����������Լ����bno,sno��
alter table lendt
add constraint C7 primary key(bno,sno)
--��2��Ϊ������������Ĭ��ֵԼ����Ĭ��ֵΪ��ǰ����
alter table lendt
add constraint C8 default getdate() for ldate
--��3��ΪӦ����������Ĭ��ֵԼ����Ĭ��ֵΪ��ǰ����+30��
alter table lendt
add constraint C9 default getdate()+convert(datetime,30) for rdate
--��4��Ϊ�Ƿ���������Ĭ��ֵԼ����Ĭ��ֵΪ��
alter table lendt
add constraint C10 default 0 for relend
go
--9.	��������167ҳ��5.6�ڶ���������в�����
/* 
   ����MSSQLSERVER��֧�ֶ��ԣ���˺ܿ�ϧ��Щ����һ��Ҳ������
   ���ǿ����ô��������ʵ����ͬЧ��
*/
--��1��	�޶�ÿ��רҵ��ѡ���������ܳ���10��
create trigger T1 on cj
after insert
as
if 10<(
	select COUNT(cj.�γ̺�)
	from xs inner join cj on xs.ѧ��=cj.ѧ��
	group by xs.רҵ
)
	rollback transaction
go
--��2��	�޶�ÿ��ѧ������Ҫѡ��6�ſγ�
create trigger T2 on cj
after delete
as
if 6>(
	select COUNT(cj.�γ̺�)
	from xs left join cj on xs.ѧ��=cj.ѧ��
	group by xs.ѧ��
)
	rollback transaction
go
--10.	��ƴ�����ʵ�֣����һ��ѧ����רҵ�����繤��רҵ����ô������ѧ�ֲ�������22�֣�
--Ҳ������������һ���µ����繤��רҵ��ѧ�����߸������רҵ��ѧ����ѧ������22�ֵĻ���
--�ͽ����Ϊ22ѧ�֡�
create trigger T3 on xs
after insert,update
as
if exists (
	select* from inserted
	where inserted.רҵ='���繤��' and inserted.��ѧ��<22
)
begin
	update xs
	set xs.��ѧ��=22
	where xs.ѧ�� in (
		select inserted.ѧ��
		from inserted
		where inserted.רҵ='���繤��' and inserted.��ѧ��<22
	)
end
go
--11.	������ʦ���̹���ţ�������רҵ��ְ�ƣ����ʣ���
--���ʱ仯���̹���ţ�ԭ���ʣ��¹��ʣ�����ƴ�����ʵ�ֽ��ڵĹ��ʲ��õ���4000Ԫ��
--�������4000Ԫ���Զ���Ϊ4000Ԫ��
--��������Ա�����Ա���Ĺ��ʷ����仯�����ʱ仯�����һ����¼��
--�����̹���ţ�ԭ���ʣ��¹��ʡ�
create table js(
	�̹���� char(10),
	���� nchar(10),
	רҵ char(16),
	ְ�� char(16),
	���� int
)

create table gzbh(
	�̹���� char(10),
	ԭ���� int,
	�¹��� int
)
go

create trigger T4 on js
after insert,update
as
if exists(
	select* from inserted
	where inserted.����<4000
)
begin
	update js
	set js.����=4000
	where js.�̹���� in(
		select inserted.�̹���� from inserted
		where inserted.����<4000
	)
end
go

create trigger T5 on js
after update
as
begin
	insert into gzbh(�̹����,ԭ����,�¹���)
	select inserted.�̹����,deleted.����,inserted.����
	from inserted inner join deleted on inserted.�̹����=deleted.�̹����
end
go
--12.	��ƴ�����ʵ�����һ��ѧ��תרҵ�ˣ���ô���һ����Ϣ��ʾ��ѧ�����ſγ̵�ƽ���֣�
--���������ѧ���Ǽ�����а�רҵ������תרҵ��
create trigger T7 on xs
after update
as
begin
	if UPDATE(רҵ) 
	begin
		if exists(select * from deleted where deleted.רҵ='������а�')
		begin
			print '����Ĳ���ܾ��㣬�����ǻ��ǽ�����ʵ�ɣ��Ͼ���������������'
			rollback transaction
		end
		else
		begin
			declare @pjf numeric(18,0)
			select @pjf=AVG(cj.�ɼ�)
			from xs left join cj on xs.ѧ��=cj.ѧ��
			where xs.ѧ�� in 
			(
				select deleted.ѧ��
				from deleted
			)
			print '���ƽ������'+str(@pjf)+'����ĺܰ�����ϲ��˳�����תרҵ��'
		end
	end
end
go
--13.	��ƴ�����ʵ��ÿ�ſε�ѡ���������ܳ���60�ˣ�ֻ���ǲ���һ��
create trigger T8 on cj
after insert,update
as
begin
	if 60<(
		select COUNT(cj.ѧ��)
		from cj
		group by cj.�γ̺�
		having cj.�γ̺� in	(
			select inserted.�γ̺�
			from inserted
		)
	)
	begin
		rollback transaction
	end
end
go
--14.	��ƴ�����ʵ������ɼ����޸���20�����ϣ��������ʾ��Ϣ���޸ĳɼ�����20�֣������ء���
--�������ѧ����ѡ�μ�¼��
create trigger T9 on cj
after update
as
begin
	if(UPDATE(�ɼ�))
	begin
		declare @xgq numeric(18,0)
		declare @xgh numeric(18,0)
		select @xgq=deleted.�ɼ�
		from deleted
		select @xgh=inserted.�ɼ�
		from inserted
		if @xgh-@xgq>20 or @xgh-@xgq<-20
			print'�޸ĳɼ�����20�֣������ء���ѧ���ǻ������ƣ����������񴦷��֣���������Ҫ�е�����'
	end
end
go
--15.	���һ�ſε�ѧ�ַ������޸ģ� ������ѡ�޸ÿγ̲��Ҽ����ѧ������ѧ��Ҫ����Ӧ���޸ģ�
--�����ѧ�ţ�������ԭ��ѧ�֣�����ѧ�֡�
create trigger T10 on kc
after update
as
begin
	if(UPDATE(ѧ��))
	begin
		declare @yxf smallint
		declare @xxf smallint
		declare @kch char(10)
		select @xxf=inserted.ѧ��
		from inserted
		select @yxf=deleted.ѧ��
		from deleted
		select @kch=inserted.�γ̺�
		from inserted
		declare @delta smallint
		set @delta=@xxf-@yxf
		update xs
		set xs.��ѧ��=xs.��ѧ��+@delta
		where xs.ѧ�� in(
			select cj.ѧ��
			from cj
			where cj.�ɼ�>=60 and cj.�γ̺�=@kch
		)
	end
end
go
--16.	���northwind���ݿ�ʵ�ִ�������ÿ��Ա��ÿ�촦�������������ܳ���100��
--�������100����ܾ���������ʾ�����������������޶
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
		print'���������������޶�'
		rollback transaction
	end
end
--17.	���northwind���ݿ�ʵ�ִ���������orders�����zje�������ܽ������У�
--Ҫ������λС�������ô�����ʵ�ֵ��������µĶ�����ϸ֮���ܽ����µ����������
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
--18.	�ڿγ̱������һ�У�ѡ�����������ô�����ÿ�ſ��������ѡ���ˣ�
--��ô�γ̱����ѡ��������Ӧ�޸ģ�������������ѡ�μ�¼�������
use xsgl
go
alter table kc
add ѡ������ int
go

create trigger T13 on cj
after insert
as
begin
	update kc
	set ѡ������=(
		select COUNT(*)
		from cj
		where cj.�γ̺�=kc.�γ̺�
		group by cj.�γ̺�
	)
	where kc.�γ̺� in
	(select distinct cj.�γ̺� from cj)
end
go
--19.	���ô�����ʵ�����ѧ�������˲��롢���»���ɾ����������������롢���»���ɾ����������
create trigger T14 on xs
after insert,update,delete
as
begin
	declare @cnt1 int
	declare @cnt2 int
	set @cnt1= (select COUNT(*) from inserted)
	set @cnt2= (select COUNT(*) from deleted)
	if(@cnt1<>0 and @cnt2<>0)
		print '����'+str(@cnt1)+'��'
	else if (@cnt1<>0 and @cnt2=0)
		print '���'+str(@cnt1)+'��'
	else if(@cnt1=0 and @cnt2<>0)
		print 'ɾ��'+str(@cnt2)+'��'
end
go
/* 
  ��·ǧ������
  ��ȫ��һ����
  �г����淶��
  ���������ᣡ
*/