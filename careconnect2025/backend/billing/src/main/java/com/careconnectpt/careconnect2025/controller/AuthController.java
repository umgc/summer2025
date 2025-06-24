package com.careconnectpt.careconnect2025.controller;

import com.careconnectpt.careconnect2025.dto.auth.*;
import com.careconnectpt.careconnect2025.service.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {


    private final AuthService auth;
    public AuthController(AuthService auth) { this.auth = auth; }
    
    @PostMapping("/login")
    public ResponseEntity<TokenDto> login(@RequestBody LoginRequest req) {
        return ResponseEntity.ok(auth.login(req));
    }

    @PostMapping("/register/patient")
    @ResponseStatus(HttpStatus.CREATED)
    public void registerPatient(@RequestBody PatientRegistration reg) {
        auth.registerPatient(reg);
    }

    @PostMapping("/register/caregiver")
    @ResponseStatus(HttpStatus.CREATED)
    public void registerCaregiver(@RequestBody CaregiverRegistration reg) {
        auth.registerCaregiver(reg);
    }
}