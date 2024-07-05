-- 13) 综合客户表(client)、资产表(property)、理财产品表(finances_product)、
--     保险表(insurance)、基金表(fund)和投资资产表(property)，
--     列出所有客户的编号、名称和总资产，总资产命名为total_property。
--     总资产为储蓄卡余额，投资总额，投资总收益的和，再扣除信用卡透支的金额
--     (信用卡余额即为透支金额)。客户总资产包括被冻结的资产。
--    请用一条SQL语句实现该查询：
-- 13) 综合客户表(client)、资产表(property)、理财产品表(finances_product)、
--     保险表(insurance)、基金表(fund)和投资资产表(property)，
--     列出所有客户的编号、名称和总资产，总资产命名为total_property。
--     总资产为储蓄卡余额，投资总额，投资总收益的和，再扣除信用卡透支的金额
--     (信用卡余额即为透支金额)。客户总资产包括被冻结的资产。
--    请用一条SQL语句实现该查询：
select
    c_id,
    c_name,
    ifnull (ii_n, 0) + ifnull (ff_n, 0) + ifnull (pp_n, 0) + ifnull (in_n, 0) + ifnull (b_n, 0) - ifnull (o_n, 0) as total_property
from
    (
        (
            (
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
                left outer join (
                    select
                        c_id,
                        ifnull (sum(pro_income), 0)
                    from
                        client
                        left outer join property on (c_id = pro_c_id)
                    group by
                        c_id
                ) as income (in_id, in_n) on (c_id = in_id)
            )
            left outer join (
                select
                    c_id,
                    ifnull (sum(b_balance), 0)
                from
                    client
                    left outer join bank_card on (c_id = b_c_id)
                where
                    b_type = '储蓄卡'
                group by
                    c_id
            ) as balance (b_id, b_n) on (c_id = b_id)
        )
        left outer join (
            select
                c_id,
                ifnull (sum(b_balance), 0)
            from
                client
                left outer join bank_card on (c_id = b_c_id)
            where
                b_type = '信用卡'
            group by
                c_id
        ) as overdraft (o_id, o_n) on (c_id = o_id)
    )
order by
    c_id;

/*  end  of  your code  */
/*  end  of  your code  */