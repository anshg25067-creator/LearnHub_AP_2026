
-- ============================================================
-- LEARNHUB - AP APPLICATION SQL QUERIES
-- PostgreSQL
-- Initial query collection for CP3
-- ============================================================
-- READ  : R1, R2, R3...
-- WRITE : W1, W2, W3...
-- Parameters are represented using $1, $2, $3...
-- ============================================================


-- ============================================================
-- 1. USERS / AUTHENTICATION / PROFILE
-- ============================================================

-- READ
-- R1: Fetch user by email

SELECT user_id, full_name, email, role, is_active, created_at
FROM users
WHERE email = $1;


-- READ
-- R2: Fetch user by user ID

SELECT user_id, full_name, email, role, bio, is_active, created_at
FROM users
WHERE user_id = $1;


-- READ
-- R3: Fetch all active users

SELECT user_id, full_name, email, role, created_at
FROM users
WHERE is_active = TRUE
ORDER BY created_at DESC;


-- READ
-- R4: Fetch all users of a particular role

SELECT user_id, full_name, email, role, created_at
FROM users
WHERE role = $1
ORDER BY created_at DESC;


-- READ
-- R5: Fetch all teachers

SELECT user_id, full_name, email, bio, created_at
FROM users
WHERE role = 'teacher'
  AND is_active = TRUE
ORDER BY full_name;


-- READ
-- R6: Fetch all students

SELECT user_id, full_name, email, created_at
FROM users
WHERE role = 'student'
  AND is_active = TRUE
ORDER BY full_name;


-- READ
-- R7: Fetch user profile

SELECT user_id, full_name, email, role, bio, created_at
FROM users
WHERE user_id = $1;


-- READ
-- R8: Search users by name

SELECT user_id, full_name, email, role
FROM users
WHERE full_name ILIKE '%' || $1 || '%'
ORDER BY full_name;


-- WRITE
-- W1: Register a new user

INSERT INTO users (full_name, email, password_hash, role)
VALUES ($1, $2, $3, $4)
RETURNING user_id, full_name, email, role, created_at;


-- WRITE
-- W2: Update user profile

UPDATE users
SET full_name = $2,
    bio = $3,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = $1
RETURNING user_id, full_name, bio, updated_at;


-- WRITE
-- W3: Update user email

UPDATE users
SET email = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = $1
RETURNING user_id, email;


-- WRITE
-- W4: Activate or deactivate a user

UPDATE users
SET is_active = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = $1
RETURNING user_id, is_active;


-- WRITE
-- W5: Update user role

UPDATE users
SET role = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE user_id = $1
RETURNING user_id, role;


-- ============================================================
-- 2. COURSES
-- ============================================================

-- READ
-- R9: Fetch all published courses

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    c.course_status,
    c.created_at,
    u.user_id AS teacher_id,
    u.full_name AS teacher_name
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
WHERE c.course_status = 'published'
  AND u.is_active = TRUE
ORDER BY c.created_at DESC;


-- READ
-- R10: Fetch course details by course ID

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    c.course_status,
    c.created_at,
    u.user_id AS teacher_id,
    u.full_name AS teacher_name,
    u.bio AS teacher_bio
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
WHERE c.course_id = $1;


-- READ
-- R11: Fetch all courses created by a particular teacher

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    c.course_status,
    c.created_at
FROM courses c
WHERE c.teacher_id = $1
ORDER BY c.created_at DESC;


-- READ
-- R12: Search courses by title

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    u.full_name AS teacher_name
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
WHERE c.course_status = 'published'
  AND c.title ILIKE '%' || $1 || '%'
ORDER BY c.title;


-- READ
-- R13: Fetch courses by status

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    c.course_status,
    u.full_name AS teacher_name
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
WHERE c.course_status = $1
ORDER BY c.created_at DESC;


-- READ
-- R14: Fetch courses within a price range

SELECT
    c.course_id,
    c.title,
    c.price,
    u.full_name AS teacher_name
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
WHERE c.course_status = 'published'
  AND c.price BETWEEN $1 AND $2
ORDER BY c.price ASC;


-- READ
-- R15: Fetch latest courses

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    c.created_at,
    u.full_name AS teacher_name
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
WHERE c.course_status = 'published'
ORDER BY c.created_at DESC
LIMIT $1;


