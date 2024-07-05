SELECT c_name, c_phone, b_number
FROM client, bank_card
WHERE c_id = b_c_id
  AND b_type = '储蓄卡'
ORDER BY c_id;


-- 从finances_product表中选择产品ID、金额和年份S
SELECT p_id, p_amount, p_year
FROM finances_product
--选择金额在30000到50000之间的记录
WHERE p_amount BETWEEN 30000 AND 50000
-- 按金额升序排列，年份降序排列
ORDER BY p_amount, p_year DESC;


-- 查询资产表中所有资产记录里商品收益的众数和它出现的次数
SELECT pro_income, COUNT(pro_income) AS presence
FROM property
GROUP BY pro_income
HAVING COUNT(pro_income) = (
    -- 子查询：找到商品收益出现次数的最大值
    SELECT MAX(count_pro_income)
    FROM (
        SELECT COUNT(pro_income) AS count_pro_income
        FROM property
        GROUP BY pro_income
    ) AS subquery
);

/* end of your code */

-- 查询当前总的可用资产收益前三名的客户的名称、身份证号及其总收益
SELECT c.c_name, c.c_id_card, p.total_income
FROM (
    -- 子查询：计算每个客户的总收益
    SELECT pro_c_id, SUM(pro_income) AS total_income
    FROM property
    WHERE pro_status = '可用'
    GROUP BY pro_c_id
    ORDER BY total_income DESC
    LIMIT 3
) AS p
JOIN client AS c ON c.c_id = p.pro_c_id
ORDER BY p.total_income DESC;

/* end of your code */

-- 综合客户表(client)、资产表(property)、理财产品表(finances_product)、保险表(insurance)、基金表(fund)和投资资产表(property)
-- 列出所有客户的编号、名称和总资产，总资产命名为total_property
-- 总资产为储蓄卡余额，投资总额，投资总收益的和，再扣除信用卡透支的金额(信用卡余额即为透支金额)
-- 客户总资产包括被冻结的资产

SELECT c.c_id, c.c_name,
       IFNULL(b.balance, 0) + IFNULL(i.investment, 0) + IFNULL(income.total_income, 0) - IFNULL(o.overdraft, 0) AS total_property
FROM client c
LEFT JOIN (
    -- 计算客户储蓄卡余额
    SELECT b_c_id, SUM(b_balance) AS balance
    FROM bank_card
    WHERE b_type = '储蓄卡'
    GROUP BY b_c_id
) b ON c.c_id = b.b_c_id
LEFT JOIN (
    -- 计算客户总投资金额
    SELECT pro_c_id,
           SUM(CASE WHEN pro_type = 1 THEN pro_quantity * p_amount ELSE 0 END) +
           SUM(CASE WHEN pro_type = 2 THEN pro_quantity * i_amount ELSE 0 END) +
           SUM(CASE WHEN pro_type = 3 THEN pro_quantity * f_amount ELSE 0 END) AS investment
    FROM property
    LEFT JOIN finances_product ON property.pro_pif_id = finances_product.p_id AND pro_type = 1
    LEFT JOIN insurance ON property.pro_pif_id = insurance.i_id AND pro_type = 2
    LEFT JOIN fund ON property.pro_pif_id = fund.f_id AND pro_type = 3
    GROUP BY pro_c_id
) i ON c.c_id = i.pro_c_id
LEFT JOIN (
    -- 计算客户总收益
    SELECT pro_c_id, SUM(pro_income) AS total_income
    FROM property
    GROUP BY pro_c_id
) income ON c.c_id = income.pro_c_id
LEFT JOIN (
    -- 计算客户信用卡透支金额
    SELECT b_c_id, SUM(b_balance) AS overdraft
    FROM bank_card
    WHERE b_type = '信用卡'
    GROUP BY b_c_id
) o ON c.c_id = o.b_c_id
ORDER BY c.c_id;

/* end of your code */
-- 以日历表格式列出2022年2月每周每日基金购买总金额

SELECT
    wk AS week_of_trading,
    SUM(IF(dayId = 0, amount, NULL)) AS Monday,
    SUM(IF(dayId = 1, amount, NULL)) AS Tuesday,
    SUM(IF(dayId = 2, amount, NULL)) AS Wednesday,
    SUM(IF(dayId = 3, amount, NULL)) AS Thursday,
    SUM(IF(dayId = 4, amount, NULL)) AS Friday
