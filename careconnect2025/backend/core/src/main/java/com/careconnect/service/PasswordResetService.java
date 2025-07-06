package com.careconnect.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import java.time.Duration;
import java.time.Instant;
import java.util.Base64;
import java.security.SecureRandom;
import org.apache.commons.codec.digest.DigestUtils;
import jakarta.mail.internet.MimeMessage;

import com.careconnect.model.User;
import com.careconnect.model.PasswordResetToken;
import com.careconnect.repository.UserRepository;
import com.careconnect.repository.PasswordResetTokenRepo;

@Service
public class PasswordResetService {

    private final UserRepository users;
    private final PasswordResetTokenRepo tokens;
    private final PasswordEncoder encoder;
    
    @Autowired(required = false)
    private JavaMailSender mail;
    
    @Value("${careconnect.email.provider:mailtrap}")
    private String emailProvider;
    
    public PasswordResetService(UserRepository users, PasswordResetTokenRepo tokens, PasswordEncoder encoder) {
        this.users = users;
        this.tokens = tokens;
        this.encoder = encoder;
    }

    private static final Duration TTL = Duration.ofHours(2);

    /* Step 1 – request */
    public void startReset(String email, String appUrl) {
        User user = users.findByEmail(email)
                         .orElseThrow(() -> new IllegalArgumentException("Email not found"));

        String raw   = generateSecureRandomString(48);
        String hash  = hash(raw);

        PasswordResetToken entity = new PasswordResetToken();
        entity.setUser(user);
        entity.setTokenHash(hash);
        entity.setExpiresAt(Instant.now().plus(TTL));
        tokens.save(entity);

        String link = appUrl + "/reset?token=" + raw;
        sendPasswordResetEmail(user.getEmail(), link);   // Send the email properly
    }

    /* Step 2 – confirmation */
    public void finalizeReset(String rawToken, String newPassword) {
        String hash = hash(rawToken);

        PasswordResetToken t = tokens.findValid(hash, Instant.now())
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired token"));

        User user = t.getUser();
        String encodedPassword = encoder.encode(newPassword);
        user.setPassword(encodedPassword);
        user.setPasswordHash(encodedPassword);
        users.save(user);

        t.setUsed(true);
        tokens.save(t);                         // or delete
    }

    /**
     * Check if a reset token is valid
     */
    public boolean isTokenValid(String rawToken) {
        try {
            String hash = hash(rawToken);
            return tokens.findValid(hash, Instant.now()).isPresent();
        } catch (Exception e) {
            return false;
        }
    }

    /* ---------- helpers ------------------------------------------------ */
    private String generateSecureRandomString(int len) {
        byte[] bytes = new byte[len];
        new SecureRandom().nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }
    
    private String hash(String raw) {
        return DigestUtils.sha256Hex(raw);      // Apache commons-codec
    }
    
    private void sendPasswordResetEmail(String to, String link) {
        if ("console".equals(emailProvider) || mail == null) {
            // Console mode disabled - password reset would be logged here
            // System.out.println("🔧 CONSOLE MODE - Password reset email logged to console:");
            // System.out.println("  To: " + to);
            // System.out.println("  Subject: CareConnect Password Reset");
            // System.out.println("  Reset Link: " + link);
            // System.out.println("  ===================================");
            return;
        }
        
        try {
            MimeMessage message = mail.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);
            helper.setTo(to);
            helper.setSubject("CareConnect Password Reset");
            helper.setText("<p>You requested a password reset.</p>" +
                    "<p>Click <a href='" + link + "'>here</a> to reset your password. This link will expire in 2 hours.</p>", true);
            
            mail.send(message);
            String providerInfo = getProviderInfo();
            // System.out.println("✅ Password reset email sent via " + providerInfo + " to " + to);
        } catch (Exception e) {
            System.err.println("❌ Failed to send password reset email to " + to + ": " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("Failed to send password reset email", e);
        }
    }
    
    private String getProviderInfo() {
        switch (emailProvider.toLowerCase()) {
            case "mailtrap":
                return "Mailtrap (Development)";
            case "sendgrid":
                return "SendGrid (Production)";
            case "gmail":
                return "Gmail (Production)";
            case "console":
                return "Console (Testing)";
            default:
                return emailProvider;
        }
    }
}
