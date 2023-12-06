DELIMITER //

CREATE FUNCTION calculate_price_exam(BillID INT) RETURNS INT READS SQL DATA
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE total_price INT DEFAULT 0;
	DECLARE price_exam INT;
	DECLARE price_service INT;
	DECLARE price_medician INT;

	DECLARE id_service INT;
	DECLARE id_exam INT;
    DECLARE cursorExams CURSOR FOR
        SELECT id as id_exam, service_id
        FROM examination
        where bill_id = BillID;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    IF BillID is NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Giá trị này không được bỏ trống';
    END IF;
    OPEN cursorExams;

    read_loop: LOOP
        FETCH cursorExams INTO id_exam, id_service;
        SELECT cost INTO price_service from service where id = id_service;
        
        SELECT SUM(p.quantity*m.cost) INTO price_medician
        from prescription p JOIN medicine m on p.serial_num = m.serial_num
        where p.exam_id = id_exam;
        
        SET price_exam = price_service + price_medician;
        IF done THEN
            LEAVE read_loop;
        END IF;
		SET total_price = total_price + price_exam;

    END LOOP;

    CLOSE cursorExams;
    return total_price;
END //

DELIMITER ;
