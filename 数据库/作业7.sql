/**
 * 实验七要求
 * @author Steve
 * @version 1.0.0
 */

--一、对xsgl数据库完成下列操作要求：
use xsgl
go
--1.	用函数实现：求某个专业选修了某门课程的学生人数，并调用函数求出计算机系“数据库”课程的选课人数
create function f1(@专业 as char(16),@课程名 as char(16))
returns int
begin
	declare @返回值 int
	declare @课程号 char(10)

	select @课程号=kc.课程号
	from kc
	where kc.课程名=@课程名

	select @返回值=COUNT(*)
	from cj
	where cj.课程号=@课程号
	and cj.学号 in(
		select xs.学号
		from xs
		where xs.专业=@专业
	)
	return @返回值
end
go

print str(dbo.f1('计合','数据库SQL Server'))
go
--2.	用内嵌表值函数实现：查询某个专业所有学生所选的每门课的平均成绩；调用该函数求出计算机系的所有课程的平均成绩。
create function f2(@zhuanye as char(16))
returns table
as
return
(
	select AVG(cj.成绩) '平均分'
	from cj
	where cj.学号 in
	(
		select xs.学号
		from xs
		where xs.专业=@zhuanye
	)
	group by cj.课程号
)
go
--3.	创建多语句表值函数，通过学号作为实参调用该函数，可显示该学生的姓名以及各门课的成绩和学分，调用该函数求出“200515002”的各门课成绩和学分。
create FUNCTION f3(@xuehao char(10))
RETURNS @tb TABLE(
    姓名 NCHAR(10),
    课程号 CHAR(10),
    成绩 NUMERIC(18,0),
    学分 SMALLINT
)
BEGIN
    insert into @tb
    SELECT xs.姓名,kc.课程号,cj.成绩,kc.学分
    FROM xs LEFT OUTER JOIN cj ON xs.学号=cj.学号 LEFT JOIN kc ON cj.课程号=kc.课程号
    WHERE xs.学号=@xuehao
    RETURN --表也可以看作是table变量，但返回值什么也不写
END
go

SELECT * FROM dbo.f3('200515002')
go
--4.	编写一个存储过程，统计某门课程的优秀（90-100）人数、良好（80-89）人数、中等（70-79）人数、及格（60-69）人数和及格率，其输入参数是课程号，输出的是各级别人数及及格率，及格率的形式是90.25%，执行存储过程，在消息区显示1号课程的统计信息。
CREATE PROC p1 @kch CHAR(10)
AS
BEGIN
    SELECT 
    COUNT(case when cj.成绩>=90 and cj.成绩<=100 then 1 END) as '优秀人数',
    COUNT(case when cj.成绩>=80 and cj.成绩<90 then 1 END) as '良好人数',
    COUNT(case when cj.成绩>=70 and cj.成绩<80 then 1 END) as '中等人数',
    COUNT(case when cj.成绩>=60 and cj.成绩<70 then 1 END) as '及格人数',
    STR(((CONVERT(float,COUNT(case when cj.成绩>=60 then 1 END))/CONVERT(float,COUNT(*)))*100)) +'%' as '及格率'
    FROM cj
    WHERE cj.课程号=@kch
END --踩坑了，0也是count，不写是null，那才是真正的空
GO
exec p1 'A001'
go
--5.	创建一个带有输入参数的存储过程，该存储过程根据传入的学生名字，查询其选修的课程名和成绩，执行存储过程，在消息区显示方可以同学的相关信息。
CREATE PROC p2 @xm NCHAR(10)
AS
BEGIN
    DECLARE @xuehao CHAR(10)
    SELECT @xuehao=xs.学号
    from xs
    where xs.姓名=@xm
    SELECT kc.课程名,cj.成绩
    FROM kc INNER JOIN cj ON kc.课程号=cj.课程号
    WHERE cj.学号=@xuehao
END
go

