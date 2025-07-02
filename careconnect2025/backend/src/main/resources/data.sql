-- 1. Insert users (patients, caregivers, family)
INSERT INTO users (id, email, password_hash, role, status, created_at, updated_at) VALUES
  (1,  'patient.one@example.com',   'hashed_password_patient1',   'PATIENT',   'ACTIVE', '2025-06-28 09:00', '2025-06-28 09:00'),
  (2,  'caregiver.one@example.com', 'hashed_password_caregiver1', 'CAREGIVER', 'ACTIVE', '2025-06-28 09:01', '2025-06-28 09:01'),
  (3,  'family.one@example.com',    'hashed_password_family1',    'FAMILY_MEMBER', 'ACTIVE', '2025-06-28 09:04', '2025-06-28 09:04'),
  (41, 'patient.fortyone@example.com', 'hashed_password_patient41', 'PATIENT',   'ACTIVE', '2025-06-28 09:10', '2025-06-28 09:10'),
  (42, 'caregiver.fortyone@example.com', 'hashed_password_caregiver41', 'CAREGIVER', 'ACTIVE', '2025-06-28 09:11', '2025-06-28 09:11');

-- 2. Caregivers
INSERT INTO caregiver (
  id, user_id, first_name, last_name, dob, email, phone,
  address_line1, address_line2, city, state, zip,
  caregiver_type, license_number, issuing_state, years_experience
) VALUES
  (1, 2,  'Jane', 'Doe', '1992-01-01', 'caregiver.one@example.com', '240-555-5555',
      '112 SE Ave', 'Apt 103', 'McLean', 'VA', '19053',
      'PROFESSIONAL', 'AA123454', 'VA', 5),
  (2, 42, 'Care', 'Giver', '1985-05-05', 'caregiver.fortyone@example.com', '301-555-1234',
      '500 Main St', NULL, 'Arlington', 'VA', '22201',
      'FAMILY', NULL, NULL, 2);

-- 3. Patients
INSERT INTO patient (
  user_id, first_name, last_name, dob, email, phone,
  address_line1, address_line2, city, state, zip,
  caregiver_id, relationship, sex, medical_notes
) VALUES
  (1,  'Jane', 'Doe', '1992-01-01', 'patient.one@example.com', '240-555-5555',
      '112 SE Ave', 'Apt 103', 'McLean', 'VA', '19053',
      1, 'daughter', 'F', 'Diabetic, needs daily insulin.'),   -- caregiver_id = 1
  (41, 'Patient', 'Fortyone', '1978-09-15', 'patient.fortyone@example.com', '202-555-8888',
      '200 North Rd', NULL, 'Bethesda', 'MD', '20814',
      2, 'client', 'M', 'Hypertension, on medication.');       -- caregiver_id = 2

-- 4. Meal entries
INSERT INTO meal_entry (patient_user_id, caregiver_user_id, calories, taken_at, created_at, updated_at) VALUES
(1, 2, 500, '2025-06-29 08:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 2, 650, '2025-06-29 12:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 42, 600, '2025-06-29 09:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 42, 700, '2025-06-29 13:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 5. Symptom entries
INSERT INTO symptom_entry (patient_user_id, caregiver_user_id, symptom_key, symptom_value, severity, taken_at, completed, created_at, updated_at) VALUES
(1, 2, 'Headache', 'Mild', 3, '2025-06-29 10:00:00', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 2, 'Nausea', 'Moderate', 4, '2025-06-29 15:00:00', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 42, 'Fatigue', 'Severe', 5, '2025-06-29 11:30:00', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 42, 'Dizziness', 'Mild', 2, '2025-06-29 16:00:00', TRUE, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 6. Wearable metrics
INSERT INTO wearable_metric (patient_user_id, metric, metric_value, recorded_at, created_at, updated_at) VALUES
(1, 'HEART_RATE', 75.5, '2025-06-29 07:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'STEPS', 3500, '2025-06-29 18:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BLOOD_PRESSURE_SYS', 120, '2025-06-29 07:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 'BLOOD_PRESSURE_DIA', 80,  '2025-06-29 07:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 'HEART_RATE', 68.0, '2025-06-29 08:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 'STEPS', 5000.0, '2025-06-29 12:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 'BLOOD_PRESSURE_SYS', 130, '2025-06-29 09:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 'BLOOD_PRESSURE_DIA', 85,  '2025-06-29 09:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 7. Mood entries
INSERT INTO mood_entry (patient_user_id, mood_score, taken_at, created_at, updated_at) VALUES
(1, 4, '2025-06-29 09:30:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(1, 5, '2025-06-29 19:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 3, '2025-06-29 14:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, 2, '2025-06-29 20:00:00', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 8. Summary metrics
INSERT INTO summary_metrics (patient_user_id, period_start, period_end, adherence_rate, avg_heart_rate, created_at, updated_at) VALUES
(1, '2025-06-22 00:00:00', '2025-06-28 23:59:59', 0.85, 72.0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(41, '2025-06-22 00:00:00', '2025-06-28 23:59:59', 0.92, 68.0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- 9. Family member link
INSERT INTO family_member_link (family_user_id, patient_user_id, granted_by, created_at) VALUES
(3, 1, 2, CURRENT_TIMESTAMP),
(3, 41, 42, CURRENT_TIMESTAMP);

-- 10. Email verification tokens
INSERT INTO email_verification_token (token, user_id, expires_at) VALUES
('token_patient1', 1, '2025-07-01 12:00:00'),
('token_patient41', 41, '2025-07-01 12:00:00');

ALTER TABLE users ALTER COLUMN id RESTART WITH 100;
ALTER TABLE caregiver ALTER COLUMN id RESTART WITH 100;
ALTER TABLE patient ALTER COLUMN id RESTART WITH 100;