FROM (
    SELECT
        WEEK(pro_purchase_time, 1) - WEEK('2022-02-01', 1) + 1 AS wk,
        WEEKDAY(pro_purchase_time) AS dayId,
        SUM(pro_quantity * f_amount) AS amount
    FROM
        property
        JOIN fund ON property.pro_pif_id = fund.f_id
    WHERE
        pro_purchase_time BETWEEN '2022-02-01' AND '2022-02-28'
        AND pro_type = 3
    GROUP BY
        pro_purchase_time
) t
GROUP BY wk
ORDER BY wk;

/* end of your code */
-- 查询持有相同基金组合的客户对
WITH pro(c_id, f_ids) AS (
    -- 从 property 表中选择客户 ID 和基金组合
    SELECT
        pro_c_id AS c_id,
        GROUP_CONCAT(DISTINCT pro_pif_id ORDER BY pro_pif_id) AS f_ids
    FROM property
    WHERE pro_type = 3
    GROUP BY pro_c_id
)
SELECT
    t1.c_id AS c_id1,
    t2.c_id AS c_id2
FROM pro t1, pro t2
-- 仅选择编号小者在前的客户对
WHERE t1.c_id < t2.c_id
-- 筛选出持有相同基金组合的客户对
AND t1.f_ids = t2.f_ids;

/* end of your code */



-- 查询投资积极且偏好理财类产品的客户
SELECT t1.pro_c_id
FROM (
    -- 查询每个客户投资理财产品的数量
    SELECT pro_c_id, COUNT(DISTINCT pro_pif_id) AS cnt1
    FROM property
    JOIN finances_product ON pro_pif_id = p_id
    WHERE pro_type = 1
    GROUP BY pro_c_id
) AS t1
JOIN (
    -- 查询每个客户投资基金产品的数量
    SELECT pro_c_id, COUNT(DISTINCT pro_pif_id) AS cnt2
    FROM property
    JOIN fund ON pro_pif_id = f_id
    WHERE pro_type = 3
    GROUP BY pro_c_id
) AS t2 ON t1.pro_c_id = t2.pro_c_id
WHERE t1.cnt1 > t2.cnt2;

/* end of your code */

-- 查询购买了所有畅销理财产品的客户
SELECT pro_c_id
FROM (
    SELECT pro_c_id, COUNT(DISTINCT pro_pif_id) AS cnt1
    FROM property
    WHERE pro_type = 1
    AND pro_pif_id IN (
        SELECT pro_pif_id
        FROM property
        WHERE pro_type = 1
        GROUP BY pro_pif_id
        HAVING COUNT(DISTINCT pro_c_id) > 2
    )
    GROUP BY pro_c_id
) AS t
WHERE cnt1 = (
    SELECT COUNT(DISTINCT pro_pif_id)
    FROM property
    WHERE pro_type = 1
    AND pro_pif_id IN (
        SELECT pro_pif_id
        FROM property
        WHERE pro_type = 1
        GROUP BY pro_pif_id
        HAVING COUNT(DISTINCT pro_c_id) > 2
    )
);

/* end of your code */

-- 查询任意两个客户的相同理财产品数

SELECT p1.pro_c_id AS c_id1, p2.pro_c_id AS c_id2, COUNT(*) AS total_count
FROM property AS p1
INNER JOIN property AS p2 ON p1.pro_pif_id = p2.pro_pif_id
WHERE p1.pro_type = 1 AND p2.pro_type = 1
AND p1.pro_c_id < p2.pro_c_id
GROUP BY p1.pro_c_id, p2.pro_c_id
HAVING COUNT(*) >= 2
ORDER BY p1.pro_c_id, p2.pro_c_id;

/* end of your code */

USE fib;

-- 创建存储过程 sp_fibonacci，接受一个 int 类型的输入参数 m
DROP PROCEDURE IF EXISTS sp_fibonacci;
DELIMITER $$
CREATE PROCEDURE sp_fibonacci(IN m INT)
BEGIN
    DECLARE id INT DEFAULT 0;
    DECLARE cur INT DEFAULT 0;
    DECLARE pre INT DEFAULT 0;
    DECLARE next INT DEFAULT 0;

    -- 清空表 fibonacci
    DELETE FROM fibonacci;

    --初始值
    INSERT INTO fibonacci (n, fibn) VALUES (id, cur);

    SET id = id + 1;
    SET cur = 1;
    INSERT INTO fibonacci (n, fibn) VALUES (id, cur);

    --生成数列并插入表
    WHILE id < m - 1 DO
        SET next = cur + pre;
        SET pre = cur;
        SET cur = next;
        SET id = id + 1;
        INSERT INTO fibonacci (n, fibn) VALUES (id, cur);
    END WHILE;
END $$
DELIMITER ;