-- READ
-- R16: Fetch course with total lesson count

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    u.full_name AS teacher_name,
    COUNT(l.lesson_id) AS total_lessons
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
LEFT JOIN lessons l
    ON c.course_id = l.course_id
WHERE c.course_id = $1
GROUP BY c.course_id, u.user_id;


-- READ
-- R17: Fetch course enrollment count

SELECT
    c.course_id,
    c.title,
    COUNT(e.enrollment_id) AS total_enrollments
FROM courses c
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
WHERE c.course_id = $1
GROUP BY c.course_id;


-- READ
-- R18: Fetch teacher courses with enrollment counts

SELECT
    c.course_id,
    c.title,
    c.course_status,
    COUNT(e.enrollment_id) AS total_enrollments
FROM courses c
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
WHERE c.teacher_id = $1
GROUP BY c.course_id
ORDER BY c.created_at DESC;


-- WRITE
-- W6: Create a new course

INSERT INTO courses
    (teacher_id, title, description, price, course_status)
VALUES
    ($1, $2, $3, $4, $5)
RETURNING course_id, title, price, course_status, created_at;


-- WRITE
-- W7: Update course details

UPDATE courses
SET title = $2,
    description = $3,
    price = $4,
    updated_at = CURRENT_TIMESTAMP
WHERE course_id = $1
RETURNING course_id, title, description, price, updated_at;


-- WRITE
-- W8: Update course status

UPDATE courses
SET course_status = $2,
    updated_at = CURRENT_TIMESTAMP
WHERE course_id = $1
RETURNING course_id, course_status;


-- WRITE
-- W9: Delete a course

DELETE FROM courses
WHERE course_id = $1
RETURNING course_id;


-- ============================================================
-- 3. LESSONS
-- ============================================================

-- READ
-- R19: Fetch all lessons of a course in order

SELECT
    lesson_id,
    course_id,
    title,
    description,
    content_url,
    duration_seconds,
    lesson_order
FROM lessons
WHERE course_id = $1
ORDER BY lesson_order ASC;


-- READ
-- R20: Fetch lesson details

SELECT
    l.lesson_id,
    l.course_id,
    l.title,
    l.description,
    l.content_url,
    l.duration_seconds,
    l.lesson_order,
    c.title AS course_title
FROM lessons l
JOIN courses c
    ON l.course_id = c.course_id
WHERE l.lesson_id = $1;


-- READ
-- R21: Fetch a particular lesson of a course

SELECT
    lesson_id,
    course_id,
    title,
    description,
    content_url,
    duration_seconds,
    lesson_order
FROM lessons
WHERE course_id = $1
  AND lesson_order = $2;


-- READ
-- R22: Fetch total number of lessons in a course

SELECT
    course_id,
    COUNT(*) AS total_lessons
FROM lessons
WHERE course_id = $1
GROUP BY course_id;


-- READ
-- R23: Fetch total course duration

SELECT
    course_id,
    SUM(duration_seconds) AS total_duration_seconds,
    ROUND(SUM(duration_seconds) / 60.0, 2) AS total_duration_minutes
FROM lessons
WHERE course_id = $1
GROUP BY course_id;


-- READ
-- R24: Fetch lessons with course information

SELECT
    l.lesson_id,
    l.title AS lesson_title,
    l.lesson_order,
    l.duration_seconds,
    c.course_id,
    c.title AS course_title
FROM lessons l
JOIN courses c
    ON l.course_id = c.course_id
WHERE c.course_id = $1
ORDER BY l.lesson_order;


-- WRITE
-- W10: Create a new lesson

INSERT INTO lessons
    (course_id, title, description, content_url,
     duration_seconds, lesson_order)
VALUES
    ($1, $2, $3, $4, $5, $6)
RETURNING lesson_id, course_id, title, lesson_order;


-- WRITE
-- W11: Update lesson details

UPDATE lessons
SET title = $2,
    description = $3,
    content_url = $4,
    duration_seconds = $5
WHERE lesson_id = $1
RETURNING lesson_id, title, description, content_url, duration_seconds;


-- WRITE
-- W12: Update lesson order

