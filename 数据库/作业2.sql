--Ҫ�ʵ����⣺
--		һ��7��10��14��17��20��21��23��24��25��26��27��30-34��
--		����10��
--		����ȫ������û���������ĵ������еĵط������ף�

--һ���Ը�����xsgl���ݿ�������²�ѯҪ�� ��
use xsgl
go
--��xs���������֤���������У�Ҫ����18λ���ַ�����
alter table xs
add sfzh char(18)
--1����ѯ��ֱ�����пεĿγ̵Ŀκţ����������пκš�
select kc.�γ̺�,kc.�γ���,kc.���пκ�
from kc
where kc.���пκ� is not null
--2����ѯ���пκ��ǡ�J001���ſγ̵ĿκźͿ���
select kc.�γ̺�,kc.�γ���
from kc
where kc.���пκ�='J001'
--3��	��ѯ���е����繤��ϵ����ţ�����ͬѧ��ѧ�ź�����
select xs.ѧ��,xs.����
from xs
where xs.רҵ='���繤��' and xs.���� like '[��,��,��]%'
--4��	��ѯ�������繤�̺���Ϣ����רҵѧϰ��ѧ����ѧ�ź�������ϵ�𣬲��Բ�ѯ�������רҵ�������ѧ�ŵĽ�������
select xs.ѧ��,xs.����,xs.רҵ
from xs
where xs.רҵ not in('���繤��','��Ϣ����')
order by xs.רҵ asc,xs.ѧ�� desc
--5��	��ѯÿ�ſβ������ѧ������������ʾ�κź�����
select cj.�γ̺�,COUNT(*)
from cj
where cj.�ɼ�<60
group by cj.�γ̺�
--6��	��ѯ���䲻��30-35֮������繤��ϵ��ѧ����ѧ�ţ�����������
select xs.ѧ��,xs.����,DATEDIFF(yy,xs.����ʱ��,getdate()) as '����'
from xs
where xs.רҵ='���繤��' and DATEDIFF(yy,xs.����ʱ��,getdate()) not between 30 and 35
--7��	��ѯû��ѡ�ޡ�J001���ſγ̵�ѧ����ѧ�ţ�ע��ȥ���ظ���Ԫ�飩
select distinct xs.ѧ��
from xs
where xs.ѧ�� not in (select cj.ѧ�� from cj where cj.�γ̺�='J001')
--8��	��ѯÿ��ѧ����ѧ�ţ�������������ݣ�����������������Ϊchusheng 
select xs.ѧ��,xs.����,YEAR(xs.����ʱ��) as 'chusheng'
from xs
--9. ��ѯÿ��ѧ����ѧ�ţ������ͳ������ڣ��������ڸ������֤�����ѯ��
select xs.ѧ��,xs.����,SUBSTRING(xs.sfzh,7,8) as '��������'
from xs--����δ�������֤�������ݣ��������һ��ȫNULL���б����Ѿ������ǰ���д��룩
--10.��ѯѡ��J001�γ̳ɼ�������һ��ͬѧ��ѧ�źͳɼ�
select cj.ѧ��,cj.�ɼ�
from cj
where cj.�γ̺�='j001' and cj.�ɼ� in(
	select top 1 cj.�ɼ�
	from cj
	where cj.�γ̺�='j001'
	order by cj.�ɼ� desc
)
--11. ��ѯ���������к��С��������ߡ�������ͬѧ��ѧ�ţ�����
select xs.ѧ��,xs.����
from xs
where xs.���� like '%[��,��]%'
--12. ��ѯ��Ϣ����רҵ���䳬��20���ѧ��������
select COUNT(*)
from xs
where xs.רҵ='��Ϣ����' and DATEDIFF(yy,xs.����ʱ��,getdate())>20
--13. ��ѯƽ���ɼ�����80�ֵĿγ̵Ŀγ̺ź�ƽ���ɼ�
select cj.�γ̺�,AVG(cj.�ɼ�)
from cj
group by cj.�γ̺�
having AVG(cj.�ɼ�)>80
--14. ��ѯÿ��רҵ�������ŵ�����
select xs.רҵ,COUNT(*) as '����'
from xs
where xs.���� like '��%'
group by xs.רҵ--����������Բ��������ŵ��޷����
--�������Լ�yy��һ��������
select xs1.רҵ,COUNT(xs2.ѧ��)
from xs as xs1 left outer join(select* from xs where xs.���� like '��%')as xs2 on xs1.ѧ��=xs2.ѧ��
group by xs1.רҵ
--15. ��ѯ�������ϵ�����������û�и��գ�
select SUBSTRING(xs.����,1,1) as '����',COUNT(*) as '����'
from xs
group by SUBSTRING(xs.����,1,1)--gruopby������Ҳ�������б�����������Ľ��
--16.��ѯѡ�޿γ̳���5�ŵ�ѧ����ѧ�ź�ѡ���������Լ�ƽ���ɼ�
select cj.ѧ��,COUNT(*) as 'ѡ������',AVG(cj.�ɼ�) as 'ƽ���ɼ�'
from cj
group by cj.ѧ��
having COUNT(*)>5
--17. ��ѯѡ�ޡ�J001���γ̵ĳɼ�����ǰ���ѧ����ѧ�źͳɼ�
select top 5 with ties cj.ѧ��,cj.�ɼ�
from cj
order by cj.�ɼ� desc--����ǰ����ô��⣿
--�����ͬ����˳�ӵĻ���top5+withties�Ϳ��Ը㶨�����Ҫ���У�����ʹ��Ƕ�ײ�ѯ
--18.��ѯÿ��ѧ������ͷֺ�ѡ������
select cj.ѧ��, MIN(cj.�ɼ�) as '��ͷ�',COUNT(cj.�γ̺�) as 'ѡ������'
from cj
group by cj.ѧ��
--19. ��ѯ����רҵ�����Ա������
select xs.רҵ,xs.�Ա�,COUNT(xs.ѧ��) as '����'
from xs
group by xs.רҵ,xs.�Ա�
--20.��ѯ����רҵ����������
select xs.רҵ,COUNT(xs.ѧ��) as '����'
from xs
where xs.�Ա�='��'
group by xs.רҵ--��14һ��������
--21. �г��ж������Ͽγ̣������ţ��������ѧ����ѧ�ż���ѧ����ƽ���ɼ���
select cj.ѧ��,AVG(cj.�ɼ�)as'ƽ����'
from cj
where cj.ѧ�� in(
	select cj.ѧ��
	from cj
	where cj.�ɼ�<60
	group by cj.ѧ��
	having COUNT(cj.�γ̺�)>=2
)
group by cj.ѧ��
--22. ��ʾѧ�ŵ���λ���ߵ���λ��1��2��3��4����9��ѧ����ѧ�š��������Ա����估רҵ��
select xs.ѧ��,xs.����,xs.�Ա�,DATEDIFF(yy,xs.����ʱ��,getdate()) as '����',xs.רҵ
from xs
where SUBSTRING(xs.ѧ��,5,1) in('1','2','3','4','9') or SUBSTRING(xs.ѧ��,6,1) in('1','2','3','4','9')
--23. ��ʾѡ�޿γ�������ѧ�ż�ѡ�޿γ������ٵ�ѧ�ţ�
select cj.ѧ��,COUNT(cj.�γ̺�)as'ѡ������'
from cj
group by cj.ѧ��
having COUNT(cj.�γ̺�) in(
	select top 1 COUNT(cj.�γ̺�)
	from cj
	group by cj.ѧ��
	order by COUNT(cj.�γ̺�) desc
)--һ�仰�ܸ㶨��
--24. ��ѯѡ����A001����A002����J001����J002�γ̵�ѧ����ѧ�źͿγ̺�
select cj.ѧ��,cj.�γ̺�
from cj
where cj.�γ̺� in('a001','a002','j001','j002')--��Ҳ�У�
--25. ��ѯ����Ϊ�����ֵĲ�ͬ���ϵ�������������ϣ�������
select SUBSTRING(xs.����,1,1) as '����',COUNT(xs.ѧ��) as '����'
from xs
where LEN(xs.����)=2--ͨ������⻹���е㲻����
group by SUBSTRING(xs.����,1,1) 
--26. ��ѯѡ����A001����A002����J001����J002�γ̵�ѧ���Ŀγ̺ţ��γ�����ѡ������
select cj.�γ̺�,kc.�γ���,COUNT(cj.ѧ��)as'ѡ������'
from cj inner join kc on cj.�γ̺�=kc.�γ̺�
where cj.�γ̺� in ('A001','A002','J001','J002')
group by cj.�γ̺�,kc.�γ���
having COUNT(cj.ѧ��)>0--û��������
--27.��ѯÿ��ѧ����ѧ�ţ������Լ��ɼ�����Ŀγ�����
select xs.ѧ��,xs.����,COUNT(cj1.�γ̺�)as'��������'
from xs left outer join (select * from cj where cj.�ɼ�>=60)as cj1 on xs.ѧ��=cj1.ѧ��
group by xs.ѧ��,xs.����
--28. ��ѯÿ��ѧ����ѧ�ţ������Լ�ѡ��������ƽ���ɼ�
select xs.ѧ��,xs.����,COUNT(cj.�γ̺�)as'ѡ������',AVG(cj.�ɼ�)as'ƽ���ɼ�'
from xs left outer join cj on xs.ѧ��=cj.ѧ��
group by xs.ѧ��,xs.����
--29. ��ѯѡ��ѡ�����ݽṹ�Ͳ���ϵͳ�Ŀγ�����ѡ������
select kc.�γ���,COUNT(cj.ѧ��)as'ѡ������'
from kc inner join cj on kc.�γ̺�=cj.�γ̺�
group by kc.�γ���
having kc.�γ��� in('���ݽṹ','����ϵͳ')
--30. ��ѯѡ�������������˵Ŀγ̺źͿγ����Լ��ÿγ̵���߷�
select kc.�γ̺�,kc.�γ���,MAX(cj.�ɼ�) as '��߷�'
from kc inner join cj on kc.�γ̺�=cj.�γ̺�
group by kc.�γ̺�,kc.�γ���
having COUNT(cj.ѧ��)>5
--31.Ϊkc���������пκ������У�Ҫ������Ϊkc��ο������������
alter table kc
add ���пκ� char(10)

