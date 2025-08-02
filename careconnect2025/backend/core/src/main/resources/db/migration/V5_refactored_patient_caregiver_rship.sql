CREATE TABLE patient_caregiver (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    patient_id BIGINT NOT NULL,
    caregiver_user_id BIGINT NOT NULL,
    relationship_type VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_patient FOREIGN KEY (patient_id) REFERENCES patient(id),
    CONSTRAINT fk_caregiver FOREIGN KEY (caregiver_user_id) REFERENCES users(id),
    CONSTRAINT uk_patient_caregiver UNIQUE (patient_id, caregiver_user_id)
);