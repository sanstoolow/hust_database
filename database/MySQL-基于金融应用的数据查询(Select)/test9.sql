-- 9) 查询购买了货币型(f_type='货币型')基金的用户的名称、电话号、邮箱。
--   请用一条SQL语句实现该查询：
SELECT
    c_name,
    c_phone,
    c_mail
FROM
    client
WHERE
    c_id IN (
        SELECT
            pro_c_id
        FROM
            fund,
            property
        WHERE
            pro_pif_id = f_id
            AND f_type = '货币型'
            and pro_type = 3
    )
ORDER BY
    c_id;

/*  end  of  your code  */