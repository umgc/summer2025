package com.careconnect.controller;

import com.careconnect.dto.LoginRequest;
import com.careconnect.dto.RegisterRequest;
import com.careconnect.dto.UserResponse;
import com.careconnect.model.User;
import com.careconnect.service.AuthService;
import jakarta.servlet.http.Cookie;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(originPatterns = {
        "http://localhost:3000",
        "http://10.0.2.2:8080",
        "http://localhost:8080"
}, allowCredentials = "true")
public class AuthController {

    @Autowired
    private AuthService authService;

    // Register new user
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(
            @RequestBody LoginRequest request,
            HttpSession session,
            HttpServletRequest httpRequest,
            HttpServletResponse response
    ) {
        Optional<User> userOpt = authService.validateUser(request.getEmail(), request.getPassword(), request.getRole());

        if (userOpt.isPresent()) {
            User user = userOpt.get();

            // Store user ID in session
            session.setAttribute("userId", user.getId());

            System.out.println("[AuthController] Login successful");
            System.out.println("[AuthController] Session ID: " + session.getId());
            System.out.println("[AuthController] Stored userId: " + session.getAttribute("userId"));

            // DEBUG
            Cookie[] cookies = httpRequest.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    System.out.println("Incoming Cookie: " + cookie.getName() + " = " + cookie.getValue());
                }
            }

            return ResponseEntity.ok(user); // Return the full user
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Collections.singletonMap("error", "Invalid credentials"));
        }
    }


    // Logout
    @PostMapping("/logout")
    public ResponseEntity<?> logout(HttpSession session) {
        return authService.logout(session);
    }

    // Check session
    @GetMapping("/check")
    public ResponseEntity<?> checkSession(HttpSession session) {
        return authService.checkSession(session);
    }

    // Email Verification Endpoint
    @GetMapping("/verify/{token}")
    public ResponseEntity<?> verify(@PathVariable String token) {
        return authService.verifyToken(token);
    }


}