alter table kc
add constraint FK_KC foreign key(���пκ�) references kc(�γ̺�)
--32. Ϊѡ�α����ѧ�ŵ�����������Ϊѡ�α���ӿγ̺ŵĽ�������
create nonclustered index MY_INDEX_0000 on xs(ѧ��)
create nonclustered index MY_INDEX_0001 on cj(�γ̺� desc)
exec sp_helpindex xs
exec sp_helpindex cj--�洢���̵Ĳ�������Ҫ������������
--33. Ϊxs�����רҵ����ѧ�Ž��������
create nonclustered index MY_INDEX_0520 on xs(רҵ,ѧ�� desc)
exec sp_helpindex xs
--34. ΪXS�����רҵ������ľۼ�������ע������Ѿ�������ۼ���������ɾ���������þۼ�����֮���������������Լ��
exec sp_helpindex xs
--alter table xs drop constraint PK_xs--ֱ��ɾ���ᱨ��Լ�� 'PK_xs' ���ɱ� 'cj' �����Լ�� 'FK_cj_xs' ���á���
--drop index xs.PK_xs--ֱ��ɾ���Ҳ�ᱨ������������� 'xs.PK_xs' ��ʽ��ʹ�� DROP INDEX�������������� PRIMARY KEY Լ����ǿ��ִ�С�
--�����ǽ��������
exec sp_helpindex cj
exec sp_helpconstraint cj--��һ��������ѯԼ������

