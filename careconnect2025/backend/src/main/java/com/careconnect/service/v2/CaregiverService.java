package com.careconnect.service.v2;

import com.careconnect.model.v2.Caregiver;
import com.careconnect.model.v2.Patient;
import com.careconnect.repository.v2.CaregiverRepository;
import com.careconnect.repository.v2.PatientRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.context.annotation.Profile;

@Profile("v2")
@Service
public class CaregiverService {

    @Autowired
    private CaregiverRepository caregiverRepository;

    @Autowired
    private PatientRepository patientRepository;

    // 1. List patients under a caregiver, with optional filtering
    public List<Patient> getPatientsByCaregiver(Long caregiverId, String email, String name) {
        List<Patient> patients = patientRepository.findByCaregiverId(caregiverId);

        if (email != null && !email.isEmpty()) {
            patients = patients.stream()
                    .filter(p -> p.getEmail() != null && p.getEmail().equalsIgnoreCase(email))
                    .collect(Collectors.toList());
        }
        if (name != null && !name.isEmpty()) {
            patients = patients.stream()
                    .filter(p -> (p.getFirstName() + " " + p.getLastName()).toLowerCase().contains(name.toLowerCase()))
                    .collect(Collectors.toList());
        }
        return patients;
    }

    // 2. Get caregiver details
    public Caregiver getCaregiverById(Long caregiverId) {
        return caregiverRepository.findById(caregiverId)
                .orElseThrow(() -> new RuntimeException("Caregiver not found"));
    }

public Caregiver updateCaregiver(Long caregiverId, Caregiver updatedCaregiver) {
    Caregiver existing = caregiverRepository.findById(caregiverId)
        .orElseThrow(() -> new RuntimeException("Caregiver not found"));
    existing.setFirstName(updatedCaregiver.getFirstName());
    existing.setLastName(updatedCaregiver.getLastName());
    existing.setDob(updatedCaregiver.getDob());
    existing.setEmail(updatedCaregiver.getEmail());
    existing.setPhone(updatedCaregiver.getPhone());
    existing.setAddress(updatedCaregiver.getAddress());
    existing.setProfessional(updatedCaregiver.getProfessional());
    existing.setCaregiverType(updatedCaregiver.getCaregiverType()); 
    return caregiverRepository.save(existing);
}
}