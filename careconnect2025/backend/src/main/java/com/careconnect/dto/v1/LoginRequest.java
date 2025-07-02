package com.careconnect.dto.v1;

import lombok.Data;

@Data
public class LoginRequest {
    private String email;
    private String password;
    private String role;
}
