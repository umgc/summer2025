package com.focused_ai.utils;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtils;

    public JwtAuthFilter(JwtUtil jwtUtils) {
        this.jwtUtils = jwtUtils;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain)
            throws ServletException, IOException {
        System.out.println("=== ENTERING JwtAuthFilter ===");
        System.out.println("Request URI: " + request.getRequestURI());
        System.out.println("Servlet Path: " + request.getServletPath());
        System.out.println("Method: " + request.getMethod());

        // Skip auth for public endpoints
        if (request.getRequestURI().startsWith("/auth") || request.getRequestURI().startsWith("/test") ||
                HttpMethod.OPTIONS.name().equals(request.getMethod())) {
            System.out.println("Skipping auth - public endpoint, continuing to controller");
            filterChain.doFilter(request, response);
            System.out.println("Returned from controller");
            return;
        }

        System.out.println("Auth required - checking JWT");

        // Get token from header
        String authHeader = request.getHeader("Authorization");
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            sendError(response, "Missing/invalid Authorization header");
            return;
        }

        System.out.println("Auth header: " + authHeader);

        // Validate token
        String jwt = authHeader.substring(7);
        if (!jwtUtils.validateToken(jwt)) {
            sendError(response, "Invalid/expired token");
            return;
        }

        System.out.println("JWT validated successfully");

        // Extract user information from token
        try {
            String userId = jwtUtils.extractUserId(jwt);
            String userRole = jwtUtils.extractUserRole(jwt);
            String userIdentifier = jwtUtils.extractUserIdentifier(jwt);
            String userLms = jwtUtils.extractLMS(jwt);

            System.out.println("User ID: " + userId);
            System.out.println("User Role: " + userRole);
            System.out.println("User Identifier: " + userIdentifier);
            System.out.println("User Identifier: " + userLms);

            // Create authentication token
            UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                    userId, // principal
                    null, // credentials (no password needed for JWT)
                    Collections.singletonList(new SimpleGrantedAuthority("ROLE_" + userRole)));

            // Set additional details if needed
            authToken.setDetails(userIdentifier);

            // Set authentication in security context
            SecurityContextHolder.getContext().setAuthentication(authToken);
            System.out.println("Authentication set in security context");

        } catch (Exception e) {
            System.err.println("Error extracting user info from JWT: " + e.getMessage());
            sendError(response, "Invalid token format");
            return;
        }

        // Token is valid and authentication is set - proceed
        filterChain.doFilter(request, response);
    }

    private void sendError(HttpServletResponse response, String message)
            throws IOException {
        // Add CORS headers to error responses
        response.setHeader("Access-Control-Allow-Origin", "http://localhost:3000");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "*");

        response.setContentType("application/json");
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.getWriter().write(
                "{\"error\": \"" + message + "\"}");
    }
}