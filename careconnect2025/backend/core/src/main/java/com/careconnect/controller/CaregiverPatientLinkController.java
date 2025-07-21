package com.careconnect.controller;

import com.careconnect.dto.*;
import com.careconnect.exception.AppException;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.Role;
import com.careconnect.service.CaregiverPatientLinkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/v1/api/caregiver-patient-links")
public class CaregiverPatientLinkController {

    @Autowired
    private CaregiverPatientLinkService linkService;

    @Autowired
    private UserRepository userRepository;

    // Helper method to get current user
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String email = authentication.getName();
        // Find user by email instead of parsing name as an ID
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new AppException(HttpStatus.UNAUTHORIZED, "User not authenticated"));
    }

    // 1. Create a new caregiver-patient link
    @PostMapping("/caregivers/{caregiverId}/patients")
    public ResponseEntity<CaregiverPatientLinkResponse> createLink(
            @PathVariable Long caregiverId,
            @RequestBody CreateLinkRequest request) {
        
        User currentUser = getCurrentUser();
        
        // Only admins and the caregiver themselves can create links
        if (currentUser.getRole() != Role.ADMIN && !currentUser.getId().equals(caregiverId)) {
            throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
        }

        CaregiverPatientLinkResponse response = linkService.createLink(caregiverId, request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    // 2. Update a link (suspend, reactivate, change type, etc.)
    @PutMapping("/{linkId}")
    public ResponseEntity<CaregiverPatientLinkResponse> updateLink(
            @PathVariable Long linkId,
            @RequestBody UpdateLinkRequest request) {
        
        User currentUser = getCurrentUser();
        
        // Only admins can update links for now (can be enhanced with more granular permissions)
        if (currentUser.getRole() != Role.ADMIN) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only admins can update links");
        }

        CaregiverPatientLinkResponse response = linkService.updateLink(linkId, request, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    // 3. Temporarily suspend a link
    @PostMapping("/{linkId}/suspend")
    public ResponseEntity<CaregiverPatientLinkResponse> suspendLink(@PathVariable Long linkId) {
        User currentUser = getCurrentUser();
        
        // Only admins and caregivers can suspend links
        if (currentUser.getRole() != Role.ADMIN && currentUser.getRole() != Role.CAREGIVER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
        }

        // Pass the user's email as the identifier
        CaregiverPatientLinkResponse response = linkService.suspendLink(linkId, currentUser.getEmail());
        return ResponseEntity.ok(response);
    }

    // 4. Reactivate a suspended link
    @PostMapping("/{linkId}/reactivate")
    public ResponseEntity<CaregiverPatientLinkResponse> reactivateLink(@PathVariable Long linkId) {
        User currentUser = getCurrentUser();
        
        // Only admins and caregivers can reactivate links
        if (currentUser.getRole() != Role.ADMIN && currentUser.getRole() != Role.CAREGIVER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
        }

        CaregiverPatientLinkResponse response = linkService.reactivateLink(linkId, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    // 5. Permanently revoke a link
    @DeleteMapping("/{linkId}")
    public ResponseEntity<Void> revokeLink(@PathVariable Long linkId) {
        User currentUser = getCurrentUser();
        
        // Only admins can permanently revoke links
        if (currentUser.getRole() != Role.ADMIN) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only admins can permanently revoke links");
        }

        linkService.revokeLink(linkId, currentUser.getId());
        return ResponseEntity.noContent().build();
    }

    // 6. Get all patients linked to a caregiver
    @GetMapping("/caregivers/{caregiverId}/patients")
    public ResponseEntity<List<CaregiverPatientLinkResponse>> getPatientsByCaregiver(@PathVariable Long caregiverId) {
        User currentUser = getCurrentUser();
        
        // Caregiver can see their own patients, admins can see all
        if (currentUser.getRole() != Role.ADMIN && !currentUser.getId().equals(caregiverId)) {
            throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
        }

        List<CaregiverPatientLinkResponse> links = linkService.getPatientsByCaregiver(caregiverId);
        return ResponseEntity.ok(links);
    }

    // 7. Get all caregivers linked to a patient
    @GetMapping("/patients/{patientId}/caregivers")
    public ResponseEntity<List<CaregiverPatientLinkResponse>> getCaregiversByPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        
        // Patient can see their own caregivers, admins can see all
        if (currentUser.getRole() != Role.ADMIN && !currentUser.getId().equals(patientId)) {
            throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
        }

        List<CaregiverPatientLinkResponse> links = linkService.getCaregiversByPatient(patientId);
        return ResponseEntity.ok(links);
    }

    // 8. Check if caregiver has access to patient
    @GetMapping("/caregivers/{caregiverId}/patients/{patientId}/access")
    public ResponseEntity<Boolean> hasAccessToPatient(
            @PathVariable Long caregiverId,
            @PathVariable Long patientId) {
        
        boolean hasAccess = linkService.hasAccessToPatient(caregiverId, patientId);
        return ResponseEntity.ok(hasAccess);
    }

    // 9. Get all links (admin only)
    @GetMapping
    public ResponseEntity<List<CaregiverPatientLinkResponse>> getAllLinks() {
        User currentUser = getCurrentUser();
        
        if (currentUser.getRole() != Role.ADMIN) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only admins can view all links");
        }

        List<CaregiverPatientLinkResponse> links = linkService.getAllLinks();
        return ResponseEntity.ok(links);
    }

    // 10. Cleanup expired links (admin only)
    @PostMapping("/cleanup-expired")
    public ResponseEntity<Void> cleanupExpiredLinks() {
        User currentUser = getCurrentUser();
        
        if (currentUser.getRole() != Role.ADMIN) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only admins can cleanup expired links");
        }

        linkService.cleanupExpiredLinks();
        return ResponseEntity.ok().build();
    }
}