-- 创建表 fibonacci
DROP TABLE IF EXISTS fibonacci;
CREATE TABLE fibonacci (
    n INT PRIMARY KEY,
    fibn INT
);


USE fib;

-- 创建表 night_shift_schedule
DROP TABLE IF EXISTS night_shift_schedule;
CREATE TABLE night_shift_schedule (
    shift_date DATE,
    doctor CHAR(30),
    nurse1 CHAR(30),
    nurse2 CHAR(30)
);

DELIMITER $$
CREATE PROCEDURE sp_night_shift_arrange(IN start_date DATE, IN end_date DATE)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE nurse1 CHAR(30);
    DECLARE nurse2 CHAR(30);
    DECLARE doctor CHAR(30);
    DECLARE temp_doctor CHAR(30);
    DECLARE typ INT;

    DECLARE cur1 CURSOR FOR SELECT e_name FROM employee WHERE e_type = 3;
    DECLARE cur2 CURSOR FOR SELECT e_type, e_name FROM employee WHERE e_type < 3;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur1;
    OPEN cur2;

    WHILE start_date <= end_date DO
        -- 获取第一个护士
        FETCH cur1 INTO nurse1;
        IF done THEN
            CLOSE cur1;
            OPEN cur1;
            SET done = FALSE;
            FETCH cur1 INTO nurse1;
        END IF;

        -- 获取第二个护士
        FETCH cur1 INTO nurse2;
        IF done THEN
            CLOSE cur1;
            OPEN cur1;
            SET done = FALSE;
            FETCH cur1 INTO nurse2;
        END IF;

        -- 获取医生
        IF WEEKDAY(start_date) = 0 AND temp_doctor IS NOT NULL THEN
            SET doctor = temp_doctor;
            SET temp_doctor = NULL;
        ELSE
            FETCH cur2 INTO typ, doctor;
            IF done THEN
                CLOSE cur2;
                OPEN cur2;
                SET done = FALSE;
                FETCH cur2 INTO typ, doctor;
            END IF;

            -- 如果是周末并且医生是类型1的，则保存医生以备下周使用
            IF WEEKDAY(start_date) > 4 AND typ = 1 THEN
                SET temp_doctor = doctor;
                FETCH cur2 INTO typ, doctor;
                IF done THEN
                    CLOSE cur2;
                    OPEN cur2;
                    SET done = FALSE;
                    FETCH cur2 INTO typ, doctor;
                END IF;
            END IF;
        END IF;

        -- 插入值班表
        INSERT INTO night_shift_schedule (shift_date, doctor, nurse1, nurse2)
        VALUES (start_date, doctor, nurse1, nurse2);

        -- 日期加一天
        SET start_date = DATE_ADD(start_date, INTERVAL 1 DAY);
    END WHILE;

    CLOSE cur1;
    CLOSE cur2;
END $$
DELIMITER ;


USE finance1;

-- 创建转账操作的存储过程
DELIMITER $$
CREATE PROCEDURE sp_transfer(
    IN applicant_id INT,
    IN source_card_id CHAR(40),
    IN receiver_id INT,
    IN dest_card_id CHAR(40),
    IN amount NUMERIC(10, 2),
    OUT return_code INT
)
pro: BEGIN
    DECLARE s_id, r_id INT;
    DECLARE s_type, r_type CHAR(30);
    DECLARE s_b, rcv_amount NUMERIC(10, 2) DEFAULT amount;

    -- 获取源卡信息
    SELECT b_c_id, b_balance, b_type
    INTO s_id, s_b, s_type
    FROM bank_card
    WHERE b_number = source_card_id;

    -- 获取目标卡信息
    SELECT b_c_id, b_type
    INTO r_id, r_type
    FROM bank_card
    WHERE b_number = dest_card_id;

    -- 检查是否满足转账条件
    IF (s_type = '储蓄卡' AND s_b < amount) OR
       (s_type = '信用卡' AND r_type = '储蓄卡') OR
       (s_id != applicant_id) OR
       (r_id != receiver_id) THEN
        SET return_code = 0;
        LEAVE pro;
    END IF;

    -- 如果目标卡是信用卡，接收金额变为负值
    IF r_type = '信用卡' THEN
        SET rcv_amount = -rcv_amount;
    END IF;

    -- 如果源卡是信用卡，转出金额变为负值
    IF s_type = '信用卡' THEN
        SET amount = -amount;
    END IF;

    -- 更新源卡和目标卡的余额
    UPDATE bank_card
    SET b_balance = b_balance - amount
    WHERE b_number = source_card_id;

    UPDATE bank_card
    SET b_balance = b_balance + rcv_amount
    WHERE b_number = dest_card_id;

    SET return_code = 1;
