--���xsgl���ݿ�ʹ��sql������һ�²�ѯ��
use xsgl
go
--��ѯ��ѧ�ֳ���20ѧ�ֵ�ѧ��������
select count(*) 
from xs
where xs.��ѧ��>20
--��ѯ�������繤��רҵ��ѧ����ѧ�ţ�������רҵ
select xs.ѧ��,xs.����,xs.רҵ
from xs
where xs.רҵ<>'���繤��'
--��ѯѡ���ˡ�A001���γ̵�ѧ��������
select count(cj.ѧ��) 
from cj
where cj.�γ̺�='A001'
--��ѯѡ���ˡ�A001���γ̵�ѧ���������ѧ����ѧ�ţ��γ̺źͳɼ�
select cj.ѧ��,cj.�γ̺�,cj.�ɼ�
from cj
where cj.�γ̺�='A001' and cj.�ɼ�<60--����60�ּ���
--��ѯxs������Ϣ����רҵ������С��ѧ����ѧ�ţ�����������
select top 1 xs.ѧ��,xs.����,datediff(yy,xs.����ʱ��,getdate()) as ����
from xs
order by xs.����ʱ�� desc
--��ѯѡ�޿γ��в������ѧ��������
select count(distinct cj.ѧ��) from cj--�е�����
where cj.�ɼ�<60
--��ѯѡ����A001��J001��J002��J003�γ�֮һ��ѧ����ѧ�ţ��γ̺úͳɼ�
select cj.ѧ��,cj.�γ̺�,cj.�ɼ�
from cj
where cj.�γ̺� in('A001','J001','J002','J003')
--��ѯ�γ�ѧ�ֵ���3�ֺ͸���5�ֵĿγ̺ţ��γ����Լ�ѧ��
select kc.�γ̺�,kc.�γ���,kc.ѧ��
from kc
where kc.ѧ�� not between 3 and 5
--��ѯ���䳬��35������Ż��������ѧ����ѧ�ţ�����������
select xs.ѧ��,xs.����,datediff(yy,xs.����ʱ��,GETDATE()) as ����
from xs
where (datediff(yy,xs.����ʱ��,GETDATE())>35) and (xs.���� like '��%' or xs.���� like '��%')
--��ѯ���ź������������Ů�����ж����ˣ����������ϣ��Ա������
select SUBSTRING(xs.����,1,1) as ����, xs.�Ա�,count(xs.ѧ��) as ����
from xs
where xs.���� like '��%' or xs.���� like '��%'
group by SUBSTRING(xs.����,1,1), xs.�Ա