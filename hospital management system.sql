USE hospital_management;

-- ============================================
-- DEPARTMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE
);


-- ============================================
-- DOCTORS
-- ============================================

CREATE TABLE IF NOT EXISTS doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_id INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    consultation_fee DECIMAL(10,2) NOT NULL,

    CONSTRAINT fk_doctor_department
        FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ============================================
-- ROOMS
-- ============================================

CREATE TABLE IF NOT EXISTS rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    room_type VARCHAR(50) NOT NULL,
    cost_per_day DECIMAL(10,2) NOT NULL,
    is_occupied BOOLEAN DEFAULT FALSE
);


-- ============================================
-- APPOINTMENTS
-- ============================================

CREATE TABLE IF NOT EXISTS appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled',

    CONSTRAINT fk_appointment_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_appointment_doctor
        FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ============================================
-- ADMISSIONS
-- ============================================

CREATE TABLE IF NOT EXISTS admissions (
    admission_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    room_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE DEFAULT NULL,
    status VARCHAR(20) DEFAULT 'Admitted',

    CONSTRAINT fk_admission_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_admission_room
        FOREIGN KEY (room_id)
        REFERENCES rooms(room_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


-- ============================================
-- BILLS
-- ============================================

CREATE TABLE IF NOT EXISTS bills (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    admission_id INT DEFAULT NULL,
    doctor_charge DECIMAL(10,2) DEFAULT 0,
    room_charge DECIMAL(10,2) DEFAULT 0,
    other_charge DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(10,2) DEFAULT 0,
    payment_status VARCHAR(20) DEFAULT 'Pending',

    CONSTRAINT fk_bill_patient
        FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,

    CONSTRAINT fk_bill_admission
        FOREIGN KEY (admission_id)
        REFERENCES admissions(admission_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
);


-- ============================================
-- SAMPLE DEPARTMENTS
-- ============================================

INSERT IGNORE INTO departments (dept_name) VALUES
('General Medicine'),
('Cardiology'),
('Orthopedics'),
('Pediatrics'),
('Neurology');


-- ============================================
-- SAMPLE DOCTORS
-- ============================================

INSERT INTO doctors
(dept_id, name, specialization, consultation_fee)
SELECT dept_id, 'Dr. Rajesh Kumar', 'General Physician', 500
FROM departments
WHERE dept_name = 'General Medicine'
AND NOT EXISTS (
    SELECT 1 FROM doctors
    WHERE name = 'Dr. Rajesh Kumar'
);

INSERT INTO doctors
(dept_id, name, specialization, consultation_fee)
SELECT dept_id, 'Dr. Anil Sharma', 'Cardiologist', 800
FROM departments
WHERE dept_name = 'Cardiology'
AND NOT EXISTS (
    SELECT 1 FROM doctors
    WHERE name = 'Dr. Anil Sharma'
);

INSERT INTO doctors
(dept_id, name, specialization, consultation_fee)
SELECT dept_id, 'Dr. Meena Rao', 'Orthopedic Specialist', 700
FROM departments
WHERE dept_name = 'Orthopedics'
AND NOT EXISTS (
    SELECT 1 FROM doctors
    WHERE name = 'Dr. Meena Rao'
);

INSERT INTO doctors
(dept_id, name, specialization, consultation_fee)
SELECT dept_id, 'Dr. Priya Singh', 'Pediatrician', 600
FROM departments
WHERE dept_name = 'Pediatrics'
AND NOT EXISTS (
    SELECT 1 FROM doctors
    WHERE name = 'Dr. Priya Singh'
);

INSERT INTO doctors
(dept_id, name, specialization, consultation_fee)
SELECT dept_id, 'Dr. Ravi Reddy', 'Neurologist', 900
FROM departments
WHERE dept_name = 'Neurology'
AND NOT EXISTS (
    SELECT 1 FROM doctors
    WHERE name = 'Dr. Ravi Reddy'
);


-- ============================================
-- SAMPLE ROOMS
-- ============================================

INSERT INTO rooms (room_type, cost_per_day, is_occupied)
SELECT 'General Ward', 1000, FALSE
WHERE NOT EXISTS (
    SELECT 1 FROM rooms
    WHERE room_type = 'General Ward'
);

INSERT INTO rooms (room_type, cost_per_day, is_occupied)
SELECT 'Private Room', 2500, FALSE
WHERE NOT EXISTS (
    SELECT 1 FROM rooms
    WHERE room_type = 'Private Room'
);

INSERT INTO rooms (room_type, cost_per_day, is_occupied)
SELECT 'ICU', 5000, FALSE
WHERE NOT EXISTS (
    SELECT 1 FROM rooms
    WHERE room_type = 'ICU'
);

INSERT INTO rooms (room_type, cost_per_day, is_occupied)
SELECT 'General Ward', 1000, FALSE
WHERE (
    SELECT COUNT(*) FROM rooms WHERE room_type = 'General Ward'
) < 2;

INSERT INTO rooms (room_type, cost_per_day, is_occupied)
SELECT 'Private Room', 2500, FALSE
WHERE (
    SELECT COUNT(*) FROM rooms WHERE room_type = 'Private Room'
) < 2;

INSERT INTO rooms (room_type, cost_per_day, is_occupied)
SELECT 'ICU', 5000, FALSE
WHERE (
    SELECT COUNT(*) FROM rooms WHERE room_type = 'ICU'
) < 2;


-- ============================================
-- SAMPLE APPOINTMENTS
-- ============================================

INSERT INTO appointments
(patient_id, doctor_id, appointment_date, status)
SELECT 1, 1, '2026-10-01 10:00:00', 'Scheduled'
WHERE EXISTS (SELECT 1 FROM patients WHERE patient_id = 1)
AND NOT EXISTS (
    SELECT 1 FROM appointments
    WHERE patient_id = 1
    AND doctor_id = 1
    AND appointment_date = '2026-10-01 10:00:00'
);

INSERT INTO appointments
(patient_id, doctor_id, appointment_date, status)
SELECT 2, 2, '2026-10-01 11:00:00', 'Scheduled'
WHERE EXISTS (SELECT 1 FROM patients WHERE patient_id = 2)
AND EXISTS (SELECT 1 FROM doctors WHERE doctor_id = 2)
AND NOT EXISTS (
    SELECT 1 FROM appointments
    WHERE patient_id = 2
    AND doctor_id = 2
    AND appointment_date = '2026-10-01 11:00:00'
);


-- ============================================
-- SAMPLE ADMISSIONS
-- ============================================

INSERT INTO admissions
(patient_id, room_id, admission_date, status)
SELECT 1, 2, '2026-09-28', 'Admitted'
WHERE EXISTS (SELECT 1 FROM patients WHERE patient_id = 1)
AND EXISTS (SELECT 1 FROM rooms WHERE room_id = 2)
AND NOT EXISTS (
    SELECT 1 FROM admissions
    WHERE patient_id = 1
    AND status = 'Admitted'
);


-- ============================================
-- SAMPLE BILL
-- ============================================

INSERT INTO bills
(patient_id, admission_id, doctor_charge, room_charge,
 other_charge, total_amount, payment_status)
SELECT
    a.patient_id,
    a.admission_id,
    500,
    1000,
    200,
    1700,
    'Pending'
FROM admissions a
WHERE a.patient_id = 1
AND NOT EXISTS (
    SELECT 1 FROM bills
    WHERE patient_id = 1
);


-- ============================================
-- FINAL CHECK
-- ============================================

SHOW TABLES;