exec p2 '方可以'
go
--6.	以基本表 课程和选课表为基础，完成如下操作
--生成显示如下报表形式的游标：报表首先列出学生的学号和姓名，然后在此学生下，列出其所选的全部课程的课程号、课程名和学分；依此类推，直到列出全部学生。
CREATE PROC p3
AS
BEGIN
    DECLARE @xuehao CHAR(10)
    DECLARE @xingming NCHAR(10)
    DECLARE @kch CHAR(10)
    DECLARE @kcm CHAR(16)
    DECLARE @xf SMALLINT
    DECLARE c1 CURSOR
    FOR 
    SELECT xs.学号,xs.姓名
    FROM xs
    OPEN c1
    FETCH NEXT FROM c1 INTO @xuehao,@xingming
    WHILE @@FETCH_STATUS =0 
    BEGIN
        PRINT '学号：'+@xuehao+' 姓名：'+@xingming
        PRINT '选课情况如下'
        PRINT '---------------------------------'
        PRINT '课程号 课程名 学分'
        DECLARE c2 CURSOR
        FOR
        SELECT cj.课程号,kc.课程名,kc.学分
        FROM cj INNER JOIN kc ON cj.课程号=kc.课程号
        WHERE cj.学号=@xuehao
        OPEN c2
        FETCH NEXT FROM c2 into @kch,@kcm,@xf
        WHILE @@FETCH_STATUS=0
        BEGIN
            
            PRINT @kch+' '+@kcm+' '+str(@xf)
            FETCH NEXT FROM c2 into @kch,@kcm,@xf
        END
        CLOSE c2
        DEALLOCATE c2
        PRINT '---------------------------------'
        FETCH NEXT FROM c1 INTO @xuehao,@xingming
    END
    CLOSE c1
    DEALLOCATE c1
END
GO

EXEC p3
go
--drop proc p3
--7.	请设计一个存储过程实现下列功能：判断某个专业某门课程成绩排名为n的学生的成绩是否低于该门课程的平均分，如果低于平均分，则将其成绩改为平均分，否则输出学号、姓名、班号、课程号、课程名、成绩。（提示：可以在存储过程内部使用游标）。
CREATE PROC p4 @zhuanye CHAR(16),@kch CHAR(10),@paiming INT
AS
BEGIN
    DECLARE @xuehao CHAR(10)
    DECLARE @xingming CHAR(10)
    DECLARE @kcm CHAR(10)
    DECLARE @cj NUMERIC(18,0)
    DECLARE @pjf NUMERIC(18,0)

    

    SELECT @pjf=AVG(cj.成绩)
    FROM cj
    WHERE cj.课程号=@kch

    DECLARE c4 SCROLL CURSOR 
    FOR SELECT cj.学号,cj.成绩
    FROM cj
    WHERE cj.课程号=@kch
    AND cj.学号 IN(
        SELECT xs.学号
        FROM xs
        WHERE xs.专业=@zhuanye
    )
    ORDER BY cj.成绩 DESC
    
    OPEN c4
    FETCH ABSOLUTE @paiming FROM c4 INTO @xuehao,@cj
    IF(@cj<@pjf)
    BEGIN
        PRINT '分有点低，算了，捞你一把，积德行善！'
        UPDATE cj
        SET CJ.成绩=@pjf
        WHERE current of c4
    END
    ELSE
    BEGIN
        SELECT @xingming=xs.姓名
        FROM xs
        WHERE xs.学号=@xuehao
        SELECT @kcm=kc.课程名
        FROM kc
        WHERE kc.课程号=@kch
        PRINT @xuehao+' '+ @xingming+' '+@zhuanye+' '+@kch+' '+@kcm+' '+STR(@cj)
    END
    CLOSE c4
    DEALLOCATE c4
