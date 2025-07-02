package com.careconnect.controller.v1;

import com.careconnect.dto.v1.LoginRequest;
import com.careconnect.dto.v1.RegisterRequest;
import com.careconnect.model.v1.User;
import com.careconnect.service.v1.AuthService;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.context.annotation.Profile;

import java.util.Collections;
import java.util.Optional;

@Profile("v1")
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(originPatterns = {
        "http://localhost:3000", // avoid these hardcoded logics
        "http://10.0.2.2:8080",
        "http://localhost:8080"
}, allowCredentials = "true")
public class AuthController {

    @Autowired
    private AuthService authService;

    // --- Register new user ---
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        // Delegate to AuthService for registration & verification logic
        return authService.register(request);
    }

    // --- Login user ---
    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest request,
            HttpSession session,
            HttpServletRequest httpRequest,
            HttpServletResponse response
    ) {
        try {
            Optional<User> userOpt = authService.validateUser(request.getEmail(), request.getPassword(), request.getRole());
            if (userOpt.isPresent()) {
                User user = userOpt.get();
                session.setAttribute("userId", user.getId());

                System.out.println("[AuthController] Login successful");
                System.out.println("[AuthController] Session ID: " + session.getId());
                System.out.println("[AuthController] Stored userId: " + session.getAttribute("userId"));

                // DEBUG: Print cookies
                Cookie[] cookies = httpRequest.getCookies();
                if (cookies != null) {
                    for (Cookie cookie : cookies) {
                        System.out.println("Incoming Cookie: " + cookie.getName() + " = " + cookie.getValue());
                    }
                }

                return ResponseEntity.ok(user); // Return user (optionally use a DTO for privacy)
            } else {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(Collections.singletonMap("error", "Invalid credentials"));
            }
        } catch (RuntimeException e) {
            // Handle "not verified" or other custom errors
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Collections.singletonMap("error", e.getMessage()));
        }
    }

    // --- Logout ---
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpSession session) {
        return authService.logout(session);
    }

    // --- Check session ---
    @GetMapping("/check")
    public ResponseEntity<?> checkSession(HttpSession session) {
        return authService.checkSession(session);
    }

    // --- Email verification ---
    @GetMapping("/verify/{token}")
    public ResponseEntity<?> verify(@PathVariable String token) {
        return authService.verifyToken(token);
    }
}
