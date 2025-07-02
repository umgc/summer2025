package com.careconnect.service.v2;


import java.util.UUID;

public class TokenProvider {
    public String generateToken() {
        return UUID.randomUUID().toString();  
    }
}
