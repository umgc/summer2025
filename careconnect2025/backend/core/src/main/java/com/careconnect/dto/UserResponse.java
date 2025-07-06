package com.careconnect.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class UserResponse {
    private Long id;
    private String name;
    private String email;
    private com.careconnect.security.Role role;
    private boolean emailVerified;
    private String profileImageUrl;
    private String status;
}
