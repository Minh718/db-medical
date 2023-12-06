DELIMITER //

CREATE PROCEDURE GetAppointmentStatus(
    IN p_app_date DATE,
    IN clinic_id INT
)
BEGIN
    SELECT
        a.id AS appointment_id,
        a._time AS time_start ,
        a._end_time AS time_end ,
        a.cur_people AS people_registed,
        a.max_people AS max_people,
        COUNT(CASE WHEN p._status = 'CONFIRM' THEN 1 END) AS count_confirm,
        COUNT(CASE WHEN p._status = 'UNCONFIRM' THEN 1 END) AS count_unconfirm
    FROM
        appointment a JOIN patient_appointment p ON a.id = p.app_id
    WHERE
        a._date = p_app_date
        AND a.clinic_id = clinic_id
    GROUP BY
        a.id
    ORDER BY
        a._date;

END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE getPeopleVisitInTheMonth(
    IN _month INT,
    IN clinic_id INT
)
BEGIN
    SELECT
		p.id,
        p.fname,
        p.minit,
        p.lname,
        p.birthdate,
        p.addr,
        p.email,
        p.phone_num,
         COUNT(p.id) AS lankham
    FROM
        appointment a 
        JOIN patient_appointment pa ON a.id = pa.app_id
        JOIN patient p ON pa.patient_id = p.id
    WHERE
        MONTH(a._date) = _month
        AND a.clinic_id = clinic_id AND
        pa._status = 'CONFIRM'
    GROUP BY
        p.id
    ORDER BY
        COUNT(p.id) ASC;

END //

DELIMITER ;


