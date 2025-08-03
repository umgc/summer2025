-- Add gender column to patient and caregiver tables

ALTER TABLE patient ADD COLUMN gender VARCHAR(20);
ALTER TABLE caregiver ADD COLUMN gender VARCHAR(20);

-- Create patient_allergy table for storing patient allergies
CREATE TABLE patient_allergy (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    patient_id BIGINT NOT NULL,
    allergen VARCHAR(255) NOT NULL,
    allergy_type VARCHAR(50),
    severity VARCHAR(50),
    reaction TEXT,
    notes TEXT,
    diagnosed_date VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_patient_allergy_patient FOREIGN KEY (patient_id) REFERENCES patient(id) ON DELETE CASCADE
);

-- Create indexes for better query performance
CREATE INDEX idx_patient_allergy_patient_id ON patient_allergy(patient_id);
CREATE INDEX idx_patient_allergy_active ON patient_allergy(patient_id, is_active);
CREATE INDEX idx_patient_allergy_allergen ON patient_allergy(allergen);