UPDATE lessons
SET lesson_order = $2
WHERE lesson_id = $1
RETURNING lesson_id, course_id, lesson_order;


-- WRITE
-- W13: Delete a lesson

DELETE FROM lessons
WHERE lesson_id = $1
RETURNING lesson_id, course_id;


-- ============================================================
-- 4. ENROLLMENTS
-- ============================================================

-- READ
-- R25: Fetch all enrollments of a student

SELECT
    e.enrollment_id,
    e.student_id,
    e.course_id,
    e.enrolled_at,
    e.enrollment_status,
    c.title AS course_title,
    c.price,
    u.full_name AS teacher_name
FROM enrollments e
JOIN courses c
    ON e.course_id = c.course_id
JOIN users u
    ON c.teacher_id = u.user_id
WHERE e.student_id = $1
ORDER BY e.enrolled_at DESC;


-- READ
-- R26: Fetch enrollment details by enrollment ID

SELECT
    e.enrollment_id,
    e.student_id,
    e.course_id,
    e.enrolled_at,
    e.enrollment_status,
    u.full_name AS student_name,
    c.title AS course_title
FROM enrollments e
JOIN users u
    ON e.student_id = u.user_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE e.enrollment_id = $1;


-- READ
-- R27: Check if student is enrolled in a course

SELECT enrollment_id, enrollment_status, enrolled_at
FROM enrollments
WHERE student_id = $1
  AND course_id = $2;


-- READ
-- R28: Fetch all students enrolled in a course

SELECT
    e.enrollment_id,
    e.enrolled_at,
    e.enrollment_status,
    u.user_id AS student_id,
    u.full_name,
    u.email
FROM enrollments e
JOIN users u
    ON e.student_id = u.user_id
WHERE e.course_id = $1
ORDER BY e.enrolled_at DESC;


-- READ
-- R29: Fetch enrollments of courses taught by a teacher

SELECT
    e.enrollment_id,
    e.enrolled_at,
    e.enrollment_status,
    c.course_id,
    c.title AS course_title,
    u.user_id AS student_id,
    u.full_name AS student_name
FROM enrollments e
JOIN courses c
    ON e.course_id = c.course_id
JOIN users u
    ON e.student_id = u.user_id
WHERE c.teacher_id = $1
ORDER BY e.enrolled_at DESC;


-- READ
-- R30: Count students enrolled in each course of a teacher

SELECT
    c.course_id,
    c.title,
    COUNT(e.enrollment_id) AS student_count
FROM courses c
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
WHERE c.teacher_id = $1
GROUP BY c.course_id
ORDER BY student_count DESC;


-- READ
-- R31: Fetch enrollment statistics by status

SELECT
    enrollment_status,
    COUNT(*) AS total_enrollments
FROM enrollments
GROUP BY enrollment_status
ORDER BY total_enrollments DESC;


-- WRITE
-- W14: Enroll a student in a course

INSERT INTO enrollments
    (student_id, course_id)
VALUES
    ($1, $2)
RETURNING enrollment_id, student_id, course_id, enrolled_at, enrollment_status;


-- WRITE
-- W15: Update enrollment status

UPDATE enrollments
SET enrollment_status = $2
WHERE enrollment_id = $1
RETURNING enrollment_id, enrollment_status;


-- WRITE
-- W16: Cancel an enrollment

UPDATE enrollments
SET enrollment_status = 'cancelled'
WHERE enrollment_id = $1
RETURNING enrollment_id, enrollment_status;


-- WRITE
-- W17: Mark enrollment as completed

UPDATE enrollments
SET enrollment_status = 'completed'
WHERE enrollment_id = $1
RETURNING enrollment_id, enrollment_status;


-- WRITE
-- W18: Delete enrollment

DELETE FROM enrollments
WHERE enrollment_id = $1
RETURNING enrollment_id;


-- ============================================================
-- 5. PAYMENTS
-- ============================================================

-- READ
-- R32: Fetch payment details by payment ID

SELECT
    p.payment_id,
    p.enrollment_id,
    p.amount,
    p.currency,
    p.payment_method,
    p.transaction_reference,
    p.payment_status,
    p.paid_at,
    p.created_at
