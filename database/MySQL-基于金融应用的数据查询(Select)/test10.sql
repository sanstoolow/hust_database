-- 10) 查询当前总的可用资产收益(被冻结的资产除外)前三名的客户的名称、身份证号及其总收益，按收益降序输出，总收益命名为total_income。不考虑并列排名情形。
--    请用一条SQL语句实现该查询：
SELECT
    c_name,
    c_id_card,
    Sum_pro.sum_income AS total_income
FROM
    (
        SELECT
            pro_c_id,
            SUM(pro_income)
        FROM
            (
                SELECT
                    *
                FROM
                    property
                where
                    pro_status = '可用'
            ) as temp1
        GROUP BY
            pro_c_id
    ) AS Sum_pro (id, sum_income),
    client
WHERE
    c_id = id
ORDER BY
    Sum_pro.sum_income DESC
limit
    3;

/*  end  of  your code  */