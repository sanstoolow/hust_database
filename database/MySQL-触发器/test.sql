use finance1;
drop trigger if exists before_property_inserted;
delimiter $$
CREATE TRIGGER before_property_inserted BEFORE INSERT ON property
FOR EACH ROW 
BEGIN
    DECLARE info VARCHAR(255) DEFAULT NULL;

    CASE new.pro_type
        WHEN 1 THEN
            IF NOT EXISTS (SELECT 1 FROM finances_product WHERE p_id = new.pro_pif_id) THEN
                SET info = CONCAT("finances product #", new.pro_pif_id, " not found!");
            END IF;
        WHEN 2 THEN
            IF NOT EXISTS (SELECT 1 FROM insurance WHERE i_id = new.pro_pif_id) THEN
                SET info = CONCAT("insurance #", new.pro_pif_id, " not found!");
            END IF;
        WHEN 3 THEN
            IF NOT EXISTS (SELECT 1 FROM fund WHERE f_id = new.pro_pif_id) THEN
                SET info = CONCAT("fund #", new.pro_pif_id, " not found!");
            END IF;
        ELSE
            SET info = CONCAT("type ", new.pro_type, " is illegal!");
    END CASE;

    IF info IS NOT NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = info;
    END IF;
END$$

delimiter ;