package com.careconnect.security.service;


import java.util.UUID;

public class TokenProvider {
    public String generateToken() {
        return UUID.randomUUID().toString();  
    }
}
