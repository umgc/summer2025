package com.careconnect.security.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder; // Make sure you have spring-boot-starter-security or similar
import org.springframework.stereotype.Service;

import com.careconnect.dto.LoginRequest;
import com.careconnect.dto.LoginResponse;
import com.careconnect.model.Caregiver;
import com.careconnect.model.Patient;
import org.springframework.web.bind.annotation.*;

import com.careconnect.model.ProfessionalInfo;
import com.careconnect.model.User;
import com.careconnect.repository.CaregiverRepository;
import com.careconnect.repository.PatientRepository;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.JwtTokenProvider;
import com.careconnect.security.service.StripeService;
import com.careconnect.exception.*;

import java.sql.Timestamp;
import java.util.UUID;

import com.careconnect.dto.RegisterRequest;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.Role;
import jakarta.servlet.http.HttpSession;

import java.util.Collections;
import java.util.Optional;

@Service
public class AuthService {

    @Autowired
    private GamificationService gamificationService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private com.careconnect.security.service.EmailService emailService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private UserRepository users;

    @Autowired
    private PatientRepository patients;

    @Autowired
    private CaregiverRepository caregivers;

    @Autowired
    private PasswordEncoder encoder;

    @Autowired
    private JwtTokenProvider jwt;
    private Long patientId;
    private Long caregiverId;


    @Value("${careconnect.baseurl:http://localhost:8080}")
    private String baseUrl; // configurable via application.properties

    public ResponseEntity<?> register(RegisterRequest request) {
        // --- Validate & Convert Role ---
        Role userRole;
        try {
            userRole = Role.valueOf(request.getRole().toUpperCase());
        } catch (IllegalArgumentException | NullPointerException ex) {
            return ResponseEntity
                    .badRequest()
                    .body(Collections.singletonMap("error", "Invalid role: " + request.getRole()));
        }

        // 1. Lookup existing user by email & role (using enum)
        Optional<User> existingUserOpt = userRepository.findByEmailAndRole(request.getEmail(), userRole.name());

        // 2. If user exists
        if (existingUserOpt.isPresent()) {
            User existingUser = existingUserOpt.get();
            if (Boolean.FALSE.equals(existingUser.getIsVerified())) {
                // User exists but is not verified -> resend with a NEW token
                String newToken = UUID.randomUUID().toString();
                existingUser.setVerificationToken(newToken);
                userRepository.save(existingUser);

                // Use frontend-supplied base URL if provided, fallback to backend baseUrl
                String verificationBaseUrl = request.getVerificationBaseUrl();
                String link = ((verificationBaseUrl != null && !verificationBaseUrl.isEmpty())
                        ? verificationBaseUrl : baseUrl)
                        + "/api/auth/verify/" + newToken;

                emailService.sendVerificationEmail(existingUser.getEmail(), link);

                return ResponseEntity.ok(Collections.singletonMap("message",
                        "A new verification email has been sent! Please check your inbox."));
            } else {
                // User exists AND is verified
                return ResponseEntity.status(HttpStatus.CONFLICT)
                        .body(Collections.singletonMap("error",
                                "An account with this email already exists and is verified."));
            }
        }

        // 3. Normal registration flow for new users
        String verificationToken = UUID.randomUUID().toString();
        User user = new User();
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setName(request.getName());
        user.setRole(userRole); // use enum!
        user.setIsVerified(false);
        user.setVerificationToken(verificationToken);
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        userRepository.save(user);

        String verificationBaseUrl = request.getVerificationBaseUrl();
        String link = ((verificationBaseUrl != null && !verificationBaseUrl.isEmpty())
                ? verificationBaseUrl : baseUrl)
                + "/api/auth/verify/" + verificationToken;

        emailService.sendVerificationEmail(user.getEmail(), link);

        return ResponseEntity.ok(Collections.singletonMap("message",
                "Registration successful! Please check your email to verify your account."));
    }



    public Optional<User> validateUser(String email, String password, String role) {
        Optional<User> userOpt = userRepository.findByEmailAndRole(email, Role.fromString(role).name());
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (!passwordEncoder.matches(password, user.getPassword())) {
                return Optional.empty();
            }
            if (!Boolean.TRUE.equals(user.getIsVerified())) {
                throw new RuntimeException("Please verify your email before logging in.");
            }

            // Award First Login XP if first login
            if (user.getLastLogin() == null) {
                gamificationService.unlockAchievement(user.getId(), "First Login", 20);
            }

            // Update lastLogin timestamp
            user.setLastLogin(new Timestamp(System.currentTimeMillis()));
            userRepository.save(user);

            return Optional.of(user);
        }
        return Optional.empty();
    }


    // ✅ Logout
    public ResponseEntity<?> logout(/*HttpSession session*/) {
        // session.invalidate(); -> comment out for stateless section
        return ResponseEntity.ok(Collections.singletonMap("message", "Logged out successfully"));
    }

    public ResponseEntity<?> checkSession(String authHeader) {
        try {
            // Remove Bearer prefix if present
            String token = authHeader.replace("Bearer ", "").trim();

            if (!jwt.validateToken(token)) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Collections.singletonMap("error", "Invalid or expired token"));
            }

            String email = jwt.getUsername(token); // This extracts the subject (email)
            Role role = jwt.getRole(token);        // If you want to show the user's role

            // You can optionally return the user info
            return ResponseEntity.ok(Collections.singletonMap("email", email));
            // Or, just say it's valid:
            // return ResponseEntity.ok(Collections.singletonMap("message", "Token is valid"));

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Collections.singletonMap("error", "Invalid or expired token"));
        }
    }

    // ✅ Email verification (optional if implemented)
    public ResponseEntity<?> verifyToken(String token) {
        Optional<User> userOpt = userRepository.findByVerificationToken(token);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            user.setIsVerified(true);
            user.setVerificationToken(null); // Clear token so it can't be reused
            userRepository.save(user);
            gamificationService.unlockAchievement(user.getId(), "Verified Email", 10);
            return ResponseEntity.ok("Your email has been verified! You can now log in.");
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid or expired verification link.");
        }
    }

    public LoginResponse loginV2(LoginRequest req) {
    User user = users.findByEmail(req.getEmail())
            .orElseThrow(() -> new AuthenticationException("Invalid credentials"));

    System.out.println("Raw: " + req.getPassword());
    System.out.println("Hash: " + user.getPassword());
    System.out.println("Match: " + encoder.matches(req.getPassword(), user.getPassword()));
    if (!encoder.matches(req.getPassword(), user.getPassword()))
        throw new AuthenticationException("Invalid credentials");

    Long patientId = null;
    Long caregiverId = null;
    String name = null;

    switch (user.getRole()) {
        case PATIENT -> {
            Patient patient = patients.findByUser(user).orElse(null);
            if (patient != null) {
                patientId = patient.getId();
                name = patient.getFirstName() + " " + patient.getLastName();
            }
        }
        case CAREGIVER -> {
            Caregiver caregiver = caregivers.findByUser(user).orElse(null);
            if (caregiver != null) {
                caregiverId = caregiver.getId();
                name = caregiver.getFirstName() + " " + caregiver.getLastName();
            }
        }
        case FAMILY_MEMBER -> {
            // TODO: FAMILY_MEMBER
        }
        case ADMIN -> {
            // TODO: ADMIN
        }
    }

    return LoginResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .role(user.getRole())
            .token(jwt.createToken(user.getEmail(), user.getRole()))
            .patientId(patientId)
            .caregiverId(caregiverId)
            .name(name)
            .build();
    }
}
