package com.careconnect.service;

import com.careconnect.model.Caregiver;
import com.careconnect.model.Patient;
import com.careconnect.model.User;
import com.careconnect.repository.CaregiverRepository;
import com.careconnect.repository.PatientRepository;
import com.careconnect.repository.UserRepository;
import com.careconnect.exception.AppException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import com.careconnect.dto.CaregiverPatientLinkResponse;

@Service
public class PatientService {

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private CaregiverRepository caregiverRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private CaregiverPatientLinkService caregiverPatientLinkService;

    // 1. List caregivers associated with a patient (ACTIVE links only)
    public List<Caregiver> getCaregiversByPatient(Long patientId) {
        Patient patient = patientRepository.findById(patientId)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "Patient not found"));
        
        // Get active caregiver links via CaregiverPatientLinkService
        List<CaregiverPatientLinkResponse> activeLinks = caregiverPatientLinkService.getCaregiversByPatient(patient.getUser().getId());
        
        // Extract caregiver user IDs from active links and get User objects
        List<Caregiver> caregivers = activeLinks.stream()
                .map(link -> userRepository.findById(link.caregiverUserId()))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .map(user -> caregiverRepository.findByUser(user))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toList());
        
        return caregivers;
    }

    // 2. Get patient details
    public Patient getPatientById(Long patientId) {
        return patientRepository.findById(patientId)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "Patient not found"));
    }

    // 3. Get patient by user ID (for family member access)
    public Patient getPatientByUserId(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "User not found"));
        return patientRepository.findByUser(user)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "Patient profile not found"));
    }

    // 4. Update patient information
    public Patient updatePatient(Long patientId, Patient updatedPatient) {
        Patient existing = patientRepository.findById(patientId)
                .orElseThrow(() -> new AppException(HttpStatus.NOT_FOUND, "Patient not found"));
        existing.setFirstName(updatedPatient.getFirstName());
        existing.setLastName(updatedPatient.getLastName());
        existing.setDob(updatedPatient.getDob());
        existing.setEmail(updatedPatient.getEmail());
        existing.setPhone(updatedPatient.getPhone());
        existing.setAddress(updatedPatient.getAddress());
        existing.setRelationship(updatedPatient.getRelationship());
        return patientRepository.save(existing);
    }

    // 5. Check if a patient exists by user ID
    public boolean existsByUserId(Long userId) {
        User user = userRepository.findById(userId).orElse(null);
        return user != null && patientRepository.existsByUser(user);
    }

}