FROM payments p
WHERE p.payment_id = $1;


-- READ
-- R33: Fetch all payments of an enrollment

SELECT
    payment_id,
    enrollment_id,
    amount,
    currency,
    payment_method,
    transaction_reference,
    payment_status,
    paid_at,
    created_at
FROM payments
WHERE enrollment_id = $1
ORDER BY created_at DESC;


-- READ
-- R34: Fetch payments made by a student

SELECT
    p.payment_id,
    p.amount,
    p.currency,
    p.payment_method,
    p.transaction_reference,
    p.payment_status,
    p.paid_at,
    e.enrollment_id,
    c.course_id,
    c.title AS course_title
FROM payments p
JOIN enrollments e
    ON p.enrollment_id = e.enrollment_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE e.student_id = $1
ORDER BY p.created_at DESC;


-- READ
-- R35: Fetch payments received for courses of a teacher

SELECT
    p.payment_id,
    p.amount,
    p.currency,
    p.payment_method,
    p.payment_status,
    p.paid_at,
    c.course_id,
    c.title AS course_title,
    u.full_name AS student_name
FROM payments p
JOIN enrollments e
    ON p.enrollment_id = e.enrollment_id
JOIN courses c
    ON e.course_id = c.course_id
JOIN users u
    ON e.student_id = u.user_id
WHERE c.teacher_id = $1
ORDER BY p.created_at DESC;


-- READ
-- R36: Calculate total successful payment revenue

SELECT
    currency,
    SUM(amount) AS total_revenue,
    COUNT(*) AS successful_payments
FROM payments
WHERE payment_status = 'successful'
GROUP BY currency;


-- READ
-- R37: Fetch payment statistics by status

SELECT
    payment_status,
    COUNT(*) AS total_payments,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_status
ORDER BY total_payments DESC;


-- READ
-- R38: Fetch pending and failed payments

SELECT
    payment_id,
    enrollment_id,
    amount,
    currency,
    payment_method,
    payment_status,
    created_at
FROM payments
WHERE payment_status IN ('pending', 'failed')
ORDER BY created_at DESC;


-- WRITE
-- W19: Create a payment record

INSERT INTO payments
    (enrollment_id, amount, currency, payment_method,
     transaction_reference, payment_status)
VALUES
    ($1, $2, $3, $4, $5, $6)
RETURNING payment_id, enrollment_id, amount, currency, payment_status;


-- WRITE
-- W20: Update payment status

UPDATE payments
SET payment_status = $2,
    paid_at = CASE
        WHEN $2 = 'successful' THEN CURRENT_TIMESTAMP
        ELSE paid_at
    END
WHERE payment_id = $1
RETURNING payment_id, payment_status, paid_at;


-- WRITE
-- W21: Update payment transaction reference

UPDATE payments
SET transaction_reference = $2
WHERE payment_id = $1
RETURNING payment_id, transaction_reference;


-- ============================================================
-- 6. REVIEWS
-- ============================================================

-- READ
-- R39: Fetch review of an enrollment

SELECT
    r.review_id,
    r.enrollment_id,
    r.rating,
    r.review_text,
    r.created_at,
    r.updated_at
FROM reviews r
WHERE r.enrollment_id = $1;


-- READ
-- R40: Fetch all reviews of a course

SELECT
    r.review_id,
    r.rating,
    r.review_text,
    r.created_at,
    u.user_id AS student_id,
    u.full_name AS student_name,
    c.course_id,
    c.title AS course_title
FROM reviews r
JOIN enrollments e
    ON r.enrollment_id = e.enrollment_id
JOIN users u
    ON e.student_id = u.user_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE c.course_id = $1
ORDER BY r.created_at DESC;


-- READ
-- R41: Calculate average rating and review count of a course

SELECT
    c.course_id,
    c.title,
    COALESCE(AVG(r.rating), 0) AS average_rating,
    COUNT(r.review_id) AS total_reviews
FROM courses c
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
LEFT JOIN reviews r
    ON e.enrollment_id = r.enrollment_id
WHERE c.course_id = $1
GROUP BY c.course_id;


-- READ
-- R42: Fetch all reviews submitted by a student

