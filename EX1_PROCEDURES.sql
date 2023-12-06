USE clinicSystemDB;

DELIMITER //
CREATE FUNCTION isValidEmail(email VARCHAR(100)) 
  RETURNS BOOL
  BEGIN
    DECLARE email_pattern VARCHAR(100);
      SET email_pattern = '^[A-Z|a-z|0-9|.|_|%|-]+@[A-Z|a-z|0-9|.|-]+\.[A-Z|a-z]{2,4}$';
      RETURN email REGEXP email_pattern;
  END //


  CREATE FUNCTION isValidPhoneNumber(phone_num VARCHAR(15))
  RETURNS BOOL
  BEGIN
    DECLARE phone_num_pattern VARCHAR(15);
      SET phone_num_pattern = '^[0-9]{10,11}$';
      RETURN phone_num REGEXP phone_num_pattern;
  END //


CREATE PROCEDURE insertPatient(
    IN fname		VARCHAR(20),
    IN minit    	VARCHAR(20),
    IN lname		VARCHAR(20),
    IN gender 		VARCHAR(10),
    IN birthdate 	VARCHAR(20),
    IN addr			VARCHAR(255),
    IN email		VARCHAR(50),
	IN phone_num	VARCHAR(15),
    IN username		VARCHAR(50),
    IN _password	VARCHAR(255)
  )
  BEGIN

    IF LENGTH(fname) <= 1 OR LENGTH(lname) <= 1 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tên có độ dài quá ngắn! Họ hoặc tên phải > 1 kí tự';
    END IF;

    IF NOT (gender = 'male' OR gender = 'female' OR gender = 'other') THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giới tính không hợp lệ! Chỉ có 3 giá trị: NAM, NỮ và KHÁC';
      END IF;
    
      IF STR_TO_DATE(birthdate, '%d-%m-%Y') IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày sinh không hợp lệ! Định dạng ngày sinh là %d-%m-%Y';
      END IF;
      
      IF STR_TO_DATE(birthdate, '%d-%m-%Y') > CURDATE() THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày sinh phải là ngày trong quá khứ!';
      END IF;
      
      IF EXISTS (SELECT email FROM patient WHERE patient.email = email) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email đã được sử dụng!';
      END IF;
      
    IF NOT (SELECT isValidEmail(email)) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email không hợp lệ!';
      END IF;
      
    IF NOT (SELECT isValidPhoneNumber(phone_num)) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số điện thoại không hợp lệ! Độ dài từ 10 đến 11 số';
      END IF;
      
      IF LENGTH(username) < 6 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username ít nhất có 6 kí tự!';
      END IF;
      
      IF EXISTS (SELECT username FROM patient WHERE patient.username = username) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Username đã tồn tại!';
      END IF;
      
      IF LENGTH(_password) < 8 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password ít nhất có 8 kí tự';
      END IF;
      
    INSERT INTO patient(fname, minit, lname, gender, birthdate, addr, email, phone_num, username, _password)
    VALUES (fname, minit, lname, gender, STR_TO_DATE(birthdate, '%d-%m-%Y'), addr, email, phone_num, username, SHA2(_password, 256));
      
  END //

CREATE PROCEDURE updateInfoPatient(
    IN id       INT,
    IN fname		VARCHAR(20),
    IN minit    	VARCHAR(20),
    IN lname		VARCHAR(20),
    IN gender 		VARCHAR(10),
    IN birthdate 	VARCHAR(20),
    IN addr			VARCHAR(255),
    IN email		VARCHAR(50),
	IN phone_num	VARCHAR(15),
  )
  BEGIN

    IF LENGTH(fname) <= 1 OR LENGTH(lname) <= 1 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tên có độ dài quá ngắn! Họ hoặc tên phải > 1 kí tự';
    END IF;

    IF NOT (gender = 'NAM' OR gender = 'NỮ' OR gender = 'KHÁC') THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giới tính không hợp lệ! Chỉ có 3 giá trị: NAM, NỮ và KHÁC';
      END IF;
    
      IF STR_TO_DATE(birthdate, '%d-%m-%Y') IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày sinh không hợp lệ! Định dạng ngày sinh là %d-%m-%Y';
      END IF;
      
      IF STR_TO_DATE(birthdate, '%d-%m-%Y') > CURDATE() THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ngày sinh phải là ngày trong quá khứ!';
      END IF;
      
      IF EXISTS (SELECT email FROM patient WHERE patient.email = email) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email đã được sử dụng!';
      END IF;
      
    IF NOT (SELECT isValidEmail(email)) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email không hợp lệ!';
      END IF;
      
    IF NOT (SELECT isValidPhoneNumber(phone_num)) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Số điện thoại không hợp lệ! Độ dài từ 10 đến 11 số';
      END IF;
      
  
	UPDATE patient
  SET patient.fname = fname, patient.minit = minit, patient.lname = lname, patient.gender = gender, patient.birthdate = birthdate, patient.addr = addr, patient.email = email, patient.phone_num = phone_num
	WHERE patient.id = id
    
  END //
CREATE PROCEDURE updatePasswordById(
	IN id	INT,
  IN _password			VARCHAR(255),
  )
  BEGIN
    IF NOT EXISTS(SELECT username FROM patient WHERE patient.id = id) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User không tồn tại';
      END IF;
      
    IF LENGTH(_password) < 8 THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Password ít nhất có 8 kí tự';
      END IF;
      
      UPDATE patient
      SET patient._password = SHA2(_password, 256)
      WHERE patient.id = id;
  END //

CREATE PROCEDURE deleteUserById(
    IN id		INT
  )
  BEGIN
    IF NOT EXISTS(SELECT id FROM patient WHERE patient.id = id) THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Id của user không tồn tại';
      END IF;
      DELETE FROM patient WHERE patient.id = id;	
  END //

  DELIMITER ;




