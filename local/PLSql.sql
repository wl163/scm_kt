-- 声明变量
declare
    v_price    number(10, 2); -- 单价
    v_usernum  number; -- 水费字数
    v_usernum2 number(10, 2);--吨数
    v_money    number(10, 2); -- 金额
begin
    v_price := 2.5;
    v_usernum := 2819;
    v_usernum2 := round(v_usernum / 1000, 2);-- 吨数
    v_money := v_usernum2 * v_price;
    DBMS_OUTPUT.put_line('金额:' || v_money);
end;

-- select into 赋值
declare
    v_price    number(10, 2); -- 单价
    v_usernum  number; -- 水费字数
    v_usernum2 number(10, 2);--吨数
    v_money    number(10, 2); -- 金额
begin
    v_price := 2.5;
    select NUM0 into v_usernum from T_ACCOUNT where id =1;
    v_usernum2 := round(v_usernum / 1000, 2);-- 吨数
    v_money := v_usernum2 * v_price;
end;


-- while循环
declare
    v_num number(10, 2);
begin
    v_num := 1;
    while v_num <= 10
        loop
            DBMS_OUTPUT.put_line(v_num);
            v_num := v_num + 1;
        end loop;
end;

/*  for循环 */
begin
    for i in 1.. 100
        loop
            DBMS_OUTPUT.put_line(i);
        end loop;
end;

select * from T_PRICETABLE where OWNERTYPEID=1;
select * from T_ACCOUNT ;

-- 记录型
declare
    v_price1  number(10, 2);
    v_price2  number(10, 2);
    v_price3  number(10, 2);
    v_num2    number(10, 2); -- 吨数
    v_money   number(10, 2);
    v_account T_ACCOUNT%rowtype; -- 记录型
begin
    v_price1 := 2.45;
    v_price2 := 3.45;
    v_price3 := 4.45;
    select * into v_account from T_ACCOUNT where year = '2012' and month = '01' and owneruuid = 1;
    -- 使用吨数
    v_num2 := round(v_account.USENUM / 1000, 2);
    if v_num2 <= 5 then
        v_money := v_num2 * v_price1;
    elsif v_num2 > 5 and v_num2 <= 10 then
        v_money := v_num2 * 5 + (v_num2 - 5) * v_price2;
    elsif v_num2 > 10 then
        v_money := v_price1 * 5 + v_price2 * 5 +
                   v_price3 * (v_num2 - 10);
    end if;
     DBMS_OUTPUT.put_line(v_money);
end;

/*-- 引用类型*/
declare
    v_num   T_ACCOUNT.NUM0 %TYPE; -- 水费字数
    v_num2  T_ACCOUNT.USENUM %TYPE; -- 吨数
    v_price number(10, 2); /*单价*/
    v_money number(10, 2); /*金钱*/
begin
    select USENUM into v_num2 from T_ACCOUNT where id = 1;
    v_price := 1.45;
    v_num := 10090.44;
    v_money := v_price * v_num2;
    DBMS_OUTPUT.put_line('金额：' || v_money);
end;


-- 记录类型 以及异常处理
declare
    v_num     T_ACCOUNT.NUM0 %TYPE; -- 水费字数
    v_num2    T_ACCOUNT.USENUM %TYPE; -- 吨数
    v_price   number(10, 2); /*单价*/
    v_money   number(10, 2); /*金钱*/
    v_account T_ACCOUNT%rowtype; -- 记录型
begin
    select * into v_account from T_ACCOUNT;
    v_price := 1.45;
    v_num := v_account.USENUM;
    v_num2 := round(v_num / 1000);
    v_money := v_price * v_num2;
    DBMS_OUTPUT.put_line('金额：' || v_money);
exception
    when NO_DATA_FOUND then
        DBMS_OUTPUT.put_line('没找到数据');
    when TOO_MANY_ROWS then
        DBMS_OUTPUT.put_line('找到多行数据');
end;
