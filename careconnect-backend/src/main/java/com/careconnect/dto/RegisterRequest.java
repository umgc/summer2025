package com.careconnect.dto;

import lombok.Data;

@Data
public class RegisterRequest {
    private String name;
    private String email;
    private String password;
    private String role = "patient"; // default role
    private String verificationBaseUrl;
}
