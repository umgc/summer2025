package com.careconnect.controller.v2;

import com.careconnect.model.v2.Caregiver;
import com.careconnect.model.v2.Patient;
import com.careconnect.service.v2.CaregiverService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
// import com.careconnectpt.careconnect2025.util.SecurityUtil;
import org.springframework.web.bind.annotation.*;
// import com.careconnectpt.careconnect2025.security.Role;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Profile;

import java.util.List;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/caregivers")
public class CaregiverController {

    @Autowired
    private CaregiverService caregiverService;

    // @Autowired
    // private SecurityUtil securityUtil;

    // 1. List patients under a caregiver, with optional filtering
    @GetMapping("/{caregiverId}/patients")
    public ResponseEntity<List<Patient>> getPatientsByCaregiver(
            @PathVariable Long caregiverId,
            @RequestParam(required = false) String email,
            @RequestParam(required = false) String name,
            HttpServletRequest request) {

        // SecurityUtil.UserInfo user = securityUtil.getCurrentUser(request);
        // Caregiver caregiver = caregiverService.getCaregiverById(caregiverId);

        // if (user.role != Role.CAREGIVER || !caregiver.getEmail().equals(user.email)) {
        //     return ResponseEntity.status(403).build();
        // }

        List<Patient> patients = caregiverService.getPatientsByCaregiver(caregiverId, email, name);
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

    @PutMapping("/{caregiverId}")
    public ResponseEntity<Caregiver> updateCaregiver(@PathVariable Long caregiverId, @RequestBody Caregiver updatedCaregiver) {
    Caregiver caregiver = caregiverService.updateCaregiver(caregiverId, updatedCaregiver);
    return ResponseEntity.ok(caregiver);
}
}