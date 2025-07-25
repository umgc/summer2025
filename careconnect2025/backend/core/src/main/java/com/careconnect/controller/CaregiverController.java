package com.careconnect.controller;

import com.careconnect.model.Caregiver;
import com.careconnect.model.Patient;
import com.careconnect.service.CaregiverService;
import com.careconnect.dto.CaregiverRegistration;
import com.careconnect.dto.PatientRegistration;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import com.careconnect.dto.PatientWithLinkDto;
// import com.careconnect.util.SecurityUtil;
import org.springframework.web.bind.annotation.*;
// import com.careconnect.security.Role;
import jakarta.servlet.http.HttpServletRequest;


import java.util.List;

@RestController
@RequestMapping("/v1/api/caregivers")
public class CaregiverController {

    @Autowired
    private CaregiverService caregiverService;

    @Autowired
    private CaregiverService auth; // Using caregiverService as auth for now
    // private SecurityUtil securityUtil;

    // 1. List patients under a caregiver, with optional filtering
    @GetMapping("/{caregiverId}/patients")
    public ResponseEntity<List<PatientWithLinkDto>> getPatientsByCaregiver(
        @PathVariable("caregiverId") Long caregiverId,
        @RequestParam(required = false) String email,
        @RequestParam(required = false) String name) {
        List<PatientWithLinkDto> patients = caregiverService.getPatientsByCaregiver(caregiverId, email, name);
        return ResponseEntity.ok(patients);
    }

    // 2. Get caregiver details
    @GetMapping("/{caregiverId}")
    public ResponseEntity<Caregiver> getCaregiver(@PathVariable Long caregiverId, HttpServletRequest request) {
        // SecurityUtil.UserInfo user = securityUtil.getCurrentUser(request);
        Caregiver caregiver = caregiverService.getCaregiverById(caregiverId);

        // if (user.role != Role.CAREGIVER || !caregiver.getEmail().equals(user.email)) {
        //     return ResponseEntity.status(403).build(); 
        // }

        return ResponseEntity.ok(caregiver);
    }

    @PostMapping
    public ResponseEntity<Caregiver> registerCaregiver(@RequestBody CaregiverRegistration reg) {
        Caregiver caregiver = auth.registerCaregiver(reg);
        return ResponseEntity.status(HttpStatus.CREATED).body(caregiver);
    }

    @PutMapping("/{caregiverId}")
    public ResponseEntity<Caregiver> updateCaregiver(@PathVariable Long caregiverId, @RequestBody Caregiver updatedCaregiver) {
    Caregiver caregiver = caregiverService.updateCaregiver(caregiverId, updatedCaregiver);
    return ResponseEntity.ok(caregiver);
  }

     @PostMapping("/{caregiverId}/patients")
    public ResponseEntity<Patient> registerPatient(
            @PathVariable Long caregiverId,
            @RequestBody PatientRegistration reg) {
        reg.setCaregiverId(caregiverId); 
        Patient patient = auth.registerPatient(reg);
        return ResponseEntity.ok(patient);
    }
    
    /**
     * Get a specific patient under a caregiver's care
     */
    @GetMapping("/{caregiverId}/patients/{patientId}")
    public ResponseEntity<?> getPatientForCaregiver(
            @PathVariable Long caregiverId,
            @PathVariable Long patientId) {
        
        // Check if the caregiver has access to this patient using entity IDs
        if (!caregiverService.caregiverHasAccessToPatient(caregiverId, patientId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body("Caregiver does not have access to this patient");
        }
        
        // If authorized, get the patient details with link information
        PatientWithLinkDto patientDto = caregiverService.getPatientWithLinkById(caregiverId, patientId);
        if (patientDto == null) {
            return ResponseEntity.notFound().build();
        }
        
        return ResponseEntity.ok(patientDto);
    }
}