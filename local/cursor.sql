select * from T_ACCOUNT;
select * from T_AREA;


/*-- 游标*/
-- 打印业主类型为1的价格表
select * from T_PRICETABLE where OWNERTYPEID=1;

declare
    cursor cur_pricetable is select * from T_PRICETABLE where OWNERTYPEID = 1;
    v_pricetable T_PRICETABLE%rowtype;
begin
    open cur_pricetable;
    loop
        fetch cur_pricetable into v_pricetable; -- 提取游标并赋值到变量
        exit when cur_pricetable %notfound; -- 游标退出条件
        DBMS_OUTPUT.put_line('价格：'|| v_pricetable.PRICE || '吨位：' || v_pricetable.MINNUM || '-' || v_pricetable.MAXNUM);
    end loop;
    close cur_pricetable; -- 关闭游标
end;


-- 带参数游标
declare
    cursor cur_pricetable(owner_type_id number) is select * from T_PRICETABLE where OWNERTYPEID = owner_type_id;
    v_pricetable cur_pricetable%rowtype;
begin
    open cur_pricetable(2);
    loop
        fetch cur_pricetable into v_pricetable;
        exit when cur_pricetable%notfound;
        DBMS_OUTPUT.put_line('价格：'|| v_pricetable.PRICE || '吨位：' || v_pricetable.MINNUM || '-' || v_pricetable.MAXNUM);
    end loop;
    close cur_pricetable;
end;


-- 带参数游标  记录类型使用游标：v_pricetable cur_pricetable%rowtype;
declare
    cursor cur_pricetable(owner_type_id number) is select * from T_PRICETABLE where OWNERTYPEID = owner_type_id;
    v_pricetable cur_pricetable%rowtype;
begin
    open cur_pricetable(2);
    loop
        fetch cur_pricetable into v_pricetable;
        exit when cur_pricetable%notfound;
        DBMS_OUTPUT.put_line('价格：'|| v_pricetable.PRICE || '吨位：' || v_pricetable.MINNUM || '-' || v_pricetable.MAXNUM);
    end loop;
    close cur_pricetable;
end;

-- for循环 带参数的游标
declare
    cursor cur_pricetable(owner_type_id number) is select * from T_PRICETABLE where OWNERTYPEID = owner_type_id ;
begin
    for v_pricetable in cur_pricetable(1)
    loop
        DBMS_OUTPUT.put_line('价格：' || v_pricetable.PRICE || '吨位：' || v_pricetable.MINNUM || '-' ||
                                 v_pricetable.MAXNUM);
    end loop;
end;


select * from T_ADDRESS;
-- 存储函数
create or replace function fn_getname(v_id number)
    return varchar2
    is
    v_name varchar2(30);
begin
    select NAME into v_name from T_ADDRESS where ID = v_id;
    return v_name;
end;

select fn_getname(1) from dual;


