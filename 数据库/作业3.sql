/*	ʵ����Ҫ��	*/
/*	@author Steve	*/
/*	@date 2021.10.17	*/

--һ��	��xsgl���ݿ�������²���
use xsgl
--1.	��ѯû��ѡ��Ӣ���ѧ����ѧ�ţ������Ϳγ̺ţ��γ������ɼ�
select xs.ѧ��,xs.����,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from xs left outer join cj on xs.ѧ��=cj.ѧ�� left outer join kc on cj.�γ̺�=kc.�γ̺�
where xs.ѧ�� not in (
	select cj1.ѧ��
	from cj as cj1 inner join  kc as kc1 on cj1.�γ̺�=kc1.�γ̺�
	where kc1.�γ���='Ӣ��'
)
--2.	��ѯӢ��ɼ�����Ӣ���ƽ���ɼ���ѧ����ѧ�ţ��������ɼ�
select xs.ѧ��,xs.����,cj.�ɼ�
from xs inner join cj on xs.ѧ��=cj.ѧ�� inner join kc on cj.�γ̺�=kc.�γ̺�
where kc.�γ���='Ӣ��'and cj.�ɼ�>(
	select AVG(cj1.�ɼ�)
	from cj as cj1 inner join kc as kc1 on cj1.�γ̺�=kc1.�γ̺�
	where kc1.�γ���='Ӣ��'
)
--3.	��ѯѡ����Ӣ��͸�����ѧ����ѧ�ź�������Ҫ��ʹ�����ַ���ʵ�֣�
/*����һ*/
select xs.ѧ��,xs.����
from xs
where xs.ѧ�� in (
	select cj.ѧ��
	from cj
	where cj.�γ̺� in(
		select kc.�γ̺�
		from kc
		where kc.�γ��� in('Ӣ��','����')
	)
)
/*������*/
select xs.ѧ��,xs.����
from xs inner join cj on xs.ѧ��=cj.ѧ�� inner join kc on cj.�γ̺�=kc.�γ̺�
where kc.�γ��� in ('Ӣ��','����')
--4.	��ѯû��ѡ�޳�����ѡ�޵�ȫ���γ̵�ѧ��������
select xs.ѧ��,xs.����
from xs
where exists
(
	select* 
	from cj inner join xs as xs1 on cj.ѧ��=xs1.ѧ��
	where xs1.����='����'--������⵱�����еĿγ̾������ӱ�
	and
	not exists(
		select *
		from cj as cj1
		where xs.ѧ��=cj1.ѧ�� and cj1.�γ̺�=cj.�γ̺�
		)
)
--5.	��ѯÿ��רҵ���䳬����רҵƽ�������ѧ����������רҵ
select xs.����,xs.רҵ
from xs
where DATEDIFF(yy,xs.����ʱ��,GETDATE())>(
	select AVG(DATEDIFF(yy,xs1.����ʱ��,GETDATE()))
	from xs as xs1
	where xs.רҵ=xs1.רҵ
)
--6.	��ѯÿ��רҵÿ�ſγ̵�רҵ���γ̺ţ��γ�����ѡ��������ƽ���ֺ���߷�
select xs.רҵ,kc.�γ̺�,kc.�γ���,COUNT(distinct xs.ѧ��),AVG(cj.�ɼ�),MAX(cj.�ɼ�)
from xs inner join cj on xs.ѧ��=cj.ѧ�� inner join kc on cj.�γ̺�=kc.�γ̺�
group by xs.רҵ,kc.�γ̺�,kc.�γ���
--7.	��ѯÿ��ѧ��ȡ����߷ֵĿγ̵Ŀγ̺ţ��γ����ͳɼ�
select xs.ѧ��,cj.�γ̺�,kc.�γ���,cj.�ɼ�
from xs left join(kc inner join cj on kc.�γ̺�=cj.�γ̺�) on xs.ѧ��=cj.ѧ��
where cj.�ɼ�>=all(
	select cj2.�ɼ�
	from cj as cj2
	where cj2.ѧ��=xs.ѧ��
)
--8.	��ѯÿ��רҵ������ߵ�ѧ����ѧ�ţ�������רҵ������
select xs.ѧ��,xs.����,xs.רҵ,DATEDIFF(YY,xs.����ʱ��,GETDATE())as'����'
from xs 
where DATEDIFF(YY,xs.����ʱ��,GETDATE())>=all(
	select DATEDIFF(YY,xs2.����ʱ��,GETDATE())
	from xs as xs2
	where xs.רҵ=xs2.רҵ
)
--9.	��ѯû��ѡ�����ݽṹ�Ͳ���ϵͳ��ѧ����ѧ�ź���������ʹ�ô�������ʵ�֣�
select xs.ѧ��,xs.����
from xs
where not exists
(
	select * from cj
	where cj.ѧ��=xs.ѧ�� and cj.�γ̺� in(
		select kc.�γ̺�
		from  kc
		where kc.�γ��� in ('���ݽṹ','����ϵͳ')
	)
)
--10.	��ѯ���繤��רҵ������С��ѧ����ѧ�ź�����
select xs.ѧ��,xs.����
from xs
where xs.רҵ='���繤��'
and
DATEDIFF(YY,xs.����ʱ��,GETDATE())<=all(
	select DATEDIFF(YY,xs2.����ʱ��,GETDATE())
	from xs as xs2
	where xs2.רҵ=xs.רҵ
)
--11.	��ѯѡ����������5�˵Ŀγ̵Ŀγ̺ţ��γ����ͳɼ�
select cj.�γ̺�,kc.�γ���,cj.�ɼ�
from cj inner join kc on cj.�γ̺�=kc.�γ̺�
where (select COUNT(cj2.ѧ��)from cj as cj2 where cj2.�γ̺�=cj.�γ̺�)>5
--12.	��ѯѡ������Ϣ����רҵ����ѧ��ѡ�޵�ȫ���γ̵�ѧ����ѧ�ź�����
select xs.ѧ��,xs.����
from xs
where not exists
(
	select * 
	from cj inner join xs as xs2 on cj.ѧ��=xs2.ѧ��
	and xs2.רҵ='��Ϣ����'
	and not exists
	(
		select* from cj as cj2
		where xs.ѧ��=cj2.ѧ�� and cj2.�γ̺�=cj.�γ̺�
	)
)
--13.	ʹ�ô�������ʵ�ֲ�ѯû�б�ѧ��ѡ�޵Ŀγ̵Ŀγ̺źͿγ���
select kc.�γ̺�,kc.�γ���
from kc
where not exists
(
	select *
	from xs
	where exists
	(
		select * from cj
		where xs.ѧ��=cj.ѧ�� and cj.�γ̺�=kc.�γ̺�
	)
)
--14.	��ѯѡ����������ѡ���������ٵĿγ̵Ŀγ̺ţ��γ���������
/*�üһ���nm�Ѿ�*/
select kc.�γ̺�,kc.�γ���,COUNT(cj.ѧ��)
from kc left outer join cj on kc.�γ̺�=cj.�γ̺�
group by kc.�γ̺�,kc.�γ���
having COUNT(cj.ѧ��)>=all(select COUNT(cj2.ѧ��) from kc as kc2 left outer join cj as cj2 on kc2.�γ̺�=cj2.�γ̺� group by kc2.�γ̺�)
or COUNT(cj.ѧ��)<=all(select COUNT(cj2.ѧ��) from kc as kc2 left outer join cj as cj2 on kc2.�γ̺�=cj2.�γ̺� group by kc2.�γ̺�)
--15.	��ѯѡ��Ӣ��ĳɼ�����Ӣ��γ̵�ƽ���ɼ���ѧ����ѧ�ţ������ͳɼ�
select xs.ѧ��,xs.����,cj.�ɼ�
from xs inner join cj on xs.ѧ��=cj.ѧ�� inner join kc on cj.�γ̺�=kc.�γ̺�
where kc.�γ���='Ӣ��'
and
cj.�ɼ�>(
	select AVG(cj2.�ɼ�) from cj as cj2 where cj2.�γ̺�=cj.�γ̺�
)
--16.	��ѯ���ſ��гɼ���߷ֵ�ѧ����ѧ�ţ��������γ̺ţ��γ���������
select xs.ѧ��,xs.����,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from kc left outer join cj on kc.�γ̺�=cj.�γ̺� left outer join xs on cj.ѧ��=xs.ѧ��
where cj.�ɼ�>=all(
	select cj2.�ɼ� from cj as cj2
	where cj2.�γ̺�=kc.�γ̺�
)
--17.	��ѯÿ�ſ��гɼ����ڸÿγ̵�ƽ���ɼ���ѧ�ţ��γ̺ţ��ɼ�
select cj.ѧ��,cj.�γ̺�,cj.�ɼ�
from cj
where cj.�ɼ�<(
	select AVG(cj2.�ɼ�)from cj as cj2 where cj2.�γ̺�=cj.�γ̺�
)
--18.	��ѯ����רҵÿ�ſγ�ȡ����߷ֵ�ѧ����ѧ�ţ�������רҵ���γ̺ţ��γ������ɼ�
select xs.ѧ��,xs.����,xs.רҵ,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from xs inner join cj on xs.ѧ��=cj.ѧ�� inner join kc on cj.�γ̺�=kc.�γ̺�
where cj.�ɼ�>=all(
	select cj2.�ɼ�
	from cj as cj2
	where cj2.�γ̺�=kc.�γ̺�/*û����ûѡ�εĺ�û��ѡ�ĿΣ��о������������̫�ø����������*/
)
--19.	��ѯû��ѡ��ȫ���γ̵�ѧ����ѧ�ź�������
select xs.ѧ��,xs.����
from xs
where exists(
	select * from kc
	where not exists(
		select* from cj
		where cj.ѧ��=xs.ѧ�� and cj.�γ̺�=kc.�γ̺�
	)
)
--20.	��ѯû�б�ȫ��ѧ����ѡ���˵Ŀγ̵Ŀγ̺źͿγ���
select kc.�γ̺�,kc.�γ���
from kc
where exists(
	select* 
	from xs
	where not exists(
		select* from cj
		where cj.ѧ��=xs.ѧ�� and cj.�γ̺�=kc.�γ̺�
	)
)
--21.	��ѯѡ�������������繤��רҵĳ��ѧ����ѡ��������ѧ����ѧ�ţ�������ѡ������

