package com.focused_ai.utils;

import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import java.util.function.Function;
import io.jsonwebtoken.security.Keys;

@Component
public class JwtUtil {
    
    @Value("${JWT_SECRET}")
    private String jwtSecret;
    
    @Value("${ENCRYPTION_KEY}")
    private String encryptionKey; // Must be 32 characters for AES-256

    private long expirationMs = 3600000;

    private SecretKey getSigningKey() {
        return Keys.hmacShaKeyFor(this.jwtSecret.getBytes());
    }

    // --- Encryption/Decryption ---
    private String encrypt(String data) {
        if (data == null) return null;
        try {
            Cipher cipher = Cipher.getInstance("AES");
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(), "AES");
            cipher.init(Cipher.ENCRYPT_MODE, keySpec);
            return Base64.getEncoder().encodeToString(cipher.doFinal(data.getBytes()));
        } catch (Exception e) {
            throw new RuntimeException("Encryption failed", e);
        }
    }
    
    private String decrypt(String encryptedData) {
        if (encryptedData == null) return null;
        try {
            Cipher cipher = Cipher.getInstance("AES");
            SecretKeySpec keySpec = new SecretKeySpec(encryptionKey.getBytes(), "AES");
            cipher.init(Cipher.DECRYPT_MODE, keySpec);
            return new String(cipher.doFinal(Base64.getDecoder().decode(encryptedData)));
        } catch (Exception e) {
            throw new RuntimeException("Decryption failed", e);
        }
    }

    // --- Token Generation for Google Users ---
    public String generateGoogleToken(String userId, String userEmail, String userRole, 
                                     String googleAccessToken, String googleRefreshToken, Long googleTokenExpiry) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("lms", "googleClassroom");
        claims.put("identifier", encrypt(userEmail)); // Encrypted email
        claims.put("role", userRole);
        
        // Google-specific encrypted session data only
        claims.put("googleAccessToken", encrypt(googleAccessToken));
        claims.put("googleRefreshToken", encrypt(googleRefreshToken));
        claims.put("googleTokenExpiry", googleTokenExpiry);
        
        return createToken(claims, userId);
    }

    // --- Token Generation for Moodle Users ---
    public String generateMoodleToken(String userId, String username, String userRole, 
                                     String moodleDomain, String webServiceToken) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("lms", "moodle");
        claims.put("identifier", encrypt(username)); // Encrypted username
        claims.put("role", userRole);
        
        // Moodle-specific encrypted session data only
        claims.put("moodleDomain", encrypt(moodleDomain));
        claims.put("webServiceToken", encrypt(webServiceToken));
        
        return createToken(claims, userId);
    }

    private String createToken(Map<String, Object> claims, String subject) {
        return Jwts.builder()
            .claims(claims)
            .subject(subject) // User ID (not encrypted - used for JWT subject)
            .issuedAt(new Date(System.currentTimeMillis()))
            .expiration(new Date(System.currentTimeMillis() + expirationMs))
            .signWith(getSigningKey(), Jwts.SIG.HS256)
            .compact();
    }

    // --- Token Validation & Extraction ---
    public Boolean validateToken(String token) {
        try {
            Jwts.parser()
                .verifyWith(getSigningKey())
                .build()
                .parseSignedClaims(token);
            return true;
        } catch (Exception e) {
            System.err.println("JWT Validation Error: " + e.getMessage());
            return false;
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
        String encryptedIdentifier = extractClaim(token, claims -> claims.get("identifier", String.class));
        return decrypt(encryptedIdentifier); // Decrypt before returning
    }

    public String extractUserRole(String token) {
        return extractClaim(token, claims -> claims.get("role", String.class));
    }

    public Boolean isTokenExpired(String token) {
        return extractClaim(token, Claims::getExpiration).before(new Date());
    }

    // --- Google Session Data Extraction ---
    public String extractGoogleAccessToken(String token) {
        String encryptedToken = extractClaim(token, claims -> claims.get("googleAccessToken", String.class));
        return decrypt(encryptedToken);
    }

    public String extractGoogleRefreshToken(String token) {
        String encryptedToken = extractClaim(token, claims -> claims.get("googleRefreshToken", String.class));
        return decrypt(encryptedToken);
    }

    public Long extractGoogleTokenExpiry(String token) {
        return extractClaim(token, claims -> claims.get("googleTokenExpiry", Long.class));
    }

    public boolean isGoogleTokenExpired(String token) {
        Long expiry = extractGoogleTokenExpiry(token);
        return expiry != null && System.currentTimeMillis() > expiry;
    }

    // --- Moodle Session Data Extraction ---
    public String extractMoodleDomain(String token) {
        String encryptedDomain = extractClaim(token, claims -> claims.get("moodleDomain", String.class));
        return decrypt(encryptedDomain);
    }

    public String extractwebServiceToken(String token) {
        String encryptedWebServiceToken = extractClaim(token, claims -> claims.get("webServiceToken", String.class));
        return decrypt(encryptedWebServiceToken);
    }

    // --- User Type Check ---
    public boolean isGoogleUser(String token) {
        return "googleClassroom".equals(extractLMS(token));
    }

    public boolean isMoodleUser(String token) {
        return "moodle".equals(extractLMS(token));
    }
}