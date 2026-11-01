-- ============================================================
-- FACE ATTENDANCE SYSTEM — POSTGRESQL SCHEMA
-- Compatible with Render PostgreSQL
-- ============================================================

-- Drop existing tables
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS student_faces CASCADE;
DROP TABLE IF EXISTS attendance_sessions CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS lecturers CASCADE;
DROP TABLE IF EXISTS test CASCADE;

-- ============================================================
-- STUDENTS TABLE
-- ============================================================
CREATE TABLE students (
    id            SERIAL PRIMARY KEY,
    student_id    VARCHAR(100) UNIQUE NOT NULL,
    full_name     VARCHAR(100) NOT NULL,
    department    VARCHAR(100) NOT NULL,
    year_intake   VARCHAR(50) NOT NULL,
    semester      INTEGER NOT NULL,
    face_token    VARCHAR(200) DEFAULT NULL,
    face_descriptor TEXT DEFAULT NULL,
    face_id       VARCHAR(100) DEFAULT NULL,
    photo_path    VARCHAR(255) DEFAULT NULL,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_student_id ON students(student_id);
CREATE INDEX idx_department ON students(department);
CREATE INDEX idx_semester ON students(semester);
CREATE INDEX idx_face_id ON students(face_id);

-- ============================================================
-- STUDENT FACES TABLE
-- ============================================================
CREATE TABLE student_faces (
    id              SERIAL PRIMARY KEY,
    student_id      VARCHAR(100) NOT NULL,
    face_token      VARCHAR(200) DEFAULT NULL,
    face_descriptor TEXT DEFAULT NULL,
    photo_path      VARCHAR(255) DEFAULT NULL,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

CREATE INDEX idx_face_token ON student_faces(face_token);
CREATE INDEX idx_sf_student_id ON student_faces(student_id);

-- ============================================================
-- LECTURERS TABLE
-- ============================================================
CREATE TABLE lecturers (
    id          SERIAL PRIMARY KEY,
    lecturer_id VARCHAR(10) UNIQUE NOT NULL,
    full_name   VARCHAR(100) NOT NULL,
    email       VARCHAR(100) UNIQUE NOT NULL,
    department  VARCHAR(100) NOT NULL,
    is_active   SMALLINT DEFAULT 1,
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_lecturer_id ON lecturers(lecturer_id);
CREATE INDEX idx_email ON lecturers(email);

-- ============================================================
-- ATTENDANCE SESSIONS TABLE
-- ============================================================
CREATE TABLE attendance_sessions (
    id                 SERIAL PRIMARY KEY,
    session_token      VARCHAR(200) UNIQUE NOT NULL,
    is_active          SMALLINT DEFAULT 0,
    lecturer_id        VARCHAR(100) NOT NULL,
    lecturer_name      VARCHAR(100) NOT NULL,
    department         VARCHAR(100) NOT NULL,
    semester           INTEGER NOT NULL,
    course_code        VARCHAR(50) NOT NULL,
    course_name        VARCHAR(100) NOT NULL,
    started_at         TIMESTAMP NOT NULL,
    expected_end_time  TIMESTAMP DEFAULT NULL,
    ended_at           TIMESTAMP DEFAULT NULL,
    total_students     INTEGER DEFAULT 0,
    marked_students    INTEGER DEFAULT 0,
    created_at         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_as_department ON attendance_sessions(department);
CREATE INDEX idx_as_semester ON attendance_sessions(semester);
CREATE INDEX idx_is_active ON attendance_sessions(is_active);

-- ============================================================
-- ATTENDANCE RECORDS TABLE
-- ============================================================
CREATE TABLE attendance (
    id          SERIAL PRIMARY KEY,
    student_id  VARCHAR(100) NOT NULL,
    session_id  INTEGER DEFAULT NULL,
    department  VARCHAR(100) DEFAULT NULL,
    semester    INTEGER DEFAULT NULL,
    course_code VARCHAR(50) DEFAULT NULL,
    course_name VARCHAR(100) DEFAULT NULL,
    date        DATE NOT NULL,
    time        TIME NOT NULL,
    confidence  INTEGER DEFAULT 0,
    status      VARCHAR(20) DEFAULT 'present',
    marked_by   VARCHAR(50) DEFAULT 'system',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES attendance_sessions(id) ON DELETE SET NULL,
    UNIQUE (student_id, session_id)
);

CREATE INDEX idx_att_date ON attendance(date);
CREATE INDEX idx_att_student_id ON attendance(student_id);
CREATE INDEX idx_att_session_id ON attendance(session_id);

-- ============================================================
-- TEST TABLE
-- ============================================================
CREATE TABLE test (
    id         SERIAL PRIMARY KEY,
    message    VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- SEED DATA
-- ============================================================

INSERT INTO test (message) VALUES ('Database is ready!');

INSERT INTO lecturers (lecturer_id, full_name, email, department) VALUES
('LEC001', 'Lecturer 1',  'lec001@school.edu', 'JSS1'),
('LEC002', 'Lecturer 2',  'lec002@school.edu', 'JSS1'),
('LEC003', 'Lecturer 3',  'lec003@school.edu', 'JSS2'),
('LEC004', 'Lecturer 4',  'lec004@school.edu', 'JSS2'),
('LEC005', 'Lecturer 5',  'lec005@school.edu', 'JSS3'),
('LEC006', 'Lecturer 6',  'lec006@school.edu', 'JSS3'),
('LEC007', 'Lecturer 7',  'lec007@school.edu', 'SS1'),
('LEC008', 'Lecturer 8',  'lec008@school.edu', 'SS1'),
('LEC009', 'Lecturer 9',  'lec009@school.edu', 'SS2'),
('LEC010', 'Lecturer 10', 'lec010@school.edu', 'SS2'),
('LEC011', 'Lecturer 11', 'lec011@school.edu', 'SS3'),
('LEC012', 'Lecturer 12', 'lec012@school.edu', 'SS3'),
('LEC013', 'Lecturer 13', 'lec013@school.edu', 'JSS1'),
('LEC014', 'Lecturer 14', 'lec014@school.edu', 'JSS2'),
('LEC015', 'Lecturer 15', 'lec015@school.edu', 'JSS3'),
('LEC016', 'Lecturer 16', 'lec016@school.edu', 'SS1'),
('LEC017', 'Lecturer 17', 'lec017@school.edu', 'SS2'),
('LEC018', 'Lecturer 18', 'lec018@school.edu', 'SS3'),
('LEC019', 'Lecturer 19', 'lec019@school.edu', 'JSS1'),
('LEC020', 'Lecturer 20', 'lec020@school.edu', 'SS1')
ON CONFLICT DO NOTHING;



-- Verify
SELECT 'students' AS table_name, COUNT(*) AS total_rows FROM students
UNION ALL
SELECT 'student_faces', COUNT(*) FROM student_faces
UNION ALL
SELECT 'lecturers', COUNT(*) FROM lecturers
UNION ALL
SELECT 'attendance_sessions', COUNT(*) FROM attendance_sessions
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'test', COUNT(*) FROM test;
