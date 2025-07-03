package com.careconnect.util;

import com.careconnect.security.JwtTokenProvider;
import com.careconnect.security.Role;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class SecurityUtil {

    private final JwtTokenProvider jwtTokenProvider;

    @Autowired
    public SecurityUtil(JwtTokenProvider jwtTokenProvider) {
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public UserInfo getCurrentUser(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            throw new RuntimeException("Missing or invalid Authorization header");
        }
        String token = header.substring(7);
        String email = jwtTokenProvider.getUsername(token);
        Role role = jwtTokenProvider.getRole(token);
        return new UserInfo(email, role);
    }

    public static class UserInfo {
        public final String email;
        public final Role role;
        public UserInfo(String email, Role role) {
            this.email = email;
            this.role = role;
        }
    }
}