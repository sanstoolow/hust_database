delimiter $$

create procedure sp_night_shift_arrange_optimized(in start_date date, in end_date date)
begin
    declare done int default false;
    declare nurse1, nurse2, doctor, next_doctor char(30);
    declare cur_nurse cursor for select e_name from employee where e_type = 3 order by e_name;
    declare cur_doctor cursor for select e_name from employee where e_type = 1 order by e_name;
    declare continue handler for not found set done = true;

    open cur_nurse;
    open cur_doctor;

    fetch cur_doctor into doctor; -- 预先获取第一个医生
    fetch cur_doctor into next_doctor; -- 预先获取下一个医生

    while start_date <= end_date do
        fetch cur_nurse into nurse1;
        if done then
            close cur_nurse;
            open cur_nurse;
            set done = false;
            fetch cur_nurse into nurse1;
        end if;

        fetch cur_nurse into nurse2;
        if done then
            close cur_nurse;
            open cur_nurse;
            set done = false;
            fetch cur_nurse into nurse2;
        end if;

        if weekday(start_date) > 4 then
            if next_doctor is not null then
                set doctor = next_doctor;
                fetch cur_doctor into next_doctor;
                if done then
                    close cur_doctor;
                    open cur_doctor;
                    set done = false;
                    fetch cur_doctor into doctor;
                    fetch cur_doctor into next_doctor;
                end if;
            end if;
        end if;

        insert into night_shift_schedule (shift_date, doctor_name, nurse1_name, nurse2_name) 
        values (start_date, doctor, nurse1, nurse2);

        set start_date = date_add(start_date, interval 1 day);
    end while;

    close cur_nurse;
    close cur_doctor;
end$$

delimiter ;