END$$
DELIMITER ;





USE finance1;
DROP TRIGGER IF EXISTS before_property_inserted;

DELIMITER $$
CREATE TRIGGER before_property_inserted BEFORE INSERT ON property
FOR EACH ROW 
BEGIN
    DECLARE info VARCHAR(40);
    
    -- 检查 pro_type 并验证 pro_pif_id 是否存在于对应的表中
    IF NEW.pro_type = 1 THEN
        IF NEW.pro_pif_id NOT IN (SELECT p_id FROM finances_product) THEN
            SET info = CONCAT("finances product #", NEW.pro_pif_id, " not found!");
        END IF;
    ELSEIF NEW.pro_type = 2 THEN
        IF NEW.pro_pif_id NOT IN (SELECT i_id FROM insurance) THEN
            SET info = CONCAT("insurance #", NEW.pro_pif_id, " not found!");
        END IF;
    ELSEIF NEW.pro_type = 3 THEN
        IF NEW.pro_pif_id NOT IN (SELECT f_id FROM fund) THEN
            SET info = CONCAT("fund #", NEW.pro_pif_id, " not found!");
        END IF;
    ELSE
        SET info = CONCAT("type ", NEW.pro_type, " is illegal!");
    END IF;

    -- 如果 info 不为空，抛出错误
    IF info IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = info;
    END IF;

END$$
DELIMITER ;




USE finance1;
-- 允许创建函数
SET GLOBAL log_bin_trust_function_creators = 1;

DROP FUNCTION IF EXISTS get_deposit;
-- 创建函数 get_deposit
DELIMITER $$
CREATE FUNCTION get_deposit(client_id INT)
RETURNS NUMERIC(10,2)
BEGIN
    DECLARE total_deposit NUMERIC(10,2);
    
    SELECT SUM(b_balance)
    INTO total_deposit
    FROM bank_card
    WHERE b_type = '储蓄卡' AND b_c_id = client_id;
    
    RETURN IFNULL(total_deposit, 0);
END$$
DELIMITER ;
SELECT
    c_id_card,
    c_name,
    get_deposit(c_id) AS total_deposit
FROM client
WHERE get_deposit(c_id) >= 1000000
ORDER BY total_deposit DESC;


-- 事务1:

USE testdb1;
START TRANSACTION;
SET @n = SLEEP(6);
SELECT tickets FROM ticket WHERE flight_no = 'MU2455';
SELECT tickets FROM ticket WHERE flight_no = 'MU2455';
COMMIT;
-- 事务2:
USE testdb1;
START TRANSACTION;
SET @n = SLEEP(2);
UPDATE ticket SET tickets = tickets - 1 WHERE flight_no = 'MU2455';
COMMIT;

-- 延迟2秒

-- 更新票数

-- 提交事务


use testdb1;
# 设置事务的隔离级别为 read uncommitted
set session transaction isolation level read uncommitted;
-- 开启事务
start transaction;
insert into dept(name) values('运维部');
# 回滚事务：
rollback;
/* 结束 */






-- 事务1:
use testdb1;
## 请设置适当的事务隔离级别
set session transaction isolation level read uncommitted;

start transaction;

-- 时刻2 - 事务1读航班余票,发生在事务2修改之后
## 添加等待代码，确保读脏
set @n = sleep(2);
select tickets from ticket where flight_no = 'CA8213';
commit;

-- 事务2:
use testdb1;
## 请设置适当的事务隔离级别
set session transaction isolation level read uncommitted;
start transaction;

-- 时刻1 - 事务2修改航班余票
update ticket set tickets = tickets - 1 where flight_no = 'CA8213';

-- 时刻3 - 事务2 取消本次修改
## 请添加代码，使事务1在事务2撤销前读脏;
set @n = sleep(4);
rollback;


-- 事务1:
use testdb1;
set session transaction isolation level read uncommitted;
start transaction;
# 第1次查询航班'MU2455'的余票
select tickets from ticket where flight_no = 'MU2455' for update;
set @n = sleep(5);
# 第2次查询航班'MU2455'的余票
select tickets from ticket where flight_no = 'MU2455' for update;
commit;
-- 第3次查询所有航班的余票，发生在事务2提交后
set @n = sleep(1);
select * from ticket;

-- 事务2:
use testdb1;
set session transaction isolation level read uncommitted;
start transaction;
set @n = sleep(1);
# 在事务1的第1，2次查询之间，试图出票1张(航班MU2455)：
update ticket set tickets = tickets - 1 where flight_no = 'MU2455';
commit;
