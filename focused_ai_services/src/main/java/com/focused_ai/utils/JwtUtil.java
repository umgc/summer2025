package com.focused_ai.utils;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.SecretKey;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.impl.lang.Function;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtUtil {
    
    @Value("${jwt.secret}")
    private String jwtSecret;

    private long expirationMs = 3600000;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(this.jwtSecret.getBytes());
    }

    // --- Token Generation ---
    public String generateToken(String lms, String userId, String userIdentifier, String userRole) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("lms", lms);
        claims.put("identifier", userIdentifier); //username if Moodle, user email if Google
        claims.put("role", userRole);
        return createToken(claims, userId);
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
            .claims(claims)
            .subject(subject) // User ID
            .issuedAt(new Date(System.currentTimeMillis()))
            .expiration(new Date(System.currentTimeMillis() + expirationMs))
            .signWith(getSigningKey(), Jwts.SIG.HS256) // Use HS256 for symmetric key
            .compact();
    }

    // --- Token Validation & Extraction ---
    public Boolean validateToken(String token) {
        try {
            Jwts.parser() // Use Jwts.parser() directly
                .verifyWith(getSigningKey()) // Still setSigningKey here for parser
                .build()
                .parseSignedClaims(token);
            return true; // Token is valid and not expired
        } catch (Exception e) {
            System.err.println("JWT Validation Error: " + e.getMessage());
            return false; // Token is invalid or expired
        }
    }

    public Claims extractAllClaims(String token) {
        return Jwts.parser()
            .verifyWith(getSigningKey())
            .build()
            .parseSignedClaims(token)
            .getPayload();
    }

    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    public String extractUserId(String token) {
        return extractClaim(token, Claims::getSubject);
    }

    public String extractLMS(String token) {
        return extractClaim(token, claims -> claims.get("lms", String.class));
    }

    public String extractUserIdentifier(String token) {
        return extractClaim(token, claims -> claims.get("identifier", String.class));
    }

    public String extractUserRole(String token) {
        return extractClaim(token, claims -> claims.get("role", String.class));
    }

    public Boolean isTokenExpired(String token) {
        return extractClaim(token, Claims::getExpiration).before(new Date());
    }
}