--22.	��ѯѡ����������Ӣ���ѡ�������Ŀγ̵Ŀγ̺ţ��γ���������

--23.	��ѯ�ɼ�����ѡ��Ӣ���ĳ��ѧ���ĳɼ���ѧ����ѧ�ţ��������γ̺ţ��γ������ɼ�

--24.	��ѯѡ���˳����ͷ�����ͬѧ��ѡ�޵�ȫ���γ̵�ѧ����ѧ�ź�����

--25.	��ѯѡ��ѧ��������ѡ��Ӣ���ȫ��ѧ���Ŀγ̵Ŀγ̺źͿγ���

--26.	��ѯÿ�ſγ̳ɼ�����������ͬѧ��ѧ�ţ������Ϳγ̺ţ��γ������ɼ�

--27.	��ѯÿ�ſγ���ɼ�������ǰ10%��ͬѧ��ѧ�ţ������Ϳγ̺ţ��γ������ɼ�

--28.	��ѯû��ѡ��ȫ���γ̵�ѧ����ѧ�ź�����

--29.	��ѯѡ�������������繤��רҵÿ��ѧ����ѡ������������רҵ��ѧ����ѧ�ţ�������ѡ������

--30.	��ѯѧ���������ٵ�רҵ����רҵ����

--����	��books���ݿ�������²���

