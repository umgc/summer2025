package com.careconnect.service;

import com.careconnect.dto.MedicationDTO;
import com.careconnect.model.Medication;
import com.careconnect.model.Patient;
import com.careconnect.repository.MedicationRepository;
import com.careconnect.repository.PatientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MedicationService {
    
    private final MedicationRepository medicationRepository;
    private final PatientRepository patientRepository;
    
    /**
     * Get all active medications for a patient
     */
    public List<MedicationDTO> getActiveMedicationsForPatient(Long patientId) {
        Patient patient = patientRepository.findById(patientId)
            .orElseThrow(() -> new IllegalArgumentException("Patient not found with id: " + patientId));
        
        return medicationRepository.findByPatientAndIsActiveTrueOrderByCreatedAtDesc(patient)
            .stream()
            .map(this::mapToDTO)
            .toList();
    }
    
    /**
     * Get all medications (active and inactive) for a patient
     */
    public List<MedicationDTO> getAllMedicationsForPatient(Long patientId) {
        Patient patient = patientRepository.findById(patientId)
            .orElseThrow(() -> new IllegalArgumentException("Patient not found with id: " + patientId));
        
        return medicationRepository.findByPatientOrderByCreatedAtDesc(patient)
            .stream()
            .map(this::mapToDTO)
            .toList();
    }
    
    /**
     * Create a new medication
     */
    @Transactional
    public MedicationDTO createMedication(MedicationDTO medicationDTO) {
        Patient patient = patientRepository.findById(medicationDTO.patientId())
            .orElseThrow(() -> new IllegalArgumentException("Patient not found with id: " + medicationDTO.patientId()));
        
        Medication medication = Medication.builder()
            .patient(patient)
            .medicationName(medicationDTO.medicationName())
            .dosage(medicationDTO.dosage())
            .frequency(medicationDTO.frequency())
            .route(medicationDTO.route())
            .medicationType(medicationDTO.medicationType())
            .prescribedBy(medicationDTO.prescribedBy())
            .prescribedDate(medicationDTO.prescribedDate())
            .startDate(medicationDTO.startDate())
            .endDate(medicationDTO.endDate())
            .notes(medicationDTO.notes())
            .isActive(medicationDTO.isActive() != null ? medicationDTO.isActive() : true)
            .build();
        
        Medication saved = medicationRepository.save(medication);
        return mapToDTO(saved);
    }
    
    /**
     * Update an existing medication
     */
    @Transactional
    public MedicationDTO updateMedication(Long id, MedicationDTO medicationDTO) {
        Medication existing = medicationRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Medication not found with id: " + id));
        
        // Update only non-null fields
        if (medicationDTO.medicationName() != null) {
            existing.setMedicationName(medicationDTO.medicationName());
        }
        if (medicationDTO.dosage() != null) {
            existing.setDosage(medicationDTO.dosage());
        }
        if (medicationDTO.frequency() != null) {
            existing.setFrequency(medicationDTO.frequency());
        }
        if (medicationDTO.route() != null) {
            existing.setRoute(medicationDTO.route());
        }
        if (medicationDTO.medicationType() != null) {
            existing.setMedicationType(medicationDTO.medicationType());
        }
        if (medicationDTO.prescribedBy() != null) {
            existing.setPrescribedBy(medicationDTO.prescribedBy());
        }
        if (medicationDTO.prescribedDate() != null) {
            existing.setPrescribedDate(medicationDTO.prescribedDate());
        }
        if (medicationDTO.startDate() != null) {
            existing.setStartDate(medicationDTO.startDate());
        }
        if (medicationDTO.endDate() != null) {
            existing.setEndDate(medicationDTO.endDate());
        }
        if (medicationDTO.notes() != null) {
            existing.setNotes(medicationDTO.notes());
        }
        if (medicationDTO.isActive() != null) {
            existing.setIsActive(medicationDTO.isActive());
        }
        
        Medication updated = medicationRepository.save(existing);
        return mapToDTO(updated);
    }
    
    /**
     * Get medication by ID
     */
    public Optional<MedicationDTO> getMedication(Long id) {
        return medicationRepository.findById(id)
            .map(this::mapToDTO);
    }
    
    /**
     * Deactivate a medication (soft delete)
     */
    @Transactional
    public void deactivateMedication(Long id) {
        Medication medication = medicationRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Medication not found with id: " + id));
        
        medication.setIsActive(false);
        medicationRepository.save(medication);
    }
    
    /**
     * Map Medication entity to DTO
     */
    private MedicationDTO mapToDTO(Medication medication) {
        return MedicationDTO.builder()
            .id(medication.getId())
            .patientId(medication.getPatient().getId())
            .medicationName(medication.getMedicationName())
            .dosage(medication.getDosage())
            .frequency(medication.getFrequency())
            .route(medication.getRoute())
            .medicationType(medication.getMedicationType())
            .prescribedBy(medication.getPrescribedBy())
            .prescribedDate(medication.getPrescribedDate())
            .startDate(medication.getStartDate())
            .endDate(medication.getEndDate())
            .notes(medication.getNotes())
            .isActive(medication.getIsActive())
            .build();
    }
}
