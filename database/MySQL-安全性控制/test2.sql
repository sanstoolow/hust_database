-- 创建角色client_manager和fund_manager
CREATE ROLE client_manager;

CREATE ROLE fund_manager;

-- 授予client_manager对client表拥有select,insert,update的权限
GRANT
SELECT
,
    INSERT,
UPDATE ON client TO client_manager;

-- 授予client_manager对bank_card表拥有查询除银行卡余额外的select权限
GRANT
SELECT
    (b_c_id, b_number, b_type) ON bank_card TO client_manager;

-- 授予fund_manager对fund表的select,insert,update权限
GRANT
SELECT
,
    INSERT,
UPDATE ON fund TO fund_manager;

-- 将client_manager的权限授予用户tom和jerry
GRANT client_manager TO tom,
jerry;

-- 将fund_manager权限授予用户Cindy
GRANT fund_manager TO Cindy;