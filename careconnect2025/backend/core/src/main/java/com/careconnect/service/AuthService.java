package com.careconnect.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder; // Make sure you have spring-boot-starter-security or similar
import org.springframework.stereotype.Service;

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
    private UserRepository userRepository;

    @Autowired
    private EmailService emailService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Value("${careconnect.baseurl:http://localhost:8080}")
    private String baseUrl; // configurable via application.properties

    public ResponseEntity<?> register(RegisterRequest request) {
        // 1. Lookup existing user by email & role
        Optional<User> existingUserOpt = userRepository.findByEmailAndRole(request.getEmail(), request.getRole());

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
        user.setRole(Role.valueOf(request.getRole().toUpperCase()));
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

    // ✅ Validate user for login
    public Optional<User> validateUser(String email, String password, String role) {
        Optional<User> userOpt = userRepository.findByEmailAndRole(email, role);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            // Check password
            if (!passwordEncoder.matches(password, user.getPassword())) {
                return Optional.empty();
            }
            // Check email verification
            if (!Boolean.TRUE.equals(user.getIsVerified())) {
                // Instead of returning empty, you could throw to signal "not verified"
                throw new RuntimeException("Please verify your email before logging in.");
            }
            return Optional.of(user);
        }
        return Optional.empty();
    }


    // ✅ Logout
    public ResponseEntity<?> logout(HttpSession session) {
        session.invalidate();
        return ResponseEntity.ok(Collections.singletonMap("message", "Logged out successfully"));
    }

    // ✅ Check if user session is valid
    public ResponseEntity<?> checkSession(HttpSession session) {
        Object userId = session.getAttribute("userId");
        if (userId != null) {
            return ResponseEntity.ok(Collections.singletonMap("userId", userId));
        } else {
            return ResponseEntity.status(401).body(Collections.singletonMap("error", "Not logged in"));
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
            return ResponseEntity.ok("Your email has been verified! You can now log in.");
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid or expired verification link.");
        }
    }
}