END
GO
--8. 对xsgl数据库设计存储过程，设计程序实现更新某门课程的成绩，将该门课程成绩低于课程平均成绩的学生成绩都加上3分。
CREATE PROC p5 @kch CHAR(10)
AS
BEGIN
    DECLARE @pjf NUMERIC(18,0)
    SELECT @pjf=AVG(cj.成绩)
    FROM cj
    WHERE cj.课程号=@kch

    UPDATE cj
    SET cj.成绩=cj.成绩+3
    WHERE cj.课程号=@kch AND cj.成绩<@pjf
END
GO
--9. 针对实验六创建的借书表：lendt(bno（索书号）,sno（学号）,ldate（借阅日期）,rdate（应还日期），relend（是否续借）),
--再创建还书表 return(bno（索书号）,sno（学号），rrdate(还书日期), cq(是否超期), fakuan（罚款金额），还书日期的默认值也是当前日期，是否超期默认值为否；
--设计存储过程实现还书功能，某个学生还某本图书，首先删除相应的借阅记录，然后插入一条还书记录，如果超期则将是否超期改为是，并且按照每天0.5元计算罚款，并将罚款金额记录。
CREATE TABLE huanshu(--return是关键字，换个名称怕后面出问题
    bno INT,
    sno CHAR(10),
    rrdate DATETIME DEFAULT GETDATE(),
    cq BIT DEFAULT 0,
    fakuan FLOAT,
    PRIMARY KEY(bno,rrdate)
)
GO

CREATE PROC p6 @xuehao CHAR(10),@shuhao INT
AS
BEGIN
    DECLARE @jieyueriqi DATETIME
    SELECT @jieyueriqi=lendt.rdate
    FROM lendt
    WHERE lendt.bno=@shuhao

    DELETE FROM lendt
    WHERE lendt.bno=@shuhao

    DECLARE @chaoxian DATETIME
    DECLARE @fajin FLOAT
    DECLARE @shifouchaoxian BIT
    set @chaoxian=DATEDIFF(dd,@jieyueriqi,GETDATE())--这里默认当天还书
    set @fajin=0.5*DATENAME(DAY,@chaoxian)
    IF(@fajin=0)
        SET @shifouchaoxian=0
    ELSE
        SET @shifouchaoxian=1
    insert INTO huanshu
    VALUES(@shuhao,@xuehao,GETDATE(),@shifouchaoxian,@fajin)
END
GO
--10. 使用存储过程实现转专业功能，将某个学生（学号）转入到某个专业中，如果想转入的专业是计算机专业那么要求该学生的平均成绩必须超过95分，否则不允许转专业，并将转专业的信息插入到一个转专业的表里，changesd(学号，原专业，新专业，平均成绩)
 CREATE TABLE changesd
 (
    学号 CHAR(10),
    原专业 CHAR(16),
    新专业 CHAR(16),
    平均分 NUMERIC(18,0)
 )
 GO

create PROC p7 @xuehao CHAR(10),@xinzhuanye CHAR(16)
AS
BEGIN
    DECLARE @yuanzhuanye CHAR(16)
    DECLARE @pjf NUMERIC(18,0)

    SELECT @yuanzhuanye=xs.专业
    FROM xs
    WHERE xs.学号=@xuehao
    SELECT @pjf=AVG(cj.成绩)
    FROM cj
    WHERE cj.学号=@xuehao
    IF(@pjf<=95 AND @xinzhuanye='计算机')
    BEGIN
        PRINT '分不够还想来？没看到我们那么多人，都卷成什么样了。。。'
        ROLLBACK TRANSACTION
    END
    UPDATE xs
    SET xs.专业=@xinzhuanye
    WHERE xs.学号=@xuehao
    PRINT '好吧，你可以走了。。。'
    INSERT into changesd
    VALUES(@xuehao,@yuanzhuanye,@xinzhuanye,@pjf)
END
GO

--后记：VSCODE写SQL真的爽，还要啥自行车啊。。。（逃~）