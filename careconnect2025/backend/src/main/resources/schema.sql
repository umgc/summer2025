-- Drop tables in reverse dependency order to avoid FK constraint errors
DROP TABLE IF EXISTS family_member_link;
DROP TABLE IF EXISTS symptom_entry;
DROP TABLE IF EXISTS summary_metrics;
DROP TABLE IF EXISTS wearable_metric;
DROP TABLE IF EXISTS mood_entry;
DROP TABLE IF EXISTS meal_entry;
DROP TABLE IF EXISTS email_verification_token;
DROP TABLE IF EXISTS payment;
DROP TABLE IF EXISTS payment_method;
DROP TABLE IF EXISTS subscription;
DROP TABLE IF EXISTS plan;
-- Uncomment if you use these:
-- DROP TABLE IF EXISTS patient_profile;
-- DROP TABLE IF EXISTS caregiver_profile;
DROP TABLE IF EXISTS users;


-- 1. RBAC core

CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(254) NOT NULL UNIQUE,
  email_verified BOOLEAN DEFAULT FALSE,
  password_hash CHAR(100) NOT NULL,
  role VARCHAR(20) NOT NULL
       CHECK (role IN ('PATIENT','CAREGIVER','FAMILY_MEMBER','ADMIN')),
  status VARCHAR(20) DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','SUSPENDED')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE caregiver (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,        
  user_id BIGINT NOT NULL UNIQUE,  
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  dob DATE,
  email VARCHAR(254) NOT NULL UNIQUE,
  phone VARCHAR(32),
  address_line1 VARCHAR(255),
  address_line2 VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(50),
  zip VARCHAR(20),
  caregiver_type VARCHAR(20) NOT NULL,
  license_number VARCHAR(100),
  issuing_state VARCHAR(10),
  years_experience INT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 2. Profiles
CREATE TABLE patient (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,      
  user_id BIGINT NOT NULL UNIQUE,  
  first_name VARCHAR(100),
  last_name VARCHAR(100),
  dob DATE,
  email VARCHAR(254) NOT NULL UNIQUE,
  phone VARCHAR(32),
  address_line1 VARCHAR(255),
  address_line2 VARCHAR(255),
  city VARCHAR(100),
  state VARCHAR(50),
  zip VARCHAR(20),
  sex VARCHAR(10) CHECK(sex IN ('M','F','OTHER')),
  medical_notes TEXT,
  caregiver_id BIGINT,
  relationship VARCHAR(50), -- relationship to caregiver (e.g. "daughter", "client", etc.)
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_id) REFERENCES caregiver(id) ON DELETE SET NULL
);

-- 3. Billing
CREATE TABLE plan (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  price_cents INT NOT NULL CHECK(price_cents >= 0),
  billing_period VARCHAR(20) DEFAULT 'MONTH'
);

CREATE TABLE subscription (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  plan_id BIGINT NOT NULL,
  status VARCHAR(20) DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','SUSPENDED','GRACE','CANCELLED')),
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  current_period_end TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (plan_id) REFERENCES plan(id)
);

CREATE TABLE payment_method (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT,
  provider VARCHAR(20) NOT NULL CHECK(provider IN ('CARD','PAYPAL')),
  stripe_token VARCHAR(255),
  last4 CHAR(4),
  brand VARCHAR(20),
  exp_month INT,
  exp_year INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE payment (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  subscription_id BIGINT NOT NULL,
  payment_method_id BIGINT,
  amount_cents INT NOT NULL,
  stripe_session_id VARCHAR(255),
  stripe_payment_intent_id VARCHAR(255),
  status VARCHAR(20) NOT NULL CHECK(status IN ('SUCCEEDED','FAILED')),
  attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (subscription_id) REFERENCES subscription(id) ON DELETE CASCADE,
  FOREIGN KEY (payment_method_id) REFERENCES payment_method(id) ON DELETE SET NULL
);

CREATE TABLE email_verification_token (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    token VARCHAR(255) NOT NULL UNIQUE,
    user_id BIGINT,
    expires_at TIMESTAMP NOT NULL,
    CONSTRAINT fk_email_verification_token_user
      FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE meal_entry (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_user_id   BIGINT NOT NULL,
  caregiver_user_id BIGINT,
  calories INT CHECK(calories>=0),
  taken_at  TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_user_id)   REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (caregiver_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_meal_patient_time ON meal_entry(patient_user_id,taken_at);

CREATE TABLE mood_entry (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_user_id BIGINT NOT NULL,
  mood_score INT CHECK(mood_score BETWEEN 1 AND 5),
  taken_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_mood_patient_time ON mood_entry(patient_user_id,taken_at);

CREATE TABLE wearable_metric (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_user_id BIGINT NOT NULL,
  metric VARCHAR(20) NOT NULL CHECK(metric IN
    ('HEART_RATE','SPO2','TEMPERATURE',
     'BLOOD_PRESSURE_SYS','BLOOD_PRESSURE_DIA','WEIGHT',
     'STEPS')),
  metric_value DOUBLE NOT NULL,
  recorded_at TIMESTAMP NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_wearable_patient_time ON wearable_metric(patient_user_id,recorded_at);


CREATE TABLE summary_metrics (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_user_id BIGINT NOT NULL,
  period_start TIMESTAMP NOT NULL,
  period_end   TIMESTAMP NOT NULL,
  adherence_rate DOUBLE,
  avg_heart_rate DOUBLE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (patient_user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE(patient_user_id, period_start, period_end)
);

CREATE INDEX idx_summary_patient_end ON summary_metrics (patient_user_id, period_end);

CREATE TABLE symptom_entry (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  patient_user_id   BIGINT NOT NULL,
  caregiver_user_id BIGINT,
  symptom_key   VARCHAR(60)  NOT NULL,
  symptom_value VARCHAR(255) NOT NULL,
  severity INT CHECK(severity BETWEEN 1 AND 5),
  taken_at TIMESTAMP NOT NULL,
  completed BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 FOREIGN KEY (patient_user_id)   REFERENCES users(id) ON DELETE CASCADE,
FOREIGN KEY (caregiver_user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_symptom_patient_time ON symptom_entry(patient_user_id,taken_at);

CREATE TABLE family_member_link (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  family_user_id  BIGINT,
  patient_user_id BIGINT,
  granted_by      BIGINT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (family_user_id)  REFERENCES users(id) ON DELETE CASCADE,
FOREIGN KEY (patient_user_id) REFERENCES users(id) ON DELETE CASCADE,
FOREIGN KEY (granted_by)      REFERENCES users(id) ON DELETE SET NULL
);