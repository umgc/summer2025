-- V6__add_mood_pain_log_table.sql
-- Add mood and pain logging functionality for patients

CREATE TABLE mood_pain_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    patient_id BIGINT NOT NULL,
    mood_value INT NOT NULL CHECK (mood_value >= 1 AND mood_value <= 10),
    pain_value INT NOT NULL CHECK (pain_value >= 1 AND pain_value <= 10),
    note TEXT,
    timestamp TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE,
    INDEX idx_patient_timestamp (patient_id, timestamp),
    INDEX idx_timestamp (timestamp)
);