--31.	��ѯ��������ͼ�����������������Ŀǰû��ͼ������

--32.	��ѯ�����ˡ����ݿ�������Ķ��ߵĿ���ź�����

--33.	��ѯ�����������ͼ��۸񳬹����������ͼ���ƽ���۸��ͼ��ı�ź����ơ�

--34.	��ѯû�н��ͼ��Ķ��ߵı�ź�����

--35.	��ѯ���Ĵ�������2�εĶ��ߵı�ź�����

--36.	��ѯ���Ŀ�������Ϊ��ʦ���о����Ķ�������

--37.	��ѯû�б������ͼ��ı�ź�����

--38.	��ѯû�н��Ĺ�Ӣ�����͵�ͼ��Ľ�ʦ�ı�ź�����

--39.	��ѯ�����ˡ������Ӧ�á����ġ����ݿ�������γ̵Ķ��ߵı�ţ����������Լ��ö��ߵĽ��Ŀ������͡�

--40.	��ѯû�б�ȫ���Ķ��߶����Ĺ���ͼ��ı�ź�ͼ������

--41.	��ѯ���Ĺ��廪��ѧ�����������ͼ��Ķ��߱�ź�����

--42.	��ѯ���Ĺ����������Ĺ���ȫ��ͼ��Ķ��߱�ź�����

--43.	��ѯÿ�����͵Ľ����߽��Ĺ���ͼ��Ĵ���

--44.	��ѯ�۸�����廪��ѧ�����������ͼ��۸��ͼ��ı�ţ�ͼ�����ƺͼ۸񣬳�����

--45.	��ѯû�н��Ĺ����������������ͼ��Ľ����ߵı������

--�������̳����ݿ�������²���
--Market (mno, mname, city)
--Item (ino, iname, type, color)
--Sales (mno, ino, price)
--���У�market��ʾ�̳���������������Ϊ�̳��š��̳��������ڳ��У�item��ʾ��Ʒ��������������Ϊ��Ʒ�š���Ʒ������Ʒ������ɫ��sales��ʾ���ۣ�������������Ϊ�̳��š���Ʒ�ź��ۼۡ�

--��SQL���ʵ������Ĳ�ѯҪ��
--1.	�г����������̳������ۣ����ۼ۾�����10000 Ԫ����Ʒ����Ʒ�ź���Ʒ��

--2.	�г��ڲ�ͬ�̳�������ۼۺ�����ۼ�ֻ���100 Ԫ����Ʒ����Ʒ�š�����ۼۺ�����ۼ�

--3.	�г��ۼ۳�������Ʒ��ƽ���ۼ۵ĸ�����Ʒ����Ʒ�ź��ۼ�

--4.	��ѯÿ��ÿ�����и����̳��ۼ���ߵ���Ʒ���̳��������У���Ʒ�ź���Ʒ��

--5.	��ѯ������Ʒ���������̳����̳��ţ��̳����ͳ���

--6.	��ѯ�����˱����ϴ�»����̳��ţ��̳����ͳ���

--7.	��ѯ���۹�����Ʒ�Ƶ�������Ʒ���̳���ź��̳�����

--8.	��ѯ������������Ʒ���̳���ź��̳�����

--9.	��ѯ�ڱ����ĸ����̳��������۵���Ʒ�ı�ź���Ʒ����

--10.	��ѯ�۸���ڱ����������̳������۵Ĳ�Ʒ�ļ۸����Ʒ��ź���Ʒ���ơ�
