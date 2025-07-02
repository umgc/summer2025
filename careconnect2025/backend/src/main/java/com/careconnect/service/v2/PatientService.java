package com.careconnect.service.v2;

import com.careconnect.model.v2.Caregiver;
import com.careconnect.model.v2.Patient;
import com.careconnect.repository.v2.CaregiverRepository;
import com.careconnect.repository.v2.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;

import org.springframework.context.annotation.Profile;

@Profile("v2")
@Service
public class PatientService {

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private CaregiverRepository caregiverRepository;

    // 1. List caregivers associated with a patient
    public List<Caregiver> getCaregiversByPatient(Long patientId) {
        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() -> new RuntimeException("Patient not found"));
        // If a patient can have only one caregiver:
        if (patient.getCaregiver() != null) {
            return List.of(patient.getCaregiver());
        }
        return Collections.emptyList();
    }

    // 2. Get patient details
    public Patient getPatientById(Long patientId) {
        return patientRepository.findById(patientId)
                .orElseThrow(() -> new RuntimeException("Patient not found"));
    }

    public Patient updatePatient(Long patientId, Patient updatedPatient) {
    Patient existing = patientRepository.findById(patientId)
        .orElseThrow(() -> new RuntimeException("Patient not found"));
    existing.setFirstName(updatedPatient.getFirstName());
    existing.setLastName(updatedPatient.getLastName());
    existing.setDob(updatedPatient.getDob());
    existing.setEmail(updatedPatient.getEmail());
    existing.setPhone(updatedPatient.getPhone());
    existing.setAddress(updatedPatient.getAddress());
    existing.setRelationship(updatedPatient.getRelationship());
    return patientRepository.save(existing);
}
}