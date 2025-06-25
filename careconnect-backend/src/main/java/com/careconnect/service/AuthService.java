package com.careconnect.service;

import com.careconnect.dto.RegisterRequest;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.util.Collections;
import java.util.Optional;
import java.util.UUID;

@Service
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    // ✅ Register new user
    public ResponseEntity<?> register(RegisterRequest request) {
        if (userRepository.findByEmailAndRole(request.getEmail(), request.getRole()).isPresent()) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("error", "Email already registered."));
        }

        User user = new User();
        user.setName(request.getName());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole());
        user.setCreatedAt(new Timestamp(System.currentTimeMillis()));
        user.setIsVerified(false);
        user.setVerificationToken(UUID.randomUUID().toString());

        userRepository.save(user);
        return ResponseEntity.status(201).body(user);
    }

    // ✅ Validate user for login
    public Optional<User> validateUser(String email, String password, String role) {
        Optional<User> userOpt = userRepository.findByEmailAndRole(email, role);

        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (passwordEncoder.matches(password, user.getPassword())) {
                // Update last login time
                user.setLastLogin(new Timestamp(System.currentTimeMillis()));
                userRepository.save(user);
                return Optional.of(user);
            }
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
            user.setVerificationToken(null);
            userRepository.save(user);
            return ResponseEntity.ok(Collections.singletonMap("message", "Email verified"));
        } else {
            return ResponseEntity.status(400).body(Collections.singletonMap("error", "Invalid or expired token"));
        }
    }
}
