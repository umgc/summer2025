package com.careconnect.controller;

import com.careconnect.dto.PatientDataResponse;
import com.careconnect.dto.DashboardDTO;
import com.careconnect.dto.VitalSampleDTO;
import com.careconnect.exception.AppException;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.Role;
import com.careconnect.service.FamilyMemberService;
import com.careconnect.service.AnalyticsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Period;
import java.util.List;

@RestController
@RequestMapping("/v1/api/family-members")
public class FamilyMemberController {

    @Autowired
    private FamilyMemberService familyMemberService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AnalyticsService analyticsService;

    // Helper method to get current user and validate they are a family member
    private User getCurrentFamilyMember() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        Long currentUserId = Long.parseLong(authentication.getName());
        User user = userRepository.findById(currentUserId)
                .orElseThrow(() -> new AppException(HttpStatus.UNAUTHORIZED, "User not authenticated"));
        
        if (user.getRole() != Role.FAMILY_MEMBER) {
            throw new AppException(HttpStatus.FORBIDDEN, "This endpoint is only accessible to family members");
        }
        
        return user;
    }

    // 1. Get all patients accessible to the authenticated family member
    @GetMapping("/patients")
    public ResponseEntity<List<PatientDataResponse>> getAccessiblePatients() {
        User familyMember = getCurrentFamilyMember();
        List<PatientDataResponse> patients = familyMemberService.getAccessiblePatients(familyMember.getId());
        return ResponseEntity.ok(patients);
    }

    // 2. Get specific patient data (read-only access)
    @GetMapping("/patients/{patientId}")
    public ResponseEntity<PatientDataResponse> getPatientData(@PathVariable Long patientId) {
        User familyMember = getCurrentFamilyMember();
        PatientDataResponse patientData = familyMemberService.getPatientData(familyMember.getId(), patientId);
        return ResponseEntity.ok(patientData);
    }

    // 3. Check if family member has access to a specific patient
    @GetMapping("/patients/{patientId}/access")
    public ResponseEntity<Boolean> hasAccessToPatient(@PathVariable Long patientId) {
        User familyMember = getCurrentFamilyMember();
        boolean hasAccess = familyMemberService.hasAccessToPatient(familyMember.getId(), patientId);
        return ResponseEntity.ok(hasAccess);
    }

    // 4. Get patient dashboard data (read-only)
    @GetMapping("/patients/{patientId}/dashboard")
    public ResponseEntity<DashboardDTO> getPatientDashboard(@PathVariable Long patientId,
                                                           @RequestParam(defaultValue = "30") int days) {
        User familyMember = getCurrentFamilyMember();
        
        // Verify access to patient
        if (!familyMemberService.hasAccessToPatient(familyMember.getId(), patientId)) {
            throw new AppException(HttpStatus.FORBIDDEN, "Access denied to patient data");
        }
        
        DashboardDTO dashboard = analyticsService.getDashboard(patientId, Period.ofDays(days));
        return ResponseEntity.ok(dashboard);
    }

    // 5. Get patient vital signs (read-only)
    @GetMapping("/patients/{patientId}/vitals")
    public ResponseEntity<List<VitalSampleDTO>> getPatientVitals(@PathVariable Long patientId,
                                                                @RequestParam(defaultValue = "7") int days) {
        User familyMember = getCurrentFamilyMember();
        
        // Verify access to patient
        if (!familyMemberService.hasAccessToPatient(familyMember.getId(), patientId)) {
            throw new AppException(HttpStatus.FORBIDDEN, "Access denied to patient data");
        }
        
        List<VitalSampleDTO> vitals = analyticsService.getVitals(patientId, Period.ofDays(days));
        return ResponseEntity.ok(vitals);
    }
}
