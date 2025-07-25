-- V2: Consolidated migration for password reset, enhanced linking, and cleanup
-- This migration includes:
-- 1. Password reset token functionality
-- 2. Enhanced family member and caregiver-patient linking
-- 3. Removal of direct caregiver-patient relationship

-- =====================================================
-- 1. PASSWORD RESET TOKEN TABLE
-- =====================================================
-- Add password_reset_token table for secure password reset functionality
CREATE TABLE IF NOT EXISTS password_reset_token (
  id          BIGINT      PRIMARY KEY AUTO_INCREMENT,
  user_id     BIGINT      NOT NULL,
  token_hash  CHAR(64)    NOT NULL,      -- SHA-256 of random string
  expires_at  TIMESTAMP   NOT NULL,
  used        BOOLEAN     DEFAULT FALSE,
  created_at  TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_password_reset_token (token_hash)
);

-- =====================================================
-- 2. ENHANCED FAMILY MEMBER LINKING
-- =====================================================
-- Add enhanced family member link functionality
-- Add missing columns to the existing family_member_link table if they don't exist

-- Add status column if it doesn't exist
SET @sql = (SELECT CASE 
    WHEN COUNT(*) = 0 THEN 'ALTER TABLE family_member_link ADD COLUMN status VARCHAR(20) DEFAULT ''ACTIVE'' CHECK(status IN (''ACTIVE'',''SUSPENDED'',''REVOKED'',''EXPIRED''))'
    ELSE 'SELECT "status column already exists" as message'
END FROM information_schema.columns 
WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND column_name = 'status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add link_type column if it doesn't exist
SET @sql = (SELECT CASE 
    WHEN COUNT(*) = 0 THEN 'ALTER TABLE family_member_link ADD COLUMN link_type VARCHAR(20) DEFAULT ''PERMANENT'' CHECK(link_type IN (''PERMANENT'',''TEMPORARY'',''EMERGENCY''))'
    ELSE 'SELECT "link_type column already exists" as message'
END FROM information_schema.columns 
WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND column_name = 'link_type');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add expires_at column if it doesn't exist
SET @sql = (SELECT CASE 
    WHEN COUNT(*) = 0 THEN 'ALTER TABLE family_member_link ADD COLUMN expires_at TIMESTAMP NULL'
    ELSE 'SELECT "expires_at column already exists" as message'
END FROM information_schema.columns 
WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND column_name = 'expires_at');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add notes column if it doesn't exist
SET @sql = (SELECT CASE 
    WHEN COUNT(*) = 0 THEN 'ALTER TABLE family_member_link ADD COLUMN notes TEXT'
    ELSE 'SELECT "notes column already exists" as message'
END FROM information_schema.columns 
WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND column_name = 'notes');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add relationship column if it doesn't exist
SET @sql = (SELECT CASE 
    WHEN COUNT(*) = 0 THEN 'ALTER TABLE family_member_link ADD COLUMN relationship VARCHAR(100)'
    ELSE 'SELECT "relationship column already exists" as message'
END FROM information_schema.columns 
WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND column_name = 'relationship');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add updated_at column if it doesn't exist
SET @sql = (SELECT CASE 
    WHEN COUNT(*) = 0 THEN 'ALTER TABLE family_member_link ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP'
    ELSE 'SELECT "updated_at column already exists" as message'
END FROM information_schema.columns 
WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND column_name = 'updated_at');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 3. CAREGIVER-PATIENT LINKING TABLE
-- =====================================================
-- Create the caregiver_patient_link table if it doesn't exist
CREATE TABLE IF NOT EXISTS caregiver_patient_link (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    caregiver_user_id BIGINT NOT NULL,
    patient_user_id BIGINT NOT NULL,
    created_by BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','SUSPENDED','REVOKED','EXPIRED')),
    link_type VARCHAR(20) DEFAULT 'PERMANENT' CHECK(link_type IN ('PERMANENT','TEMPORARY','EMERGENCY')),
    expires_at TIMESTAMP NULL,
    notes TEXT,
    FOREIGN KEY (caregiver_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- 4. FAMILY MEMBER TABLE
-- =====================================================
-- Add family member table if it doesn't exist
CREATE TABLE IF NOT EXISTS family_member (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(254) NOT NULL UNIQUE,
    phone VARCHAR(32),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- =====================================================
-- 5. CREATE INDEXES FOR PERFORMANCE
-- =====================================================
-- For caregiver_patient_link table
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'caregiver_patient_link' AND index_name = 'idx_caregiver_patient_link_caregiver') = 0,
    'CREATE INDEX idx_caregiver_patient_link_caregiver ON caregiver_patient_link(caregiver_user_id)',
    'SELECT "idx_caregiver_patient_link_caregiver already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'caregiver_patient_link' AND index_name = 'idx_caregiver_patient_link_patient') = 0,
    'CREATE INDEX idx_caregiver_patient_link_patient ON caregiver_patient_link(patient_user_id)',
    'SELECT "idx_caregiver_patient_link_patient already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'caregiver_patient_link' AND index_name = 'idx_caregiver_patient_link_status') = 0,
    'CREATE INDEX idx_caregiver_patient_link_status ON caregiver_patient_link(status)',
    'SELECT "idx_caregiver_patient_link_status already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'caregiver_patient_link' AND index_name = 'idx_caregiver_patient_link_expires') = 0,
    'CREATE INDEX idx_caregiver_patient_link_expires ON caregiver_patient_link(expires_at)',
    'SELECT "idx_caregiver_patient_link_expires already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- For family_member_link table
SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND index_name = 'idx_family_member_link_family') = 0,
    'CREATE INDEX idx_family_member_link_family ON family_member_link(family_user_id)',
    'SELECT "idx_family_member_link_family already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND index_name = 'idx_family_member_link_patient') = 0,
    'CREATE INDEX idx_family_member_link_patient ON family_member_link(patient_user_id)',
    'SELECT "idx_family_member_link_patient already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND index_name = 'idx_family_member_link_status') = 0,
    'CREATE INDEX idx_family_member_link_status ON family_member_link(status)',
    'SELECT "idx_family_member_link_status already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF((SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'family_member_link' AND index_name = 'idx_family_member_link_expires') = 0,
    'CREATE INDEX idx_family_member_link_expires ON family_member_link(expires_at)',
    'SELECT "idx_family_member_link_expires already exists" as message');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- =====================================================
-- 6. REMOVE DIRECT CAREGIVER-PATIENT RELATIONSHIP
-- =====================================================
-- Remove the direct caregiver_id column from patient table since we now use linking tables

-- Drop foreign key constraints that reference caregiver_id if they exist
SET @constraint_name = (
    SELECT CONSTRAINT_NAME 
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
    WHERE TABLE_SCHEMA = DATABASE() 
    AND TABLE_NAME = 'patient' 
    AND COLUMN_NAME = 'caregiver_id'
    AND REFERENCED_TABLE_NAME IS NOT NULL
    LIMIT 1
);

SET @sql = IF(@constraint_name IS NOT NULL, 
    CONCAT('ALTER TABLE patient DROP FOREIGN KEY ', @constraint_name), 
    'SELECT "No foreign key constraint found for caregiver_id"');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Drop the caregiver_id column if it exists
SET @column_exists = (
    SELECT COUNT(*)
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'patient'
    AND COLUMN_NAME = 'caregiver_id'
);

SET @sql = IF(@column_exists > 0, 
    'ALTER TABLE patient DROP COLUMN caregiver_id', 
    'SELECT "Column caregiver_id does not exist"');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;