alter table cj
drop constraint FK_cj_xs

exec sp_helpconstraint xs--ͬ��

alter table xs
drop constraint PK_xs

create clustered index myindex on xs(רҵ)--OKһ·˳��
alter table xs
add constraint myzm primary key(ѧ��)--������û���κ�������߹
--PS��������Լ��������һ��������ǰ���û��޸У��ٶȷ�����⣩��������������
--�������루Լ������ʱ�������û�оۼ��������Զ������ۼ����������Ҳ��ܵ���ɾ����ֻ��ɾ������Լ��
--�����ȴ����ۼ��������ٴ�������Լ��
--�Զ��������������ƺ�Լ����������������汾�йأ��ֱ���ϵͳ�洢����SC_HELPINDEX,SC_HELPCONSTRAINT�鿴
--35. ��ѯ����ǿ����ͬһ��רҵѧϰ��ѧ����ѧ�ţ�������רҵ
select xs1.ѧ��,xs1.����,xs1.רҵ
from xs as xs1 inner join xs as xs2 on xs1.רҵ<>xs2.רҵ--�ú�������������ӵĹ�������ôִ�еģ�xs1��xs2����������ʲô����������
where xs2.����='��ǿ'

--���������ϵڶ��¿κ�ϰ���4��SPJ���ݿ�����ѯ�� 
use spj
go
--1��	��Ӧ����J1����Ĺ�Ӧ�̺���SNO
select distinct spj.sno
from spj
where spj.jno='j1'
--2��	���ѯÿ������ʹ�ò�ͬ��Ӧ�̵�����ĸ���
select j.jno,spj.sno,COUNT(SPJ.qty)as'����'
from j left outer join spj on j.jno=spj.jno
group by j.jno,spj.sno
--3��	��Ӧ����ʹ�����P3��������200�Ĺ��̺�JNO
select spj.jno--����˵�������ѾۺϺ������������ѯ��������ôֻ����groupby��
from spj
where spj.pno='p3'
group by spj.jno 
having SUM(spj.qty)>200
--4��	����ɫΪ��ɫ����ɫ�����������ź�����
select p.pno,p.pname
from p
where p.color in('��','��')
--5��	��ʹ�����������200-400֮��Ĺ��̺�
select spj.jno--����˵�������ѾۺϺ������������ѯ��������ôֻ����groupby��
from spj
group by spj.jno
having SUM(spj.qty) between 200 and 400
--6��	��ѯÿ�����������ţ��Լ�ʹ�ø�����Ĺ�������
select spj.pno,COUNT(distinct jno)as'ʹ�õĹ�����Ŀ'
from spj
group by spj.pno
--7��	��ѯÿ��������ʹ�õĲ�ͬ��Ӧ�̹�Ӧ�����������������̺ţ���Ӧ�̺ź�����������
select spj.jno,spj.sno,SUM(spj.qty)as'�������'
from spj
group by spj.jno,spj.sno
--8��	��ѯû�й�Ӧ�κ�����Ĺ�Ӧ�̺ţ���Ӧ������
select s.sno,s.sname
from s left outer join spj on s.sno=spj.sno
where spj.pno is null
--9��	��ѯʹ����S1��Ӧ�̹�Ӧ�ĺ�ɫ����Ĺ��̺ź͹�����
select j.jno,j.jname
from s inner join spj on s.sno=spj.sno inner join p on spj.pno=p.pno inner join j on spj.jno=j.jno
where s.sname='s1' and p.color='��'

