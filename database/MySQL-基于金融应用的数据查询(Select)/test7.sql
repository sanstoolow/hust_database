-- 7) 查询身份证隶属武汉市没有买过任何理财产品的客户的名称、电话号、邮箱。
--    请用一条SQL语句实现该查询：
select
    c_name,
    c_phone,
    c_mail
from
    client
where
    c_id_card like '4201%'
    and not exists (
        SELECT
            *
        FROM
            property
        WHERE
            pro_type = 1
            and c_id = pro_c_id
    )
ORDER BY
    c_id;

/*  end  of  your code  */