SELECT
    r.review_id,
    r.rating,
    r.review_text,
    r.created_at,
    c.course_id,
    c.title AS course_title
FROM reviews r
JOIN enrollments e
    ON r.enrollment_id = e.enrollment_id
JOIN courses c
    ON e.course_id = c.course_id
WHERE e.student_id = $1
ORDER BY r.created_at DESC;


-- WRITE
-- W22: Submit a course review

INSERT INTO reviews
    (enrollment_id, rating, review_text)
VALUES
    ($1, $2, $3)
RETURNING review_id, enrollment_id, rating, review_text, created_at;


-- WRITE
-- W23: Update a course review

UPDATE reviews
SET rating = $2,
    review_text = $3,
    updated_at = CURRENT_TIMESTAMP
WHERE review_id = $1
RETURNING review_id, rating, review_text, updated_at;


-- WRITE
-- W24: Delete a course review

DELETE FROM reviews
WHERE review_id = $1
RETURNING review_id;


-- ============================================================
-- 7. LEARNING PROGRESS
-- ============================================================

-- READ
-- R43: Fetch learning progress of a student in a course

SELECT
    lp.progress_id,
    lp.lesson_id,
    l.title AS lesson_title,
    l.lesson_order,
    l.duration_seconds,
    lp.progress_status,
    lp.watched_seconds,
    lp.completed_at,
    lp.updated_at
FROM learning_progress lp
JOIN enrollments e
    ON lp.enrollment_id = e.enrollment_id
JOIN lessons l
    ON lp.lesson_id = l.lesson_id
   AND lp.course_id = l.course_id
WHERE e.student_id = $1
  AND e.course_id = $2
ORDER BY l.lesson_order;


-- READ
-- R44: Fetch progress of a particular enrollment

SELECT
    lp.progress_id,
    lp.enrollment_id,
    lp.course_id,
    lp.lesson_id,
    l.title AS lesson_title,
    lp.progress_status,
    lp.watched_seconds,
    lp.completed_at,
    lp.updated_at
FROM learning_progress lp
JOIN lessons l
    ON lp.lesson_id = l.lesson_id
   AND lp.course_id = l.course_id
WHERE lp.enrollment_id = $1
ORDER BY l.lesson_order;


-- READ
-- R45: Fetch progress of a particular lesson for an enrollment

SELECT
    lp.progress_id,
    lp.progress_status,
    lp.watched_seconds,
    lp.completed_at,
    lp.updated_at
FROM learning_progress lp
WHERE lp.enrollment_id = $1
  AND lp.lesson_id = $2;


-- READ
-- R46: Calculate course completion percentage for an enrollment

SELECT
    e.enrollment_id,
    e.course_id,
    COUNT(l.lesson_id) AS total_lessons,
    COUNT(lp.lesson_id) FILTER (
        WHERE lp.progress_status = 'completed'
    ) AS completed_lessons,
    COALESCE(
        ROUND(
            100.0 * COUNT(lp.lesson_id) FILTER (
                WHERE lp.progress_status = 'completed'
            ) / NULLIF(COUNT(l.lesson_id), 0),
            2
        ),
        0
    ) AS completion_percentage
FROM enrollments e
JOIN lessons l
    ON e.course_id = l.course_id
LEFT JOIN learning_progress lp
    ON lp.enrollment_id = e.enrollment_id
   AND lp.lesson_id = l.lesson_id
WHERE e.enrollment_id = $1
GROUP BY e.enrollment_id, e.course_id;


-- READ
-- R47: Fetch total watched time of a student in a course

SELECT
    e.enrollment_id,
    e.student_id,
    e.course_id,
    SUM(lp.watched_seconds) AS total_watched_seconds,
    ROUND(SUM(lp.watched_seconds) / 60.0, 2) AS total_watched_minutes
FROM enrollments e
LEFT JOIN learning_progress lp
    ON e.enrollment_id = lp.enrollment_id
WHERE e.student_id = $1
  AND e.course_id = $2
GROUP BY e.enrollment_id;


-- READ
-- R48: Fetch completed lessons of an enrollment

SELECT
    lp.lesson_id,
    l.title,
    l.lesson_order,
    lp.watched_seconds,
    lp.completed_at
