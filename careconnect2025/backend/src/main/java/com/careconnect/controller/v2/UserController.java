package com.careconnect.controller.v2;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.context.annotation.Profile;

import com.careconnect.security.v2.UserDetailsServiceImpl;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/users")
public class UserController {
	
	private final UserDetailsServiceImpl userProfileService;

    public UserController(UserDetailsServiceImpl userProfileService) {
        this.userProfileService = userProfileService;
    }
    
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@AuthenticationPrincipal Object principal) {
        return userProfileService.extractUserProfile(principal);
    }
    @GetMapping("/{id}")
    public ResponseEntity<String> getUser(@PathVariable String id) { return ResponseEntity.ok("User " + id); }
    
    @PutMapping("/{id}")
    public ResponseEntity<String> updateUser(@PathVariable String id) { return ResponseEntity.ok("User updated: " + id); }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteUser(@PathVariable String id) { return ResponseEntity.ok("User deleted: " + id); }
   
    @PostMapping("/caregivers")
    public ResponseEntity<String> createCaregiver() { return ResponseEntity.ok("Caregiver created"); }
    
    @GetMapping("/caregivers")
    public ResponseEntity<String> listCaregivers() { return ResponseEntity.ok("Caregivers listed"); }
    
    @PostMapping("/patients")
    public ResponseEntity<String> createPatient() { return ResponseEntity.ok("Patient created"); }
   
    @PostMapping("/patients/{id}/link")
    public ResponseEntity<String> linkPatient(@PathVariable String id) { return ResponseEntity.ok("Patient linked: " + id); }
    
    @PostMapping("/patients/{id}/invite-family")
    public ResponseEntity<String> inviteFamily(@PathVariable String id) { return ResponseEntity.ok("Permissions updated for patient: " + id); }

    @PostMapping("/patients/{id}/permissions")
    public ResponseEntity<String> updatePermissions(@PathVariable String id) { return ResponseEntity.ok("Permissions updated for patient: " + id); }
}