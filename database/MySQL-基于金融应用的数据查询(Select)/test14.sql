-- 14) 查询每份保险金额第4高保险产品的编号和保险金额。
--     在数字序列8000,8000,7000,7000,6000中，
--     两个8000均为第1高，两个7000均为第2高,6000为第3高。
-- 请用一条SQL语句实现该查询：
SELECT
    i_id,
    i_amount
FROM
    insurance
WHERE
    i_amount = (
        SELECT
            i_amount
        FROM
            insurance
        GROUP BY
            i_amount
        ORDER BY
            i_amount DESC
        LIMIT
            3, 1
    );

/*  end  of  your code  */