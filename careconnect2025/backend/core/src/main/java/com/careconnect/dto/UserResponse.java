package com.careconnect.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@Builder
@NoArgsConstructor
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
