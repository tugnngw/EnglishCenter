-- =====================================================
-- DATABASE SCHEMA - English Learning Platform
-- Version: 8.0
-- Database: PostgreSQL
-- Total Tables: 42
-- =====================================================

-- =====================================================
-- PART 1: USER MANAGEMENT & RBAC (7 TABLES)
-- =====================================================

-- 1. USERS
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. ROLES
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- 3. USER_ROLES (Many-to-Many)
CREATE TABLE user_roles (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 4. PERMISSIONS
CREATE TABLE permissions (
    permission_id SERIAL PRIMARY KEY,
    permission_code VARCHAR(100) UNIQUE NOT NULL,
    description VARCHAR(255)
);

-- 5. ROLE_PERMISSIONS (Many-to-Many)
CREATE TABLE role_permissions (
    role_id INT NOT NULL,
    permission_id INT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id) ON DELETE CASCADE
);

-- 6. MENTOR_PROFILES
CREATE TABLE mentor_profiles (
    user_id INT PRIMARY KEY,
    created_by_user_id INT NOT NULL,
    biography TEXT,
    specialization VARCHAR(255),
    hourly_rate NUMERIC(12,2),
    rating_average NUMERIC(3,2) DEFAULT 0.00,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- 7. STUDENT_PROFILES
CREATE TABLE student_profiles (
    user_id INT PRIMARY KEY,
    target_certificate_id INT,
    target_score NUMERIC(6,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- =====================================================
-- PART 2: CERTIFICATE MANAGEMENT (3 TABLES)
-- =====================================================

-- 8. CERTIFICATE
CREATE TABLE certificate (
    certificate_id SERIAL PRIMARY KEY,
    created_by_user_id INT NOT NULL,
    certificate_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- 9. CERTIFICATE_PART
CREATE TABLE certificate_part (
    part_id SERIAL PRIMARY KEY,
    certificate_id INT NOT NULL,
    part_name VARCHAR(255) NOT NULL,
    part_description TEXT,
    part_order INT NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (certificate_id) REFERENCES certificate(certificate_id) ON DELETE CASCADE
);

-- 10. CERTIFICATE_PROPERTIES
CREATE TABLE certificate_properties (
    property_id SERIAL PRIMARY KEY,
    part_id INT NOT NULL,
    property_key VARCHAR(255) NOT NULL,
    property_value TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (part_id) REFERENCES certificate_part(part_id) ON DELETE CASCADE
);

-- Add FK for student_profiles after certificate table exists
ALTER TABLE student_profiles
ADD CONSTRAINT fk_student_target_certificate
FOREIGN KEY (target_certificate_id) REFERENCES certificate(certificate_id) ON DELETE SET NULL;

-- =====================================================
-- PART 3: COURSE MANAGEMENT (6 TABLES)
-- =====================================================

-- Create ENUM types for courses
CREATE TYPE course_status_enum AS ENUM ('draft', 'active', 'archived');
CREATE TYPE action_type_enum AS ENUM ('CREATE', 'UPDATE', 'ASSIGN_MENTOR', 'PUBLISH', 'ARCHIVE');

-- 11. COURSE
CREATE TABLE course (
    course_id SERIAL PRIMARY KEY,
    mentor_id INT,
    created_by_user_id INT NOT NULL,
    certificate_part_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    level VARCHAR(100),
    price NUMERIC(12,2),
    thumbnail_url VARCHAR(500),
    status course_status_enum DEFAULT 'draft',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mentor_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (certificate_part_id) REFERENCES certificate_part(part_id) ON DELETE SET NULL
);

-- 12. COURSE_AUDIT_LOG
CREATE TABLE course_audit_log (
    audit_id BIGSERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    action_type action_type_enum NOT NULL,
    performed_by INT NOT NULL,
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (performed_by) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- 13. LESSON
CREATE TABLE lesson (
    lesson_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    lesson_order INT NOT NULL,
    video_url VARCHAR(500),
    content TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE
);

-- 14. VOCABULARY
CREATE TABLE vocabulary (
    vocab_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    word VARCHAR(255) NOT NULL,
    translation VARCHAR(255),
    definition TEXT,
    pronunciation VARCHAR(255),
    example_sentence TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE
);

-- 15. HOMEWORK
CREATE TABLE homework (
    homework_id SERIAL PRIMARY KEY,
    lesson_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    deadline TIMESTAMP,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (lesson_id) REFERENCES lesson(lesson_id) ON DELETE CASCADE
);

-- 16. ANSWER_HOMEWORK
CREATE TABLE answer_homework (
    answer_id SERIAL PRIMARY KEY,
    homework_id INT NOT NULL,
    student_id INT NOT NULL,
    answer_content TEXT,
    file_url VARCHAR(500),
    score NUMERIC(6,2),
    feedback TEXT,
    submitted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    graded_date TIMESTAMP,
    FOREIGN KEY (homework_id) REFERENCES homework(homework_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- =====================================================
-- PART 4: EXAM SYSTEM (13 TABLES)
-- =====================================================

-- Create ENUM types for exams
CREATE TYPE question_type_enum AS ENUM ('multiple_choice', 'fill_blank', 'essay', 'matching', 'true_false');
CREATE TYPE difficulty_level_enum AS ENUM ('easy', 'medium', 'hard', 'real_test_level');
CREATE TYPE exam_status_enum AS ENUM ('draft', 'published', 'archived');
CREATE TYPE exam_type_enum AS ENUM ('quiz', 'midterm', 'final', 'placement_test');
CREATE TYPE attempt_status_enum AS ENUM ('in_progress', 'submitted', 'graded', 'expired');

-- 17. QUESTION_BANK
CREATE TABLE question_bank (
    question_id SERIAL PRIMARY KEY,
    created_by_user_id INT NOT NULL,
    certificate_part_id INT,
    question_type question_type_enum NOT NULL,
    question_text TEXT NOT NULL,
    difficulty_level difficulty_level_enum DEFAULT 'medium',
    topic VARCHAR(255),
    points NUMERIC(6,2) DEFAULT 1.00,
    usage_count INT DEFAULT 0,
    correct_rate NUMERIC(5,2) DEFAULT 0.00,
    last_used_date TIMESTAMP,
    explanation TEXT,
    audio_url VARCHAR(500),
    image_url VARCHAR(500),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (certificate_part_id) REFERENCES certificate_part(part_id) ON DELETE SET NULL
);

-- 18. QUESTION_BANK_OPTION
CREATE TABLE question_bank_option (
    option_id SERIAL PRIMARY KEY,
    question_id INT NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    option_order INT NOT NULL,
    explanation TEXT,
    FOREIGN KEY (question_id) REFERENCES question_bank(question_id) ON DELETE CASCADE
);

-- 19. TRIAL_EXAM
CREATE TABLE trial_exam (
    trial_exam_id SERIAL PRIMARY KEY,
    created_by_user_id INT NOT NULL,
    certificate_id INT NOT NULL,
    exam_code VARCHAR(50) UNIQUE NOT NULL,
    exam_title VARCHAR(255) NOT NULL,
    description TEXT,
    total_parts INT DEFAULT 0,
    total_questions INT DEFAULT 0,
    duration_minutes INT NOT NULL,
    is_free BOOLEAN DEFAULT TRUE,
    price NUMERIC(12,2) DEFAULT 0.00,
    difficulty_level difficulty_level_enum DEFAULT 'medium',
    recommended_level VARCHAR(100),
    status exam_status_enum DEFAULT 'draft',
    published_date TIMESTAMP,
    total_attempts INT DEFAULT 0,
    average_score NUMERIC(6,2) DEFAULT 0.00,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (certificate_id) REFERENCES certificate(certificate_id) ON DELETE CASCADE
);

-- 20. TRIAL_EXAM_SECTION
CREATE TABLE trial_exam_section (
    section_id SERIAL PRIMARY KEY,
    trial_exam_id INT NOT NULL,
    section_number INT NOT NULL,
    section_title VARCHAR(255) NOT NULL,
    instructions TEXT,
    audio_url VARCHAR(500),
    duration_minutes INT,
    FOREIGN KEY (trial_exam_id) REFERENCES trial_exam(trial_exam_id) ON DELETE CASCADE
);

-- 21. TRIAL_EXAM_QUESTION
CREATE TABLE trial_exam_question (
    id SERIAL PRIMARY KEY,
    trial_exam_id INT NOT NULL,
    section_id INT,
    question_bank_id INT NOT NULL,
    question_order INT NOT NULL,
    FOREIGN KEY (trial_exam_id) REFERENCES trial_exam(trial_exam_id) ON DELETE CASCADE,
    FOREIGN KEY (section_id) REFERENCES trial_exam_section(section_id) ON DELETE CASCADE,
    FOREIGN KEY (question_bank_id) REFERENCES question_bank(question_id) ON DELETE RESTRICT
);

-- 22. COURSE_EXAM
CREATE TABLE course_exam (
    exam_id SERIAL PRIMARY KEY,
    course_id INT NOT NULL,
    created_by_user_id INT NOT NULL,
    exam_type exam_type_enum DEFAULT 'quiz',
    exam_title VARCHAR(255) NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL,
    passing_score NUMERIC(6,2) DEFAULT 60.00,
    total_questions INT DEFAULT 0,
    available_from TIMESTAMP,
    available_until TIMESTAMP,
    max_attempts INT DEFAULT 1,
    show_answers BOOLEAN DEFAULT TRUE,
    show_score BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- 23. COURSE_EXAM_QUESTION
CREATE TABLE course_exam_question (
    id SERIAL PRIMARY KEY,
    exam_id INT NOT NULL,
    question_bank_id INT NOT NULL,
    question_order INT NOT NULL,
    FOREIGN KEY (exam_id) REFERENCES course_exam(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (question_bank_id) REFERENCES question_bank(question_id) ON DELETE RESTRICT
);

-- 24. TRIAL_EXAM_ATTEMPT
CREATE TABLE trial_exam_attempt (
    attempt_id SERIAL PRIMARY KEY,
    trial_exam_id INT NOT NULL,
    student_id INT NOT NULL,
    payment_transaction_id INT,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    score NUMERIC(6,2) DEFAULT 0.00,
    band_score NUMERIC(3,1),
    scaled_score INT,
    status attempt_status_enum DEFAULT 'in_progress',
    time_spent_seconds INT DEFAULT 0,
    correct_count INT DEFAULT 0,
    incorrect_count INT DEFAULT 0,
    unanswered_count INT DEFAULT 0,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trial_exam_id) REFERENCES trial_exam(trial_exam_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 25. TRIAL_EXAM_ATTEMPT_DETAIL
CREATE TABLE trial_exam_attempt_detail (
    detail_id SERIAL PRIMARY KEY,
    attempt_id INT NOT NULL,
    question_bank_id INT NOT NULL,
    selected_option_id INT,
    answer_text TEXT,
    is_correct BOOLEAN DEFAULT FALSE,
    time_spent_seconds INT DEFAULT 0,
    answered_date TIMESTAMP,
    FOREIGN KEY (attempt_id) REFERENCES trial_exam_attempt(attempt_id) ON DELETE CASCADE,
    FOREIGN KEY (question_bank_id) REFERENCES question_bank(question_id) ON DELETE RESTRICT,
    FOREIGN KEY (selected_option_id) REFERENCES question_bank_option(option_id) ON DELETE SET NULL
);

-- 26. COURSE_EXAM_ATTEMPT
CREATE TABLE course_exam_attempt (
    attempt_id SERIAL PRIMARY KEY,
    exam_id INT NOT NULL,
    student_id INT NOT NULL,
    attempt_number INT DEFAULT 1,
    start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP,
    score NUMERIC(6,2) DEFAULT 0.00,
    passed BOOLEAN DEFAULT FALSE,
    status attempt_status_enum DEFAULT 'in_progress',
    time_spent_seconds INT DEFAULT 0,
    correct_count INT DEFAULT 0,
    incorrect_count INT DEFAULT 0,
    unanswered_count INT DEFAULT 0,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (exam_id) REFERENCES course_exam(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 27. COURSE_EXAM_ATTEMPT_DETAIL
CREATE TABLE course_exam_attempt_detail (
    detail_id SERIAL PRIMARY KEY,
    attempt_id INT NOT NULL,
    question_bank_id INT NOT NULL,
    selected_option_id INT,
    answer_text TEXT,
    is_correct BOOLEAN DEFAULT FALSE,
    time_spent_seconds INT DEFAULT 0,
    answered_date TIMESTAMP,
    manual_score NUMERIC(6,2),
    mentor_feedback TEXT,
    graded_by INT,
    graded_date TIMESTAMP,
    FOREIGN KEY (attempt_id) REFERENCES course_exam_attempt(attempt_id) ON DELETE CASCADE,
    FOREIGN KEY (question_bank_id) REFERENCES question_bank(question_id) ON DELETE RESTRICT,
    FOREIGN KEY (selected_option_id) REFERENCES question_bank_option(option_id) ON DELETE SET NULL,
    FOREIGN KEY (graded_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- =====================================================
-- PART 5: PAYMENT SYSTEM (4 TABLES)
-- =====================================================

-- Create ENUM types for payments
CREATE TYPE transaction_type_enum AS ENUM ('course_purchase', 'mentor_session', 'trial_exam_access');
CREATE TYPE transaction_status_enum AS ENUM ('pending', 'success', 'failed');
CREATE TYPE email_status_enum AS ENUM ('pending', 'sent', 'failed');
CREATE TYPE code_type_enum AS ENUM ('course_purchase', 'mentor_session', 'trial_exam_access');
CREATE TYPE enrollment_status_enum AS ENUM ('active', 'expired', 'cancelled');
CREATE TYPE payment_action_enum AS ENUM ('CREATE', 'UPDATE_ATTEMPT', 'DELETE_ATTEMPT');

-- 28. PAYMENT_TRANSACTION
CREATE TABLE payment_transaction (
    transaction_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    transaction_type transaction_type_enum NOT NULL,
    course_id INT,
    mentor_schedule_id INT,
    trial_exam_id INT,
    amount NUMERIC(12,2) NOT NULL,
    payment_method VARCHAR(50),
    transaction_status transaction_status_enum DEFAULT 'pending',
    payment_date TIMESTAMP,
    confirmation_code_sent BOOLEAN DEFAULT FALSE,
    confirmation_code_sent_at TIMESTAMP,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE RESTRICT,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE SET NULL,
    FOREIGN KEY (trial_exam_id) REFERENCES trial_exam(trial_exam_id) ON DELETE SET NULL
);

-- 29. ORDER_CONFIRMATION_CODE
CREATE TABLE order_confirmation_code (
    code_id SERIAL PRIMARY KEY,
    transaction_id INT UNIQUE NOT NULL,
    confirmation_code VARCHAR(50) UNIQUE NOT NULL,
    recipient_email VARCHAR(255) NOT NULL,
    email_status email_status_enum DEFAULT 'pending',
    sent_at TIMESTAMP,
    code_type code_type_enum NOT NULL,
    order_details JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES payment_transaction(transaction_id) ON DELETE CASCADE
);

-- 30. PAYMENT_TRANSACTION_AUDIT
CREATE TABLE payment_transaction_audit (
    audit_id BIGSERIAL PRIMARY KEY,
    transaction_id INT NOT NULL,
    action_type payment_action_enum NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    old_amount NUMERIC(12,2),
    new_amount NUMERIC(12,2),
    attempted_by INT,
    attempt_reason TEXT,
    blocked BOOLEAN DEFAULT FALSE,
    error_message TEXT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES payment_transaction(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (attempted_by) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 31. ENROLLMENT
CREATE TABLE enrollment (
    enrollment_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    payment_transaction_id INT,
    enrolled_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status enrollment_status_enum DEFAULT 'active',
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE,
    FOREIGN KEY (payment_transaction_id) REFERENCES payment_transaction(transaction_id) ON DELETE SET NULL
);

-- Add FK for trial_exam_attempt after payment_transaction exists
ALTER TABLE trial_exam_attempt
ADD CONSTRAINT fk_trial_attempt_payment
FOREIGN KEY (payment_transaction_id) REFERENCES payment_transaction(transaction_id) ON DELETE SET NULL;

-- =====================================================
-- PART 6: MENTOR SCHEDULE (1 TABLE)
-- =====================================================

-- Create ENUM type for schedule
CREATE TYPE schedule_status_enum AS ENUM ('available', 'booked', 'completed', 'cancelled');

-- 32. MENTOR_SCHEDULE
CREATE TABLE mentor_schedule (
    schedule_id SERIAL PRIMARY KEY,
    mentor_id INT NOT NULL,
    student_id INT,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    status schedule_status_enum DEFAULT 'available',
    price NUMERIC(12,2),
    meeting_url VARCHAR(500),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mentor_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- Add FK for payment_transaction after mentor_schedule exists
ALTER TABLE payment_transaction
ADD CONSTRAINT fk_payment_mentor_schedule
FOREIGN KEY (mentor_schedule_id) REFERENCES mentor_schedule(schedule_id) ON DELETE SET NULL;

-- =====================================================
-- PART 7: LEARNING PATH (4 TABLES)
-- =====================================================

-- Create ENUM types for learning path
CREATE TYPE path_status_enum AS ENUM ('active', 'completed', 'abandoned');
CREATE TYPE path_item_status_enum AS ENUM ('not_started', 'in_progress', 'completed');

-- 33. LEARNING_PATH
CREATE TABLE learning_path (
    learning_path_id SERIAL PRIMARY KEY,
    certificate_id INT NOT NULL,
    created_by_user_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (certificate_id) REFERENCES certificate(certificate_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- 34. LEARNING_PATH_ITEM
CREATE TABLE learning_path_item (
    path_item_id SERIAL PRIMARY KEY,
    learning_path_id INT NOT NULL,
    course_id INT NOT NULL,
    item_order INT NOT NULL,
    recommended_days INT,
    FOREIGN KEY (learning_path_id) REFERENCES learning_path(learning_path_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE CASCADE
);

-- 35. STUDENT_LEARNING_PATH
CREATE TABLE student_learning_path (
    student_path_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    learning_path_id INT NOT NULL,
    started_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    target_completion_date DATE,
    status path_status_enum DEFAULT 'active',
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (learning_path_id) REFERENCES learning_path(learning_path_id) ON DELETE CASCADE
);

-- 36. STUDENT_PATH_PROGRESS
CREATE TABLE student_path_progress (
    progress_id SERIAL PRIMARY KEY,
    student_path_id INT NOT NULL,
    path_item_id INT NOT NULL,
    status path_item_status_enum DEFAULT 'not_started',
    completed_date TIMESTAMP,
    FOREIGN KEY (student_path_id) REFERENCES student_learning_path(student_path_id) ON DELETE CASCADE,
    FOREIGN KEY (path_item_id) REFERENCES learning_path_item(path_item_id) ON DELETE CASCADE
);

-- =====================================================
-- PART 8: SCHEDULE & NOTIFICATION (2 TABLES)
-- =====================================================

-- Create ENUM types for schedule and notification
CREATE TYPE repeat_rule_enum AS ENUM ('none', 'daily', 'weekly');
CREATE TYPE study_status_enum AS ENUM ('pending', 'done', 'skipped', 'cancelled');
CREATE TYPE notification_type_enum AS ENUM ('study_reminder', 'homework_deadline', 'payment', 'exam_result', 'general');

-- 37. STUDY_SCHEDULE
CREATE TABLE study_schedule (
    schedule_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL,
    lesson_id INT,
    title VARCHAR(255) NOT NULL,
    scheduled_time TIMESTAMP NOT NULL,
    repeat_rule repeat_rule_enum DEFAULT 'none',
    reminder_minutes_before INT DEFAULT 15,
    status study_status_enum DEFAULT 'pending',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (lesson_id) REFERENCES lesson(lesson_id) ON DELETE SET NULL
);

-- 38. NOTIFICATION
CREATE TABLE notification (
    notification_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    type notification_type_enum NOT NULL,
    related_schedule_id INT,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    recipient_email VARCHAR(255) NOT NULL,
    email_status email_status_enum DEFAULT 'pending',
    scheduled_at TIMESTAMP,
    sent_at TIMESTAMP,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (related_schedule_id) REFERENCES study_schedule(schedule_id) ON DELETE SET NULL
);

-- =====================================================
-- PART 9: PRACTICE EXAM - AI EVALUATION (3 TABLES)
-- =====================================================

-- 39. PRACTICE_EXAM_BANK
CREATE TABLE practice_exam_bank (
    bank_id SERIAL PRIMARY KEY,
    created_by_user_id INT NOT NULL,
    bank_name VARCHAR(255) NOT NULL,
    description TEXT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id) ON DELETE RESTRICT
);

-- 40. PRACTICE_EXAM
CREATE TABLE practice_exam (
    practice_exam_id SERIAL PRIMARY KEY,
    course_id INT,
    practice_exam_bank_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    exam_type VARCHAR(50) NOT NULL,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES course(course_id) ON DELETE SET NULL,
    FOREIGN KEY (practice_exam_bank_id) REFERENCES practice_exam_bank(bank_id) ON DELETE CASCADE
);

-- 41. PRACTICE_EXAM_ANSWER
CREATE TABLE practice_exam_answer (
    answer_id SERIAL PRIMARY KEY,
    practice_exam_id INT NOT NULL,
    student_id INT NOT NULL,
    answer_content TEXT,
    file_url VARCHAR(500),
    submitted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (practice_exam_id) REFERENCES practice_exam(practice_exam_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 42. AI_EVALUATION
CREATE TABLE ai_evaluation (
    evaluation_id SERIAL PRIMARY KEY,
    practice_exam_answer_id INT UNIQUE NOT NULL,
    score NUMERIC(6,2),
    feedback TEXT,
    evaluated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (practice_exam_answer_id) REFERENCES practice_exam_answer(answer_id) ON DELETE CASCADE
);

-- =====================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- =====================================================

-- User indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_active ON users(is_active);

-- Course indexes
CREATE INDEX idx_course_status ON course(status);
CREATE INDEX idx_course_mentor_status ON course(mentor_id, status);
CREATE INDEX idx_course_certificate_part ON course(certificate_part_id);

-- Lesson indexes
CREATE INDEX idx_lesson_course ON lesson(course_id);
CREATE INDEX idx_lesson_order ON lesson(course_id, lesson_order);

-- Question bank indexes
CREATE INDEX idx_question_bank_type ON question_bank(question_type);
CREATE INDEX idx_question_bank_difficulty ON question_bank(difficulty_level);
CREATE INDEX idx_question_bank_certificate_part ON question_bank(certificate_part_id);
CREATE INDEX idx_question_bank_usage ON question_bank(usage_count DESC);

-- Trial exam indexes
CREATE INDEX idx_trial_exam_status ON trial_exam(status);
CREATE INDEX idx_trial_exam_certificate ON trial_exam(certificate_id);
CREATE INDEX idx_trial_exam_code ON trial_exam(exam_code);

-- Attempt indexes
CREATE INDEX idx_trial_attempt_student ON trial_exam_attempt(student_id);
CREATE INDEX idx_trial_attempt_exam ON trial_exam_attempt(trial_exam_id);
CREATE INDEX idx_course_attempt_student ON course_exam_attempt(student_id);
CREATE INDEX idx_course_attempt_exam ON course_exam_attempt(exam_id);

-- Payment indexes
CREATE INDEX idx_payment_student ON payment_transaction(student_id);
CREATE INDEX idx_payment_status ON payment_transaction(transaction_status);
CREATE INDEX idx_payment_date ON payment_transaction(payment_date);
CREATE INDEX idx_payment_type ON payment_transaction(transaction_type);

-- Enrollment indexes
CREATE INDEX idx_enrollment_student ON enrollment(student_id);
CREATE INDEX idx_enrollment_course ON enrollment(course_id);
CREATE INDEX idx_enrollment_student_status ON enrollment(student_id, status);

-- Mentor schedule indexes
CREATE INDEX idx_mentor_schedule_mentor ON mentor_schedule(mentor_id);
CREATE INDEX idx_mentor_schedule_status ON mentor_schedule(status);
CREATE INDEX idx_mentor_schedule_time ON mentor_schedule(start_time, end_time);

-- Notification indexes
CREATE INDEX idx_notification_user ON notification(user_id);
CREATE INDEX idx_notification_status ON notification(email_status);
CREATE INDEX idx_notification_scheduled ON notification(scheduled_at);

-- Study schedule indexes
CREATE INDEX idx_study_schedule_student ON study_schedule(student_id);
CREATE INDEX idx_study_schedule_time ON study_schedule(scheduled_time);

-- Homework indexes
CREATE INDEX idx_homework_lesson ON homework(lesson_id);
CREATE INDEX idx_answer_homework_student ON answer_homework(student_id);
CREATE INDEX idx_answer_homework_homework ON answer_homework(homework_id);

-- Full-text search indexes
CREATE INDEX idx_question_text_fulltext ON question_bank USING gin(to_tsvector('english', question_text));
CREATE INDEX idx_vocabulary_word ON vocabulary(word);

-- =====================================================
-- TRIGGERS
-- =====================================================

-- Trigger 1: Prevent non-admin from assigning mentor role
CREATE OR REPLACE FUNCTION fn_check_mentor_role_assignment()
RETURNS TRIGGER AS $$
DECLARE
    v_assigned_by_role VARCHAR(50);
BEGIN
    -- Check if assigning mentor role
    IF (SELECT role_name FROM roles WHERE role_id = NEW.role_id) = 'mentor' THEN
        -- Check if assigned_by is admin
        SELECT r.role_name INTO v_assigned_by_role
        FROM user_roles ur
        JOIN roles r ON ur.role_id = r.role_id
        WHERE ur.user_id = NEW.assigned_by AND r.role_name = 'admin'
        LIMIT 1;

        IF v_assigned_by_role IS NULL THEN
            RAISE EXCEPTION 'Only admins can assign mentor role';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_roles_mentor_admin_only
BEFORE INSERT ON user_roles
FOR EACH ROW
EXECUTE FUNCTION fn_check_mentor_role_assignment();

-- Trigger 2: Prevent non-admin from creating mentor profiles
CREATE OR REPLACE FUNCTION fn_check_mentor_profile_creator()
RETURNS TRIGGER AS $$
DECLARE
    v_creator_role VARCHAR(50);
BEGIN
    -- Check if creator is admin
    SELECT r.role_name INTO v_creator_role
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.role_id
    WHERE ur.user_id = NEW.created_by_user_id AND r.role_name = 'admin'
    LIMIT 1;

    IF v_creator_role IS NULL THEN
        RAISE EXCEPTION 'Only admins can create mentor profiles';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mentor_profiles_admin_only
BEFORE INSERT ON mentor_profiles
FOR EACH ROW
EXECUTE FUNCTION fn_check_mentor_profile_creator();

-- Trigger 3: Prevent non-admin from creating courses
CREATE OR REPLACE FUNCTION fn_check_course_creator()
RETURNS TRIGGER AS $$
DECLARE
    v_creator_role VARCHAR(50);
BEGIN
    -- Check if creator is admin
    SELECT r.role_name INTO v_creator_role
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.role_id
    WHERE ur.user_id = NEW.created_by_user_id AND r.role_name = 'admin'
    LIMIT 1;

    IF v_creator_role IS NULL THEN
        RAISE EXCEPTION 'Only admins can create courses';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_course_admin_only
BEFORE INSERT ON course
FOR EACH ROW
EXECUTE FUNCTION fn_check_course_creator();

-- Trigger 4: Prevent non-admin from creating trial exams
CREATE OR REPLACE FUNCTION fn_check_trial_exam_creator()
RETURNS TRIGGER AS $$
DECLARE
    v_creator_role VARCHAR(50);
BEGIN
    -- Check if creator is admin
    SELECT r.role_name INTO v_creator_role
    FROM user_roles ur
    JOIN roles r ON ur.role_id = r.role_id
    WHERE ur.user_id = NEW.created_by_user_id AND r.role_name = 'admin'
    LIMIT 1;

    IF v_creator_role IS NULL THEN
        RAISE EXCEPTION 'Only admins can create trial exams';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_trial_exam_admin_only
BEFORE INSERT ON trial_exam
FOR EACH ROW
EXECUTE FUNCTION fn_check_trial_exam_creator();

-- Trigger 5: Prevent payment rollback
CREATE OR REPLACE FUNCTION fn_prevent_payment_rollback()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.transaction_status = 'success' AND NEW.transaction_status != 'success' THEN
        -- Log the blocked attempt
        INSERT INTO payment_transaction_audit (
            transaction_id, action_type, old_status, new_status,
            old_amount, new_amount, blocked, error_message
        ) VALUES (
            OLD.transaction_id, 'UPDATE_ATTEMPT', OLD.transaction_status::VARCHAR, NEW.transaction_status::VARCHAR,
            OLD.amount, NEW.amount, TRUE, 'Rollback blocked: Cannot change status from success'
        );

        RAISE EXCEPTION 'Cannot rollback successful payment transaction';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_payment_rollback
BEFORE UPDATE ON payment_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_payment_rollback();

-- Trigger 6: Prevent deleting successful payments
CREATE OR REPLACE FUNCTION fn_prevent_payment_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.transaction_status = 'success' THEN
        -- Log the blocked attempt
        INSERT INTO payment_transaction_audit (
            transaction_id, action_type, old_status, blocked, error_message
        ) VALUES (
            OLD.transaction_id, 'DELETE_ATTEMPT', OLD.transaction_status::VARCHAR,
            TRUE, 'Delete blocked: Cannot delete successful payment'
        );

        RAISE EXCEPTION 'Cannot delete successful payment transaction';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_payment_delete
BEFORE DELETE ON payment_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_payment_delete();

-- Trigger 7: Auto-create confirmation code on payment success
CREATE OR REPLACE FUNCTION fn_create_confirmation_code()
RETURNS TRIGGER AS $$
DECLARE
    v_code VARCHAR(50);
BEGIN
    IF NEW.transaction_status = 'success' AND OLD.transaction_status != 'success' THEN
        -- Generate confirmation code: CC-YYYYMMDD-NNNNNN-RANDOM
        v_code := 'CC-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' ||
                  LPAD(NEW.transaction_id::TEXT, 6, '0') || '-' ||
                  UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 6));

        -- Insert confirmation code
        INSERT INTO order_confirmation_code (
            transaction_id, confirmation_code, recipient_email, code_type, order_details
        ) VALUES (
            NEW.transaction_id, v_code,
            (SELECT email FROM users WHERE user_id = NEW.student_id),
            NEW.transaction_type::code_type_enum,
            jsonb_build_object(
                'transaction_id', NEW.transaction_id,
                'amount', NEW.amount,
                'payment_date', NEW.payment_date
            )
        );

        -- Update transaction
        NEW.confirmation_code_sent := TRUE;
        NEW.confirmation_code_sent_at := CURRENT_TIMESTAMP;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_create_confirmation_code
BEFORE UPDATE ON payment_transaction
FOR EACH ROW
EXECUTE FUNCTION fn_create_confirmation_code();

-- Trigger 8: Track question usage when added to trial exam
CREATE OR REPLACE FUNCTION fn_track_question_usage_trial()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE question_bank
    SET usage_count = usage_count + 1,
        last_used_date = CURRENT_TIMESTAMP
    WHERE question_id = NEW.question_bank_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_question_usage_trial
AFTER INSERT ON trial_exam_question
FOR EACH ROW
EXECUTE FUNCTION fn_track_question_usage_trial();

-- Trigger 9: Course audit log on insert
CREATE OR REPLACE FUNCTION fn_course_audit_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO course_audit_log (
        course_id, action_type, performed_by, new_value
    ) VALUES (
        NEW.course_id, 'CREATE', NEW.created_by_user_id,
        jsonb_build_object(
            'title', NEW.title,
            'status', NEW.status,
            'price', NEW.price
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_course_audit_insert
AFTER INSERT ON course
FOR EACH ROW
EXECUTE FUNCTION fn_course_audit_insert();

-- =====================================================
-- STORED PROCEDURES
-- =====================================================

-- Procedure 1: Check mentor course permission
CREATE OR REPLACE FUNCTION sp_check_mentor_course_permission(
    p_mentor_id INT,
    p_course_id INT
)
RETURNS BOOLEAN AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1
        FROM course
        WHERE course_id = p_course_id AND mentor_id = p_mentor_id
    ) INTO v_has_permission;

    RETURN v_has_permission;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- VIEWS
-- =====================================================

-- View 1: Available courses
CREATE OR REPLACE VIEW v_available_courses AS
SELECT
    c.course_id,
    c.title,
    c.description,
    c.level,
    c.price,
    c.thumbnail_url,
    u.full_name AS mentor_name,
    cp.part_name AS certificate_part,
    cert.certificate_name
FROM course c
LEFT JOIN users u ON c.mentor_id = u.user_id
LEFT JOIN certificate_part cp ON c.certificate_part_id = cp.part_id
LEFT JOIN certificate cert ON cp.certificate_id = cert.certificate_id
WHERE c.status = 'active';

-- View 2: Available trial exams
CREATE OR REPLACE VIEW v_available_trial_exams AS
SELECT
    te.trial_exam_id,
    te.exam_code,
    te.exam_title,
    te.description,
    te.duration_minutes,
    te.is_free,
    te.price,
    te.difficulty_level,
    te.total_questions,
    te.average_score,
    c.certificate_name
FROM trial_exam te
JOIN certificate c ON te.certificate_id = c.certificate_id
WHERE te.status = 'published';

-- View 3: Locked payments (cannot be rolled back)
CREATE OR REPLACE VIEW v_locked_payments AS
SELECT
    pt.transaction_id,
    pt.student_id,
    u.email AS student_email,
    pt.transaction_type,
    pt.amount,
    pt.payment_date,
    occ.confirmation_code
FROM payment_transaction pt
JOIN users u ON pt.student_id = u.user_id
LEFT JOIN order_confirmation_code occ ON pt.transaction_id = occ.transaction_id
WHERE pt.transaction_status = 'success';

-- =====================================================
-- SEED DATA
-- =====================================================

-- Seed roles
INSERT INTO roles (role_name, description) VALUES
('admin', 'System administrator with full access'),
('mentor', 'Instructor who creates and manages course content'),
('student', 'Learner who enrolls in courses and takes exams');

-- Seed permissions
INSERT INTO permissions (permission_code, description) VALUES
('user.manage', 'Manage users'),
('role.assign', 'Assign roles to users'),
('course.create', 'Create courses'),
('course.edit', 'Edit course details'),
('course.delete', 'Delete courses'),
('lesson.create', 'Create lessons'),
('lesson.edit', 'Edit lessons'),
('homework.create', 'Create homework'),
('homework.grade', 'Grade homework'),
('exam.create', 'Create exams'),
('exam.manage', 'Manage exams'),
('exam.grade', 'Grade exams'),
('question.create', 'Create questions'),
('question.edit', 'Edit questions'),
('trial_exam.create', 'Create trial exams'),
('payment.view', 'View payment transactions'),
('payment.refund', 'Process refunds'),
('certificate.manage', 'Manage certificates'),
('mentor.manage', 'Manage mentors'),
('analytics.view', 'View analytics');

-- Assign permissions to admin role
INSERT INTO role_permissions (role_id, permission_id)
SELECT
    (SELECT role_id FROM roles WHERE role_name = 'admin'),
    permission_id
FROM permissions;

-- Assign permissions to mentor role
INSERT INTO role_permissions (role_id, permission_id)
SELECT
    (SELECT role_id FROM roles WHERE role_name = 'mentor'),
    permission_id
FROM permissions
WHERE permission_code IN (
    'lesson.create', 'lesson.edit',
    'homework.create', 'homework.grade',
    'exam.create', 'exam.grade',
    'question.create', 'question.edit'
);

-- =====================================================
-- END OF MIGRATION
-- =====================================================

-- Comments for documentation
COMMENT ON DATABASE postgres IS 'English Learning Platform Database';
COMMENT ON TABLE users IS 'Core user table for authentication and basic profile';
COMMENT ON TABLE roles IS 'System roles (admin, mentor, student)';
COMMENT ON TABLE permissions IS 'Granular permissions for RBAC';
COMMENT ON TABLE payment_transaction IS 'Payment transactions - protected from rollback when status=success';
COMMENT ON TABLE question_bank IS 'Shared question bank for all exams';
COMMENT ON TABLE trial_exam IS 'Official trial exams (admin-created only)';
COMMENT ON TABLE course_exam IS 'Course-specific exams (mentor-created)';
