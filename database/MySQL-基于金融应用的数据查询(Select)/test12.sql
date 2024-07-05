-- 12) 综合客户表(client)、资产表(property)、理财产品表(finances_product)、保险表(insurance)和
--     基金表(fund)，列出客户的名称、身份证号以及投资总金额（即投资本金，
--     每笔投资金额=商品数量*该产品每份金额)，注意投资金额按类型需要查询不同的表，
--     投资总金额是客户购买的各类资产(理财,保险,基金)投资金额的总和，总金额命名为total_amount。
--     查询结果按总金额降序排序。
-- 请用一条SQL语句实现该查询：
select
    c_name,
    c_id_card,
    ifnull (ii_n, 0) + ifnull (ff_n, 0) + ifnull (pp_n, 0) as total_amount
from
    (
        (
            (
                client
                left outer join (
                    select
                        pro_c_id,
                        sum(pro_quantity * i_amount)
                    from
                        property
                        join insurance on (property.pro_pif_id = insurance.i_id)
                    where
                        pro_type = 2
                    group by
                        pro_c_id
                ) as i_n (ii_id, ii_n) on (c_id = i_n.ii_id)
            )
            left outer join (
                select
                    pro_c_id,
                    sum(pro_quantity * f_amount)
                from
                    property
                    join fund on (property.pro_pif_id = fund.f_id)
                where
                    pro_type = 3
                group by
                    pro_c_id
            ) as f_n (ff_id, ff_n) on (c_id = f_n.ff_id)
        )
        left outer join (
            select
                pro_c_id,
                sum(pro_quantity * p_amount)
            from
                property
                join finances_product on (property.pro_pif_id = finances_product.p_id)
            where
                pro_type = 1
            group by
                pro_c_id
        ) as p_n (pp_id, pp_n) on (c_id = p_n.pp_id)
    )
order by
    total_amount desc;

/*  end  of  your code  */