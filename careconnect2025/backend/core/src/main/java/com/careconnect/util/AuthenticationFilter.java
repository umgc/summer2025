package com.careconnect.util;

import java.io.IOException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import com.careconnect.dto.LoginRequest;
import com.careconnect.dto.LoginResponse;
import com.careconnect.exception.AuthenticationException;
import com.careconnect.security.JwtTokenProvider;
import com.careconnect.security.service.AuthService;
import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;


@Component
public class AuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private AuthService authService;
    
    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        filterChain.doFilter(request, response); 
    }

    // protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
    //     String uri = request.getRequestURI();

    //     if (uri.startsWith("/v1/api/auth")) {
    //         if (uri.equals("/v1/api/auth/login") && request.getMethod().equalsIgnoreCase("POST")) {
    //             filterChain.doFilter(request, response);
    //             return;
    //         }
    //     }

    //     String token = request.getHeader("Authorization");
    //     if (token == null || !isValidToken(token)) {
    //         response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired token");
    //         return;
    //     }
        
    //     filterChain.doFilter(request, response);
    // }

    private boolean isValidToken(String token) {
        try {
            return jwtTokenProvider.validateToken(token);
        } catch (Exception e) {
            return false;
        }
    }
}
