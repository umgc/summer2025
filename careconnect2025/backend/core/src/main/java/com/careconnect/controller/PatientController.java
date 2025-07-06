package com.careconnect.controller;

import com.careconnect.dto.FamilyMemberLinkResponse;
import com.careconnect.dto.FamilyMemberRegistration;
import com.careconnect.exception.AppException;
import com.careconnect.model.Caregiver;
import com.careconnect.model.Patient;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.Role;
import com.careconnect.service.CaregiverPatientLinkService;
import com.careconnect.service.FamilyMemberService;
import com.careconnect.service.PatientService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/api/patients")
public class PatientController {

    @Autowired
    private PatientService patientService;

    @Autowired
    private FamilyMemberService familyMemberService;

    @Autowired
    private CaregiverPatientLinkService caregiverPatientLinkService;

    @Autowired
    private UserRepository userRepository;

    // Helper method to get current user
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Long currentUserId = Long.parseLong(authentication.getName());
        return userRepository.findById(currentUserId)
                .orElseThrow(() -> new AppException(HttpStatus.UNAUTHORIZED, "User not authenticated"));
    }

    // Helper method to check if user has access to patient
    private void validatePatientAccess(Long patientUserId, User currentUser) {
        switch (currentUser.getRole()) {
            case PATIENT:
                // Patients can only access their own data
                if (!currentUser.getId().equals(patientUserId)) {
                    throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
                }
                break;
            case CAREGIVER:
                // Caregivers can access patients they're linked to (ACTIVE and not expired)
                if (!caregiverPatientLinkService.hasAccessToPatient(currentUser.getId(), patientUserId)) {
                    throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
                }
                break;
            case FAMILY_MEMBER:
                // Family members can access patients they're linked to (ACTIVE and not expired)
                if (!familyMemberService.hasAccessToPatient(currentUser.getId(), patientUserId)) {
                    throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
                }
                break;
            case ADMIN:
                // Admins can access all patients
                break;
            default:
                throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
        }
    }

    // 1. List caregivers associated with a patient
    @GetMapping("/{patientId}/caregivers")
    public ResponseEntity<List<Caregiver>> getCaregiversByPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        
        // Convert patientId to userId for validation
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        List<Caregiver> caregivers = patientService.getCaregiversByPatient(patientId);
        return ResponseEntity.ok(caregivers);
    }

    // 2. Get patient details
    @GetMapping("/{patientId}")
    public ResponseEntity<Patient> getPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        
        // Get patient and validate access
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        return ResponseEntity.ok(patient);
    }

    @PutMapping("/{patientId}")
    public ResponseEntity<Patient> updatePatient(@PathVariable Long patientId, @RequestBody Patient updatedPatient) {
        User currentUser = getCurrentUser();
        
        // Family members have read-only access, cannot update
        if (currentUser.getRole() == Role.FAMILY_MEMBER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Family members have read-only access");
        }
        
        // Validate access
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        Patient updatedResult = patientService.updatePatient(patientId, updatedPatient);
        return ResponseEntity.ok(updatedResult);
    }

    // 3. Get all family members for a patient
    @GetMapping("/{patientId}/family-members")
    public ResponseEntity<List<FamilyMemberLinkResponse>> getFamilyMembersByPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        
        // Convert patientId to userId for validation
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        List<FamilyMemberLinkResponse> familyMembers = familyMemberService.getFamilyMembersByPatient(patient.getUser().getId());
        return ResponseEntity.ok(familyMembers);
    }

    // 4. Register a new family member for a patient
    @PostMapping("/{patientId}/family-members")
    public ResponseEntity<FamilyMemberLinkResponse> registerFamilyMember(
            @PathVariable Long patientId,
            @RequestBody FamilyMemberRegistration registration) {
        
        User currentUser = getCurrentUser();
        
        // Only patients and caregivers can register family members, not family members themselves
        if (currentUser.getRole() == Role.FAMILY_MEMBER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Family members cannot register other family members");
        }
        
        // Convert patientId to userId for validation
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        // Create new registration with correct patient user ID
        FamilyMemberRegistration updatedRegistration = new FamilyMemberRegistration(
                registration.firstName(),
                registration.lastName(),
                registration.email(),
                registration.phone(),
                registration.address(),
                registration.relationship(),
                patient.getUser().getId()  // Use patient's user ID, not patient ID
        );
        
        FamilyMemberLinkResponse response = familyMemberService.registerFamilyMember(updatedRegistration, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    // 5. Revoke family member access to a patient
    @DeleteMapping("/family-members/{linkId}")
    public ResponseEntity<Void> revokeFamilyMemberAccess(@PathVariable Long linkId) {
        User currentUser = getCurrentUser();
        
        // Only patients and caregivers can revoke family member access
        if (currentUser.getRole() == Role.FAMILY_MEMBER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Family members cannot revoke access");
        }
        
        familyMemberService.revokeFamilyMemberAccess(linkId, currentUser.getId());
        return ResponseEntity.noContent().build();
    }
}