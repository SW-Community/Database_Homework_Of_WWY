/**
*���ݿ�ϵͳʵ����
*@author Steve
*@version 1.0.0
*/

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
select xs.ѧ��,xs.����,COUNT(cj.�γ̺�)
from xs left outer join cj on xs.ѧ��=cj.ѧ��
group by xs.ѧ��,xs.����
having COUNT(cj.�γ̺�)<any(
	select COUNT(cj1.�γ̺�)
	from xs as xs1 left outer join cj as cj1 on xs1.ѧ��=cj1.ѧ��
	where xs1.רҵ='���繤��'
	group by xs1.ѧ��,xs1.����
)
--22.	��ѯѡ����������Ӣ���ѡ�������Ŀγ̵Ŀγ̺ţ��γ���������
select kc.�γ̺�,kc.�γ���,COUNT(cj.ѧ��)
from kc inner join cj on kc.�γ̺�=cj.�γ̺�
group by kc.�γ̺�,kc.�γ���
having COUNT(cj.ѧ��)>all(
	select COUNT(cj1.ѧ��)
	from kc as kc1 inner join cj as cj1 on kc1.�γ̺�=cj1.�γ̺�
	where kc1.�γ���='Ӣ��'
)
--23.	��ѯ�ɼ�����ѡ��Ӣ���ĳ��ѧ���ĳɼ���ѧ����ѧ�ţ��������γ̺ţ��γ������ɼ�
select xs.ѧ��,xs.����,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from xs inner join cj on xs.ѧ��=cj.ѧ�� inner join kc on kc.�γ̺�=cj.�γ̺�
where cj.�ɼ�>any(
	select cj1.�ɼ�
	from cj as cj1
	where cj1.�γ̺�=(
		select kc1.�γ̺�
		from kc as kc1
		where kc1.�γ���='Ӣ��'
	)
)
--24.	��ѯѡ���˳����ͷ�����ͬѧ��ѡ�޵�ȫ���γ̵�ѧ����ѧ�ź�����
select xs.ѧ��,xs.����
from xs
where not exists(/*������*/
	select *
	from cj as cj1 inner join xs as xs1 on cj1.ѧ��=xs1.ѧ��/*�����Ǵ��ڻ��ǲ����ڶ���Ҫ��selectһ�������*/
	where xs1.���� in ('����','������')
	and not exists(/*û��*/
		select * from cj
		where xs.ѧ��=cj.ѧ�� and cj.�γ̺�=cj1.�γ̺�/*ѡ��*/
	)
)
--25.	��ѯѡ��ѧ��������ѡ��Ӣ���ȫ��ѧ���Ŀγ̵Ŀγ̺źͿγ���
select kc.�γ̺�,kc.�γ���
from kc
where not exists(
	select * from cj as cj1 inner join xs as xs1 on cj1.ѧ��=xs1.ѧ�� inner join kc as kc1 on cj1.�γ̺�=kc1.�γ̺�
	where kc1.�γ���='Ӣ��'
	and not exists(
		select * 
		from cj
		where kc.�γ̺�=cj.�γ̺� and cj.ѧ��=xs1.ѧ��
	)
)
--26.	��ѯÿ�ſγ̳ɼ�����������ͬѧ��ѧ�ţ������Ϳγ̺ţ��γ������ɼ�
select xs.ѧ��,xs.����,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from xs inner join cj on xs.ѧ��=cj.ѧ�� inner join kc on kc.�γ̺�=cj.�γ̺�
where cj.�ɼ� in (
	select distinct top 2 cj1.�ɼ�
	from cj as cj1
	where cj1.�γ̺�=cj.�γ̺�
	order by cj1.�ɼ�
)
--27.	��ѯÿ�ſγ���ɼ�������ǰ10%��ͬѧ��ѧ�ţ������Ϳγ̺ţ��γ������ɼ�
select xs.ѧ��,xs.����,kc.�γ̺�,kc.�γ���,cj.�ɼ�
from kc left join cj on kc.�γ̺�=cj.�γ̺� left join xs on xs.ѧ��=cj.ѧ��
where cj.�ɼ� in
(
	select distinct top 10 percent cj1.�ɼ�
	from cj as cj1
	where cj1.�γ̺�=kc.�γ̺�
)
--28.	��ѯû��ѡ��ȫ���γ̵�ѧ����ѧ�ź�����
select xs.ѧ��,xs.����
from xs
where exists(
	select * 
	from kc
	where not exists(
		select*
		from cj
		where cj.�γ̺�=kc.�γ̺� and cj.ѧ��=xs.ѧ��
	)
)
--29.	��ѯѡ�������������繤��רҵÿ��ѧ����ѡ������������רҵ��ѧ����ѧ�ţ�������ѡ����������������
select xs.ѧ��,xs.����,COUNT(cj.�γ̺�)
from xs left join cj on xs.ѧ��=cj.ѧ��
where xs.רҵ!='���繤��'
group by xs.ѧ��,xs.����
having COUNT(cj.�γ̺�)>all(
	select COUNT(cj1.�γ̺�)
	from xs as xs1 inner join cj as cj1 on xs1.ѧ��=cj1.ѧ��
	where xs1.רҵ='���繤��'
	group by xs1.ѧ��,xs1.����
)
--30.	��ѯѧ���������ٵ�רҵ����רҵ����
select xs.רҵ,COUNT(xs.ѧ��)
from xs
group by xs.רҵ
having COUNT(xs.ѧ��)<=all(
	select COUNT(xs1.ѧ��)
	from xs as xs1
	group by xs1.רҵ
)
--����	��books���ݿ�������²���
use books
--31.	��ѯ��������ͼ�����������������Ŀǰû��ͼ������
select BookType.TypeID,BookType.TypeName,COUNT(BookInfo.BookNo)
from BookType left join BookInfo on BookType.TypeID=BookInfo.TypeID
group by BookType.TypeID,BookType.TypeName
--32.	��ѯ�����ˡ����ݿ�������Ķ��ߵĿ���ź�����
select BorrowInfo.CardNo,CardInfo.Reader
from CardInfo inner join BorrowInfo on CardInfo.CardNo=BorrowInfo.CardNo inner join BookInfo on BorrowInfo.BookNo=bookinfo.BookNo
where bookinfo.BookName='���ݿ����'
--33.	��ѯ�����������ͼ��۸񳬹����������ͼ���ƽ���۸��ͼ��ı�ź����ơ�
select BookInfo.Publisher,BookInfo.BookNo,BookInfo.BookName
from BookInfo
where bookinfo.Price>(
	select AVG(BookInfo1.Price)
	from BookInfo as BookInfo1
	where BookInfo.Publisher=BookInfo1.Publisher
)
--34.	��ѯû�н��ͼ��Ķ��ߵı�ź�����
select CardInfo.CardNo,CardInfo.Reader
from CardInfo left join BorrowInfo on CardInfo.CardNo=BorrowInfo.CardNo
where BorrowInfo.CardNo is null
--35.	��ѯ���Ĵ�������2�εĶ��ߵı�ź�����
select CardInfo.CardNo,CardInfo.Reader
from CardInfo inner join BorrowInfo on CardInfo.CardNo=BorrowInfo.CardNo
group by CardInfo.CardNo,CardInfo.Reader
having COUNT(*)>2
--36.	��ѯ���Ŀ�������Ϊ��ʦ����ʦ�������о����Ķ�������
select CardInfo.CTypeID,COUNT(*)
from CardInfo
where Cardinfo.CTypeID in(select CardType.CTypeID from CardType where CardType.TypeName in ('��ʦ','�о���'))
group by CardInfo.CTypeID
--37.	��ѯû�б������ͼ��ı�ź�����
select BookInfo.BookNo,BookInfo.BookName
from BookInfo left join BorrowInfo on BookInfo.BookNo=BorrowInfo.BookNo
where BorrowInfo.BookNo is null
--38.	��ѯû�н��Ĺ�Ӣ�����͵�ͼ��Ľ�ʦ�ı�ź�����
select Cardinfo.CardNo,CardInfo.Reader
from CardInfo
where CardInfo.CTypeID in (select CardType.CTypeID from CardType where CardType.TypeName='��ʦ')
and CardInfo.CardNo not in (select BorrowInfo.CardNo from BorrowInfo where BorrowInfo.BookNo=(select BookInfo.BookNo from bookinfo where BookInfo.TypeID in (select BookType.TypeID from BookType where BookType.TypeName='Ӣ��')))
/*��ֹ���ޣ�����~~~*/
--39.	��ѯ�����ˡ������Ӧ�á����ġ����ݿ�������γ̣�ͼ�飿���Ķ��ߵı�ţ����������Լ��ö��ߵĽ��Ŀ������͡�
/*��������ȷ��������û���⣿*/
select CardInfo.CardNo,CardInfo.Reader,CardType.TypeName
from CardInfo,CardType
where CardInfo.CTypeID=CardType.CTypeID
and CardInfo.CardNo in
(
	select BorrowInfo.CardNo
	from BorrowInfo
	where BorrowInfo.BookNo =
	(
		select BookInfo.BookNo from BookInfo
		where BookInfo.BookName='���ݿ����'
		and BookInfo.TypeID =
		(
			select BookType.TypeID
			from BookType
			where BookType.TypeName='�����Ӧ��'
		)
	)
)
--40.	��ѯû�б�ȫ���Ķ��߶����Ĺ���ͼ��ı�ź�ͼ������
select BookInfo.BookNo,bookinfo.BookName
from BookInfo
where exists
(
	select* from CardInfo
	where not exists
	(
		select* 
		from BorrowInfo
		where CardInfo.CardNo=BorrowInfo.CardNo and BorrowInfo.BookNo=BookInfo.BookNo
	)
)
--41.	��ѯ���Ĺ��廪��ѧ�����������ͼ��Ķ��߱�ź�����
select CardInfo.CardNo,CardInfo.Reader/*����������һ������Ĳ�Ʒ��������*/
from CardInfo
where not exists(
	select* 
	from BookInfo
	where BookInfo.Publisher='�廪��ѧ������'
	and not exists(
		select*
		from BorrowInfo
		where CardInfo.CardNo=BorrowInfo.CardNo and BorrowInfo.BookNo=BookInfo.BookNo
	)
)
/*������δ��빦��ͬ�ϣ��ٴ�˵����ʱ��ĳЩwhere�������Ƶȼ���from������*/
select CardInfo.CardNo,CardInfo.Reader
from CardInfo
where not exists(
	select* 
	from (select* from BookInfo where BookInfo.Publisher='�廪��ѧ������')as sublist
	where not exists(
		select* 
		from BorrowInfo
		where CardInfo.CardNo=BorrowInfo.CardNo and BorrowInfo.BookNo=sublist.BookNo
	)
)
--42.	��ѯ���Ĺ����������Ĺ���ȫ��ͼ��Ķ��߱�ź�����
select CardInfo.CardNo,CardInfo.Reader
from CardInfo
where not exists(
	select*
	from (
		select BorrowInfo1.BookNo
		from BorrowInfo as BorrowInfo1
		where BorrowInfo1.CardNo=(
			select CardInfo1.CardNo
			from CardInfo as CardInfo1
			where CardInfo1.Reader='����'
		)
	) 
	as sublist
	where not exists(
		select* 
		from BorrowInfo
		where CardInfo.CardNo=BorrowInfo.CardNo and BorrowInfo.BookNo=sublist.BookNo
	)
)
--43.	��ѯÿ�����͵Ľ����߽��Ĺ���ͼ��Ĵ���
select CardType.TypeName,COUNT(BorrowInfo.BookNo)
from CardType inner join CardInfo on CardType.CTypeID=CardInfo.CTypeID left join BorrowInfo on CardInfo.CardNo=BorrowInfo.CardNo
group by CardType.TypeName
--44.	��ѯ�۸�����廪��ѧ�����������ͼ��۸��ͼ��ı�ţ�ͼ�����ƺͼ۸񣬳�����
select BookInfo.BookNo,BookInfo.BookName,BookInfo.Price,BookInfo.Publisher
from BookInfo
where BookInfo.Price>all(
	select b2.Price
	from BookInfo as b2
	where b2.Publisher='�廪��ѧ������'
)
--45.	��ѯû�н��Ĺ����������������ͼ��Ľ����ߵı������
select CardInfo.CardNo,CardInfo.Reader
from CardInfo
where exists(
	select *
	from 
	(
		select B2.BookNo
		from BorrowInfo as B2
		where B2.CardNo=
		(
			select C2.CardNo
			from CardInfo as C2
			where C2.Reader='����'
		)
	)
	as sublist
	where not exists(
		select *
		from BorrowInfo
		where CardInfo.CardNo=BorrowInfo.CardNo and BorrowInfo.BookNo=sublist.BookNo
	)
)
--�������̳����ݿ�������²���
--Market (mno, mname, city)
--Item (ino, iname, type, color)
--Sales (mno, ino, price)
--���У�market��ʾ�̳���������������Ϊ�̳��š��̳��������ڳ��У�item��ʾ��Ʒ��������������Ϊ��Ʒ�š���Ʒ������Ʒ������ɫ��sales��ʾ���ۣ�������������Ϊ�̳��š���Ʒ�ź��ۼۡ�
use �̳�
--��SQL���ʵ������Ĳ�ѯҪ��
--1.	�г����������̳������ۣ����ۼ۾�����10000 Ԫ����Ʒ����Ʒ�ź���Ʒ��
select item.ino,item.iname
from item
where not exists
(
	select *
	from market
	where market.city='����'
	and not exists(
		select*
		from sales
		where sales.ino=item.ino and sales.mno=market.mno and sales.price>10000
	)
)
--2.	�г��ڲ�ͬ�̳�������ۼۺ�����ۼ�ֻ���100 Ԫ����Ʒ����Ʒ�š�����ۼۺ�����ۼ�
select sales.ino,MAX(sales.price),MIN(sales.price)
from sales
group by sales.ino
having MAX(sales.price)-MIN(sales.price)>100
--3.	�г��ۼ۳�������Ʒ��ƽ���ۼ۵ĸ�����Ʒ����Ʒ�ź��ۼ�
select sales.ino,sales.price
from sales
where sales.price>(
	select AVG(sales1.price)
	from sales as sales1
	where sales.ino=sales1.ino
)
--4.	��ѯÿ��ÿ�����и����̳��ۼ���ߵ���Ʒ���̳��������У���Ʒ�ź���Ʒ��
select market.city,market.mno,item.ino,item.iname
from market,sales,item
where market.mno=sales.mno and sales.ino=item.ino
and sales.price=(
	select MAX(sales1.price)
	from sales as sales1
	where sales.mno=sales1.mno
)
--5.	��ѯ������Ʒ���������̳����̳��ţ��̳����ͳ���
select market.mno,market.mname,market.city
from market,sales
where market.mno=sales.mno
group by market.mno,market.mname,market.city
having COUNT(sales.ino)>=all(
	select COUNT(sales1.ino)
	from sales as sales1
	group by sales1.mno
)
--6.	��ѯ�����˱����ϴ�»����̳��ţ��̳����ͳ���
select market.mno,market.mname,market.city
from market
where not exists(
	select * 
	from item
	where item.iname in('����','ϴ�»�')
	and not exists(
		select * 
		from sales
		where item.ino=sales.ino and sales.mno=market.mno
	)
)
--7.	��ѯ���۹�����Ʒ�Ƶ�������Ʒ���̳���ź��̳�����
select market.mno,market.mname
from market
where not exists(
	select *
	from(
		select *
		from item as i1
		where i1.type='����'
	)as sb
	where not exists(
		select *
		from sales
		where sb.ino=sales.ino and sales.mno=market.mno
	)
)
--8.	��ѯ������������Ʒ���̳���ź��̳�����
select market.mno,market.mname
from market
where not exists(
	select*
	from item
	where not exists(
		select*
		from sales
		where sales.ino=item.ino and sales.mno=market.mno
	)
)
--9.	��ѯ�ڱ����ĸ����̳��������۵���Ʒ�ı�ź���Ʒ����
select item.ino,item.iname
from item 
where not exists
(
	select* 
	from market
	where market.city='����'
	and not exists(
		select *
		from sales
		where item.ino=sales.ino and sales.mno=market.mno
	)
)
--10.	��ѯ�۸���ڱ����������̳������۵Ĳ�Ʒ�ļ۸����Ʒ��ź���Ʒ���ơ�
select item.ino,item.iname
from item inner join sales on item.ino=sales.ino
where sales.price>all(
	select sales1.price
	from sales as sales1 
	where sales1.mno in(
		select market1.mno
		from market as market1
		where market1.city='����'
	)
)

/*
	����ǧ���У��¼�������
	���꣩
*/