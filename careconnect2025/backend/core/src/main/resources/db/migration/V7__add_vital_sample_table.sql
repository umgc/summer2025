CREATE TABLE vital_sample (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    timestamp TIMESTAMP NOT NULL,
    heart_rate DOUBLE,
    spo2 DOUBLE,
    systolic INT,
    diastolic INT,
    weight DOUBLE,
    mood_value INT CHECK (mood_value >= 1 AND mood_value <= 10),
    pain_value INT CHECK (pain_value >= 1 AND pain_value <= 10),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vital_sample_patient FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX idx_vital_sample_patient_timestamp ON vital_sample(patient_id, timestamp);
CREATE INDEX idx_vital_sample_timestamp ON vital_sample(timestamp);