FROM learning_progress lp
JOIN lessons l
    ON lp.lesson_id = l.lesson_id
   AND lp.course_id = l.course_id
WHERE lp.enrollment_id = $1
  AND lp.progress_status = 'completed'
ORDER BY l.lesson_order;


-- READ
-- R49: Fetch incomplete lessons of an enrollment

SELECT
    l.lesson_id,
    l.title,
    l.lesson_order,
    lp.progress_status,
    lp.watched_seconds
FROM lessons l
LEFT JOIN learning_progress lp
    ON lp.lesson_id = l.lesson_id
   AND lp.course_id = l.course_id
   AND lp.enrollment_id = $1
WHERE l.course_id = $2
  AND (
      lp.progress_status IS NULL
      OR lp.progress_status <> 'completed'
  )
ORDER BY l.lesson_order;


-- READ
-- R50: Fetch learning progress statistics for a course

SELECT
    c.course_id,
    c.title,
    COUNT(lp.progress_id) AS total_progress_records,
    COUNT(lp.progress_id) FILTER (
        WHERE lp.progress_status = 'completed'
    ) AS completed_records,
    COUNT(lp.progress_id) FILTER (
        WHERE lp.progress_status = 'in_progress'
    ) AS in_progress_records,
    COUNT(lp.progress_id) FILTER (
        WHERE lp.progress_status = 'not_started'
    ) AS not_started_records
FROM courses c
LEFT JOIN learning_progress lp
    ON c.course_id = lp.course_id
WHERE c.course_id = $1
GROUP BY c.course_id;


-- WRITE
-- W25: Create learning progress record

INSERT INTO learning_progress
    (enrollment_id, course_id, lesson_id, progress_status, watched_seconds)
VALUES
    ($1, $2, $3, $4, $5)
RETURNING progress_id, enrollment_id, course_id, lesson_id,
          progress_status, watched_seconds;


-- WRITE
-- W26: Update lesson learning progress

UPDATE learning_progress
SET progress_status = $3,
    watched_seconds = $4,
    completed_at = CASE
        WHEN $3 = 'completed' THEN CURRENT_TIMESTAMP
        ELSE NULL
    END,
    updated_at = CURRENT_TIMESTAMP
WHERE enrollment_id = $1
  AND lesson_id = $2
RETURNING progress_id, progress_status, watched_seconds,
          completed_at, updated_at;


-- WRITE
-- W27: Increment watched time for a lesson

UPDATE learning_progress
SET watched_seconds = watched_seconds + $3,
    progress_status = CASE
        WHEN progress_status = 'not_started' THEN 'in_progress'
        ELSE progress_status
    END,
    updated_at = CURRENT_TIMESTAMP
WHERE enrollment_id = $1
  AND lesson_id = $2
RETURNING progress_id, watched_seconds, progress_status, updated_at;


-- WRITE
-- W28: Mark a lesson as completed

UPDATE learning_progress
SET progress_status = 'completed',
    completed_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
WHERE enrollment_id = $1
  AND lesson_id = $2
RETURNING progress_id, progress_status, completed_at;


-- WRITE
-- W29: Reset lesson progress

UPDATE learning_progress
SET progress_status = 'not_started',
    watched_seconds = 0,
    completed_at = NULL,
    updated_at = CURRENT_TIMESTAMP
WHERE enrollment_id = $1
  AND lesson_id = $2
RETURNING progress_id, progress_status, watched_seconds;


-- WRITE
-- W30: Delete learning progress record

DELETE FROM learning_progress
WHERE progress_id = $1
RETURNING progress_id;


-- ============================================================
-- 8. STUDENT DASHBOARD / COURSE SUMMARY
-- ============================================================

-- READ
-- R51: Fetch student dashboard course summary

SELECT
    e.enrollment_id,
    e.enrollment_status,
    e.enrolled_at,
    c.course_id,
    c.title AS course_title,
    u.full_name AS teacher_name,
    COUNT(DISTINCT l.lesson_id) AS total_lessons,
    COUNT(DISTINCT lp.lesson_id) FILTER (
        WHERE lp.progress_status = 'completed'
    ) AS completed_lessons,
    COALESCE(SUM(lp.watched_seconds), 0) AS watched_seconds
