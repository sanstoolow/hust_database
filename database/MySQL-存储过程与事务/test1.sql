use fib;

-- 删除已存在的存储过程以避免重复创建
drop procedure if exists sp_fibonacci;

delimiter $$

create procedure sp_fibonacci(in m int)
begin
    -- 确保fibonacci表中只包含需要的斐波那契数列项
    truncate table fibonacci;
    
    -- 初始化两个变量用于计算斐波那契数列
    declare a bigint default 0;
    declare b bigint default 1;
    
    -- 循环变量
    declare i int default 0;
    
    -- 使用循环而非递归以提高性能
    while i < m do
        -- 交换a和b的值，并计算下一个斐波那契数
        set @temp = a;
        set a = b;
        set b = b + @temp;
        
        -- 将计算结果插入fibonacci表
        insert into fibonacci (n, fibn) values (i, a);
        
        -- 更新循环变量
        set i = i + 1;
    end while;
end$$

delimiter ;