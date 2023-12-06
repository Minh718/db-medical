CREATE DATABASE IF NOT EXISTS clinicSystemDB;
USE clinicSystemDB;

SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE IF NOT EXISTS clinic
(
	id					INT 				AUTO_INCREMENT,
    _name				VARCHAR(50)			UNIQUE,
    address				VARCHAR(255)			UNIQUE,
    email    			VARCHAR(100)		NOT NULL,
    _desc				VARCHAR(255),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS room
(
	num					INT,
    clinic_id			INT,
    _name				VARCHAR(50)			NOT NULL,
	_desc				VARCHAR(200),
    _status				VARCHAR(50)			NOT NULL,
    doctor_id 			INT,
    
    PRIMARY KEY (num, clinic_id),
    
    CONSTRAINT room_check_1 CHECK (_status = "KHÔNG HOẠT ĐỘNG" OR _status = "HOẠT ĐỘNG"),
    
	CONSTRAINT fk_room_doctor_id FOREIGN KEY (doctor_id)
		REFERENCES doctor(id) 
		ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS appointment
(
	id 					INT 				AUTO_INCREMENT,
    _time				TIME				NOT NULL,
    _end_time				TIME				NOT NULL,
    _date				DATE				NOT NULL,
	cur_people			INT					NOT NULL DEFAULT 0,
    max_people			INT					NOT NULL,
    _status	 			INT					NOT NULL,
    clinic_id			INT,
    
    PRIMARY KEY (id),
    
    CONSTRAINT appointment_check_1 
		CHECK (cur_people >= 0),
	CONSTRAINT appointment_check_2
		CHECK (max_people >= 0),    
    
    CONSTRAINT fk_appointment_clinic_id FOREIGN KEY (clinic_id)
		REFERENCES clinic(id)
        ON DELETE SET NULL
);

-- CREATE TABLE IF NOT EXISTS _user
-- (
-- 	id 					INT					AUTO_INCREMENT,
--     fname				VARCHAR(20)			NOT NULL,
--     minit				VARCHAR(20),
--     lname 				VARCHAR(20)			NOT NULL,
--     gender				VARCHAR(10)			NOT NULL,
-- 	birthdate			DATE				NOT NULL,
--     addr				VARCHAR(255),
--     email 				VARCHAR(50)			NOT NULL 	UNIQUE,
--     phone_num			VARCHAR(15)			NOT NULL,
--     is_active			BOOL				NOT NULL 	DEFAULT TRUE,
--     username			VARCHAR(50)			NOT NULL 	UNIQUE,
--     _password			VARCHAR(255) 		NOT NULL,
--     type          VARCHAR(20)			NOT NULL ,
    
--     CONSTRAINT user_check_1
-- 		CHECK (gender = "male" OR gender = "female" OR gender="other"),
--     CHECK (type = "user" OR type = "staff"),
--     PRIMARY KEY (id)
-- );

CREATE TABLE IF NOT EXISTS patient
(
	id 					INT					AUTO_INCREMENT,
    fname				VARCHAR(20)			NOT NULL,
    minit				VARCHAR(20),
    lname 				VARCHAR(20)			NOT NULL,
    gender				VARCHAR(10)			NOT NULL,
	birthdate			DATE				NOT NULL,
    addr				VARCHAR(255),
    email 				VARCHAR(50)			NOT NULL 	UNIQUE,
    phone_num			VARCHAR(15)			NOT NULL,
    is_active			BOOL				NOT NULL 	DEFAULT TRUE,
    username			VARCHAR(50)			NOT NULL 	UNIQUE,
    _password			VARCHAR(255) 		NOT NULL,

    CONSTRAINT user_check_1
		CHECK (gender = "male" OR gender = "female" OR gender="other"),
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS medical_staff
(
	id 					INT					AUTO_INCREMENT,
    fname				VARCHAR(20)			NOT NULL,
    minit				VARCHAR(20),
    lname 				VARCHAR(20)			NOT NULL,
    gender				VARCHAR(10)			NOT NULL,
	birthdate			DATE				NOT NULL,
    addr				VARCHAR(255),
    email 				VARCHAR(50)			NOT NULL 	UNIQUE,
    phone_num			VARCHAR(15)			NOT NULL,
    is_active			BOOL				NOT NULL 	DEFAULT TRUE,
    username			VARCHAR(50)			NOT NULL 	UNIQUE,
    _password			VARCHAR(255) 		NOT NULL,
    start_date 			DATE				DEFAULT NOW(),
    YOE 				INT					NOT NULL,
    license_number 		VARCHAR(50)			NOT NULL,
    salary 				INT					NOT NULL,
    role            VARCHAR(20) NOT NULL,        
    
    CONSTRAINT user_check_1
		CHECK (gender = "male" OR gender = "female" OR gender="other"),
    PRIMARY KEY (id)
    
		CHECK (role = "doctor" OR role = "nurse"),
    CONSTRAINT medical_staff_check_1 
		CHECK (YOE >= 0),
        
	CONSTRAINT medical_staff_check_2
		CHECK (salary >= 0),
);

CREATE TABLE IF NOT EXISTS doctor
(
	id 					INT 				PRIMARY KEY,
    specialty			VARCHAR(50)			NOT NULL,
    
    CONSTRAINT fk_doctor_id FOREIGN KEY (id)
		REFERENCES medical_staff(id) 
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS  nurse
(
	id 					INT 				PRIMARY KEY,
  
    
    CONSTRAINT fk_nurse_id FOREIGN KEY (id)
		REFERENCES medical_staff(id) 
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS examination
(
	id 					INT 				AUTO_INCREMENT,
    diagnose 			VARCHAR(100)		NOT NULL,
    _desc 				VARCHAR(50),
    image 				VARCHAR(100),
    total_price			INT					NOT NULL DEFAULT 0,
    doctor_id			INT,
    patient_id 			INT,
    app_id 				INT,
    bill_id				INT,
    service_id			INT,
    
    PRIMARY KEY (id),
    
	CONSTRAINT fk_examination_doctoc_id 	FOREIGN KEY (doctor_id)
		REFERENCES doctor(id) 					
		ON DELETE SET NULL,
    CONSTRAINT fk_examination_patient_id 	FOREIGN KEY (patient_id)
		REFERENCES patient(id) 					
		ON DELETE SET NULL,
    CONSTRAINT fk_examination_app_id 		FOREIGN KEY (app_id)
		REFERENCES appointment(id) 				
        ON DELETE SET NULL,
    CONSTRAINT fk_examination_bill_id 		FOREIGN KEY (bill_id)
		REFERENCES bill(id) 					
        ON DELETE SET NULL,
    CONSTRAINT fk_examination_service_id 	FOREIGN KEY (service_id)
		REFERENCES service(id) 					
        ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS bill
(
	id 					INT					AUTO_INCREMENT,
    total_cost			INT					NOT NULL DEFAULT 0,
    _status 			BOOL				NOT NULL DEFAULT FALSE, /* 0: Not pay yet, 1: Paid */
    _timestamp 			DATE 			NOT NULL DEFAULT (CURDATE()),
    due_date 			DATE 			NOT NULL DEFAULT (CURDATE()),
    
    PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS medicine
(
	serial_num 			VARCHAR(50) 		PRIMARY KEY,
    _name 				VARCHAR(50)			NOT NULL,
    cost 				INT					NOT NULL,
    _desc 				VARCHAR(50),
    
    CONSTRAINT medicine_check_1	
		CHECK (cost > 0)
		
);

CREATE TABLE IF NOT EXISTS service
(
	id					INT					PRIMARY KEY,
    _name 				VARCHAR(50)			NOT NULL,
    cost 				INT					NOT NULL,
    _desc 				VARCHAR(50),
    
    CONSTRAINT service_check_1
		CHECK (cost > 0)
);

CREATE TABLE IF NOT EXISTS work_at
(
	ms_id 				INT					PRIMARY KEY,
    room_num 			INT,
    clinic_id 			INT,
    
    CONSTRAINT fk_work_at_ms_id					FOREIGN KEY (ms_id)
		REFERENCES medical_staff(id)				
        ON DELETE CASCADE,
    
    CONSTRAINT fk_work_at_room_num_clinic_id	FOREIGN KEY (room_num, clinic_id)
		REFERENCES room(num, clinic_id)				
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS work_with
(
	nurse_id 			INT						PRIMARY KEY,
    doctor_id 			INT,
    
    CONSTRAINT fk_work_with_nurse_id 			FOREIGN KEY (nurse_id)
		REFERENCES nurse(id)						
        ON DELETE CASCADE,
        
    CONSTRAINT fk_work_with_doctoc_id 			FOREIGN KEY (doctor_id)
		REFERENCES doctor(id)						
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS patient_appointment
(
	patient_id 			INT,
    app_id 				INT,
    _status 			VARCHAR(50) DEFAULT "UNCONFIRM",
    
    PRIMARY KEY (patient_id, app_id),
    
    CONSTRAINT app_of_patient_check_1
		CHECK (_status ="UNCONFIRM" OR _status ="CONFIRM"),
    
    CONSTRAINT fk_patient_appointment_patient_id 	FOREIGN KEY (patient_id)
		REFERENCES patient(id) 						
        ON DELETE CASCADE,
    
    CONSTRAINT fk_patient_appointment_app_id 		FOREIGN KEY (app_id)
		REFERENCES appointment(id) 					
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS medicine_in_clinic
(
	clinic_id 			INT,
    serial_num 			VARCHAR(50),
    quantity 			INT					NOT NULL DEFAULT 0,
    
    CONSTRAINT medicine_in_clinic_check_1
		CHECK (quantity >= 0),
    
    PRIMARY KEY (clinic_id, serial_num),
    
    CONSTRAINT fk_medicine_in_clinic_clinic_id 		FOREIGN KEY (clinic_id)
		REFERENCES clinic(id) 							
        ON DELETE CASCADE,
    
    CONSTRAINT fk_medicine_in_clinic_serial_num 	FOREIGN KEY (serial_num)
		REFERENCES medicine(serial_num) 				
        ON DELETE CASCADE,
    
    CHECK (quantity > 0)
);

CREATE TABLE IF NOT EXISTS prescription
(
	exam_id 			INT,
    serial_num			VARCHAR(50),
    _desc				VARCHAR(50),
    quantity 			INT					NOT NULL DEFAULT 0,
    
	PRIMARY KEY (exam_id, serial_num),
    
    CONSTRAINT prescription_check_1
		CHECK (quantity >= 0),
    
    CONSTRAINT fk_prescription_exam_id			FOREIGN KEY (exam_id)
		REFERENCES examination(id)					
        ON DELETE CASCADE,
    
    CONSTRAINT fk_prescription_serial_num 		FOREIGN KEY (serial_num)
		REFERENCES medicine(serial_num)				
        ON DELETE CASCADE,
    
    CHECK (quantity > 0)
);

CREATE TABLE IF NOT EXISTS clinic_hotline(
	clinic_id 			INT,
    hotline				INT,
    
    PRIMARY KEY (clinic_id, hotline),
    
    CONSTRAINT fk_clinic_hotline_clinic_id 		FOREIGN KEY (clinic_id)
		REFERENCES clinic(id) 						
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS clinic_worktime
(
	clinic_id 			INT,
    weekdays			VARCHAR(15),
    open_time			TIME,
    close_time			TIME,
    
    PRIMARY KEY (clinic_id, weekdays, open_time, close_time),
    
    CONSTRAINT clinic_worktime_check_1 CHECK (open_time < close_time),
    
    CONSTRAINT fk_clinic_worktime_clinic_id 		FOREIGN KEY (clinic_id)
		REFERENCES clinic(id) 					
        ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS examination_allergy(
	exam_id 			INT,
    allergy				INT,
    
    PRIMARY KEY (exam_id, allergy),
    
    CONSTRAINT fk_patient_allergy_exam_id FOREIGN KEY (exam_id)
		REFERENCES examination(id) 						
        ON DELETE CASCADE
);

SET FOREIGN_KEY_CHECKS=1;

DELIMITER //

CREATE TRIGGER check_password
BEFORE INSERT ON patient
FOR EACH ROW
BEGIN
    DECLARE password_length INT;
    DECLARE contains_digit BOOLEAN;
    DECLARE contains_letter BOOLEAN;

    -- Kiểm tra mật khẩu có đủ 8 ký tự không
    SET password_length = CHAR_LENGTH(NEW._password);
    IF password_length < 8 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mật khẩu phải chứa ít nhất 8 ký tự.';
    END IF;

    -- Kiểm tra mật khẩu có chứa chữ và số không
    SET contains_digit = FALSE;
    SET contains_letter = FALSE;

    WHILE password_length > 0 DO
        IF SUBSTRING(NEW._password, password_length, 1) REGEXP '[0-9]' THEN
            SET contains_digit = TRUE;
        ELSE
            SET contains_letter = TRUE;
        END IF;

        SET password_length = password_length - 1;
    END WHILE;

    IF NOT contains_digit OR NOT contains_letter THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mật khẩu phải chứa ít nhất một chữ cái và một số.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER check_insert_doctor
BEFORE INSERT ON medical_staff
FOR EACH ROW
BEGIN
	IF new.role = 'doctor' AND new.YOE < 3 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Số năm kinh nghiệm tối thiếu của bác sĩ là 3';
    END IF;

END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_appoint_patient
BEFORE INSERT ON patient_appointment
FOR EACH ROW
BEGIN
	declare timesUncomfirm INT;
	select count(*) INTO timesUncomfirm 
    from patient_appointment
    where patient_id = new.patient_id AND _status = 'UNCONFIRM';
    if timesUncomfirm >= 5 THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Không thể đăng ký cuộc hẹn vì đã lỡ hẹn quá nhiều';
    END IF;
END //

DELIMITER ;





DELIMITER //

CREATE TRIGGER check_payment_deadline
BEFORE INSERT ON bill
FOR EACH ROW
BEGIN
    DECLARE due_date DATE;

    -- Lấy ngày hiện tại
    SET current_date = CURDATE();

    -- Tính toán ngày thanh toán cuối cùng (5 ngày kể từ ngày tạo)
    SET due_date = DATE_ADD(NEW.creation_date, INTERVAL 5 DAY);
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER due_date_bill
BEFORE INSERT ON bill
FOR EACH ROW
BEGIN
    -- Tính toán ngày thanh toán cuối cùng (5 ngày kể từ ngày tạo)
    SET new.due_date = DATE_ADD(NEW._timestamp, INTERVAL 5 DAY);
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER check_salary
BEFORE INSERT ON medical_staff
FOR EACH ROW
BEGIN
    -- Kiểm tra nếu là bác sĩ và có y tá có lương cao hơn
	IF NEW.role = 'doctor' AND EXISTS(SELECT * FROM medical_staff WHERE role = 'nurse' AND salary > NEW.salary) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Lương của bác sĩ không thể thấp hơn lương của y tá.';
    END IF;

    -- Kiểm tra nếu là y tá và có bác sĩ có lương thấp hơn
	IF NEW.role = 'nurse' AND EXISTS(SELECT * FROM medical_staff WHERE role = 'doctor' AND salary < NEW.salary) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lương của y tá phải thấp hơn lương của bác sĩ.';
    END IF;
END //

DELIMITER ;