FROM enrollments e
JOIN courses c
    ON e.course_id = c.course_id
JOIN users u
    ON c.teacher_id = u.user_id
LEFT JOIN lessons l
    ON c.course_id = l.course_id
LEFT JOIN learning_progress lp
    ON lp.enrollment_id = e.enrollment_id
   AND lp.lesson_id = l.lesson_id
WHERE e.student_id = $1
GROUP BY e.enrollment_id, c.course_id, u.user_id
ORDER BY e.enrolled_at DESC;


-- READ
-- R52: Fetch popular courses by enrollment count

SELECT
    c.course_id,
    c.title,
    c.price,
    u.full_name AS teacher_name,
    COUNT(e.enrollment_id) AS total_enrollments
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
   AND e.enrollment_status <> 'cancelled'
WHERE c.course_status = 'published'
GROUP BY c.course_id, u.user_id
ORDER BY total_enrollments DESC
LIMIT $1;


-- READ
-- R53: Fetch course catalog with lesson count and rating

SELECT
    c.course_id,
    c.title,
    c.description,
    c.price,
    u.full_name AS teacher_name,
    COUNT(DISTINCT l.lesson_id) AS total_lessons,
    COALESCE(AVG(r.rating), 0) AS average_rating,
    COUNT(DISTINCT r.review_id) AS total_reviews
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
LEFT JOIN lessons l
    ON c.course_id = l.course_id
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
LEFT JOIN reviews r
    ON e.enrollment_id = r.enrollment_id
WHERE c.course_status = 'published'
GROUP BY c.course_id, u.user_id
ORDER BY c.created_at DESC;


-- READ
-- R54: Fetch teacher dashboard statistics

SELECT
    u.user_id AS teacher_id,
    u.full_name AS teacher_name,
    COUNT(DISTINCT c.course_id) AS total_courses,
    COUNT(DISTINCT e.enrollment_id) AS total_enrollments,
    COUNT(DISTINCT e.student_id) AS total_students
FROM users u
LEFT JOIN courses c
    ON u.user_id = c.teacher_id
LEFT JOIN enrollments e
    ON c.course_id = e.course_id
WHERE u.user_id = $1
  AND u.role = 'teacher'
GROUP BY u.user_id;


-- READ
-- R55: Fetch admin platform statistics

SELECT
    (SELECT COUNT(*) FROM users WHERE role = 'student') AS total_students,
    (SELECT COUNT(*) FROM users WHERE role = 'teacher') AS total_teachers,
    (SELECT COUNT(*) FROM courses) AS total_courses,
    (SELECT COUNT(*) FROM courses WHERE course_status = 'published') AS published_courses,
    (SELECT COUNT(*) FROM enrollments) AS total_enrollments,
    (SELECT COUNT(*) FROM payments WHERE payment_status = 'successful') AS successful_payments,
    (SELECT COALESCE(SUM(amount), 0)
     FROM payments
     WHERE payment_status = 'successful') AS total_revenue;


-- READ
-- R56: Fetch recently registered users

SELECT
    user_id,
    full_name,
    email,
    role,
    created_at
FROM users
ORDER BY created_at DESC
LIMIT $1;


-- READ
-- R57: Fetch recently created courses

SELECT
    c.course_id,
    c.title,
    c.price,
    c.course_status,
    c.created_at,
    u.full_name AS teacher_name
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
ORDER BY c.created_at DESC
LIMIT $1;


-- READ
-- R58: Fetch top-rated courses

SELECT
    c.course_id,
    c.title,
    u.full_name AS teacher_name,
    AVG(r.rating) AS average_rating,
    COUNT(r.review_id) AS total_reviews
FROM courses c
JOIN users u
    ON c.teacher_id = u.user_id
JOIN enrollments e
    ON c.course_id = e.course_id
JOIN reviews r
    ON e.enrollment_id = r.enrollment_id
WHERE c.course_status = 'published'
GROUP BY c.course_id, u.user_id
HAVING COUNT(r.review_id) >= $1
ORDER BY average_rating DESC, total_reviews DESC
LIMIT $2;


-- ============================================================
-- END OF LEARNHUB AP SQL QUERY COLLECTION
-- ============================================================