select j.jno,j.jname
from s , spj,p,j 
where s.sno=spj.sno and  spj.pno=p.pno and  spj.jno=j.jno
 and s.sno='s1' and p.color='��'
--10.	��ѯ�������̵Ĺ��̺ţ��������Լ���ʹ�õĵ��������
select j.jno,j.jname,ISNULL(SUM(spj.qty),'0')as'ʹ���������'
from j left outer join spj on j.jno=spj.jno
group by j.jno,j.jname
--�����Է�����������
--sum(column) �Ƕ������е�ֵ��͡�
--���û�鵽���ݣ�sum��ֵΪnull
--����鵽��������һ��ֵΪnull��sum��ֵΪnull
--����鵽������null��Ҳ�в���null�ģ���ôsum��ֵΪ���зǿ�ֵ�ĺ͡�

--������Northwind���ݿ����һ�²�ѯ
--�����ţ�https://www.cnblogs.com/camelroyu/p/4284274.html
use Northwind
go
--1.��ѯÿ�����������Ʒ���������ܽ���ʾ�����ţ��������ܽ��
select [Order Details].OrderID,COUNT([Order Details].ProductID),SUM([Order Details].UnitPrice*[Order Details].Quantity*[Order Details].Discount)
from [Order Details]
group by [Order Details].OrderID--����ô
--2. ��ѯÿ��Ա����7�·ݴ�����������
select Orders.EmployeeID,COUNT(Orders.OrderID)as'��������'
from Orders
where MONTH(Orders.ShippedDate)=7
group by Orders.EmployeeID
--3. ��ѯÿ���˿͵Ķ�����������ʾ�˿�ID����������
select Orders.CustomerID,COUNT(Orders.OrderID)as'��������'
from Orders
group by Orders.CustomerID
--4. ��ѯÿ���˿͵Ķ��������Ͷ����ܽ��
select Customers.CustomerID,COUNT(Orders.OrderID)as'��������',SUM([Order Details].UnitPrice*[Order Details].Quantity*[Order Details].Discount)
from Customers left outer join Orders on Customers.CustomerID=Orders.CustomerID full outer join [Order Details] on Orders.OrderID=[Order Details].OrderID
group by Customers.CustomerID
--5. ��ѯÿ�ֲ�Ʒ�������������ܽ��
select Categories.CategoryID,SUM([Order Details].Quantity)
from Categories left outer join Products on Categories.CategoryID=Products.CategoryID left outer join [Order Details] on Products.ProductID=[Order Details].ProductID
group by Categories.CategoryID
--��ǣ��򹤿���ۣ�CRUD��������������
--С��bb����˵�����˾���Ǹ�����ġ���������