package com.careconnect.controller.v2;


import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/dashboard")
public class DashboardController {

    @GetMapping("/caregiver")
    @PreAuthorize("hasRole('CAREGIVER')")
    public String caregiverDashboard() {
        return "Caregiver Dashboard - Confidential Content";
    }

    @GetMapping("/patient")
    @PreAuthorize("hasRole('PATIENT')")
    public String patientDashboard() {
        return "Patient Dashboard - Personal Health Info";
    }
}
