package com.deeptrain.service;

import org.springframework.stereotype.Service;

@Service
public class AuthService {

    public String authenticate(String email, String password) {
        // Normally you'd validate against a database and generate a JWT
        //if ("user@example.com".equals(email) && "password123".equals(password)) {
        if ("user@example.com".equals(email) && "password123".equals(password)) {
            return "fake-jwt-token"; // TODO: Replace with real token generation
        }
        throw new RuntimeException("Invalid credentials");
    }
}

