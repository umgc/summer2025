package com.careconnect.controller.v2;

import com.careconnect.dto.v2.CaregiverRegistration;
import com.careconnect.dto.v2.LoginRequest;
import com.careconnect.dto.v2.LoginResponse;
import com.careconnect.dto.v2.PatientRegistration;
import com.careconnect.model.v2.Caregiver;
import com.careconnect.model.v2.Patient;
import com.careconnect.service.v2.AuthService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api")
public class AuthController {


    private final AuthService auth;
    public AuthController(AuthService auth) { this.auth = auth; }


    // @PostMapping("/register")
    // public ResponseEntity<LoginResponse> register(@RequestBody PatientRegistration reg) {
    //     auth.registerPatient(reg);
	// 	return null;
    // }
    
    @PostMapping("/caregivers/{caregiverId}/patients")
    public ResponseEntity<Patient> registerPatient(
            @PathVariable Long caregiverId,
            @RequestBody PatientRegistration reg) {
        reg.setCaregiverId(caregiverId); 
        Patient patient = auth.registerPatient(reg);
        return ResponseEntity.ok(patient);
    }

    @PostMapping("/caregivers")
    public ResponseEntity<Caregiver> registerCaregiver(@RequestBody CaregiverRegistration reg) {
        Caregiver caregiver = auth.registerCaregiver(reg);
        return ResponseEntity.status(HttpStatus.CREATED).body(caregiver);
    }

    @PostMapping("/auth/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest req) {
        return ResponseEntity.ok(auth.login(req));
    }
    
    @PostMapping("/auth/logout")
    public ResponseEntity<String> logout() { return ResponseEntity.ok("User logged out"); }
    
    @PostMapping("/password-reset")
    public ResponseEntity<String> resetPassword() { return ResponseEntity.ok("Password reset"); }
    
    @PostMapping("/recover-account")
    public ResponseEntity<String> recoverAccount() { return ResponseEntity.ok("Account recovered"); }
    
    @PostMapping("/verify-otp")
    public ResponseEntity<String> verifyOtp() { return ResponseEntity.ok("OTP verified"); }
    
    @GetMapping("/sso/redirect")
    public ResponseEntity<String> googleSigninRedirect() { return ResponseEntity.ok("Redirecting to google"); }
    
    @PostMapping("/sso/callback")
    public ResponseEntity<String> googleSigninCallback() { return ResponseEntity.ok("SSO callback received"); }
}