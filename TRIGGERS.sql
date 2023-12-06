DELIMITER //

CREATE TRIGGER before_insert_patient_appointment
BEFORE INSERT ON patient_appointment
FOR EACH ROW
BEGIN
    DECLARE appointment_time TIME;
    DECLARE cur_time TIME;

    DECLARE appointment_date DATE;
    DECLARE cur_date DATE;

    DECLARE max_people INT;
    DECLARE cur_people INT;

    SET cur_time = current_time();
    SET cur_date = CURDATE();

    SELECT _date, _time, max_people, cur_people
    INTO appointment_date, appointment_time, max_people, cur_people
    FROM appointment
    WHERE appointment.id = NEW.app_id;

    -- Check if the appointment date is in the past
    IF appointment_date < cur_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lịch hẹn đã quá hạn';
    END IF;

    -- Check if the appointment time is less than 30 minutes from the current time
    IF TIMEDIFF(appointment_time, cur_time) < '00:30:00' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể đặt lịch hẹn ít hơn 30 phút trước thời gian khám.';
    END IF;

    -- Check if the maximum number of people for the appointment is reached
    IF cur_people >= max_people THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số người khám tại một khung giờ đã tối đa.';
    END IF;

    -- Update the appointment status if the current number of people is one less than the maximum
    IF cur_people + 1 = max_people THEN
        UPDATE appointment SET _status = 1 WHERE id = NEW.app_id;
    END IF;

    -- Update the current number of people
    UPDATE appointment SET cur_people = cur_people + 1 WHERE id = NEW.app_id;
END;
//

DELIMITER ;



DELIMITER //
CREATE TRIGGER before_insert_examination
BEFORE INSERT ON examination
FOR EACH ROW
BEGIN
    DECLARE id_bill INT;
	IF NOT EXISTS(SELECT * FROM examination WHERE patient_id = NEW.patient_id AND app_id = NEW.app_id ) THEN
		INSERT INTO bill(total_cost, _status) VALUES (0, 0);
        SET id_bill = LAST_INSERT_ID();
	ELSE
		SELECT bill_id INTO id_bill FROM examination WHERE patient_id = NEW.patient_id AND app_id = NEW.app_id;
    END IF;
    SET NEW.bill_id = id_bill;
END;
//
DELIMITER ;
