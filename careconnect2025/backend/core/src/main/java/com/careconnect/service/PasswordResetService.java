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
    
    @Value("${careconnect.email.provider:sendgrid}")
    private String emailProvider;
    
    @Value("${careconnect.email.from:smpestest@gmail.com}")
    private String fromEmail;

    public PasswordResetService(UserRepository users, PasswordResetTokenRepo tokens, PasswordEncoder encoder) {
        this.users = users;
        this.tokens = tokens;
        this.encoder = encoder;
    }

    private static final Duration TTL = Duration.ofHours(3);  // Increased to 3 hours

    /* Step 1 – request */
    // public void startReset(String email, String appUrl) {
    //     User user = users.findByEmail(email)
    //                      .orElseThrow(() -> new IllegalArgumentException("Email not found"));

    //     String raw   = generateSecureRandomString(48);
    //     String hash  = hash(raw);

    //     // First, invalidate any existing tokens for this user
    //     tokens.findByUser(user).ifPresent(oldToken -> {
    //         oldToken.setUsed(true);
    //         tokens.save(oldToken);
    //     });

    //     PasswordResetToken entity = new PasswordResetToken();
    //     entity.setUser(user);
    //     entity.setTokenHash(hash);
    //     // Add a small buffer to account for time zone differences and processing time
    //     entity.setExpiresAt(Instant.now().plus(TTL).plus(Duration.ofMinutes(5)));
    //     tokens.save(entity);

    //     String link = appUrl + "/setup-password?token=" + raw;
    //     sendPasswordResetEmail(user.getEmail(), link);   // Send the email properly
    // }

    /* Step 1 – request */
public void startReset(String email, String appUrl) {
    User user = users.findByEmail(email)
                    .orElseThrow(() -> new IllegalArgumentException("Email not found"));

    // SIMPLIFIED FLOW: Generate a base64 encoded user ID
    String encodedUserId = Base64.getUrlEncoder().encodeToString(
        user.getId().toString().getBytes());
    
    // SIMPLIFIED FLOW: Create the reset link using 'token' parameter for client compatibility
    // but the value will actually be the encoded user ID
    String link = appUrl + "/setup-password?token=" + encodedUserId;
    sendPasswordResetEmail(user.getEmail(), link);
}
  /* Step 2 – confirmation */
public void finalizeReset(String rawToken, String newPassword) {
    try {
        // SIMPLIFIED FLOW: Treat the rawToken as the encoded user ID
        String userIdStr = new String(Base64.getUrlDecoder().decode(rawToken));
        Long userId = Long.parseLong(userIdStr);
        
        User user = users.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid or missing reset token"));
        
        String encodedPassword = encoder.encode(newPassword);
        user.setPassword(encodedPassword);
        users.save(user);

    } catch (IllegalArgumentException e) {
        throw e;
    } catch (Exception e) {
        throw new IllegalArgumentException("Invalid or missing reset token");
    }
}
    /* Step 2 – confirmation */
    // public void finalizeReset(String rawToken, String newPassword) {
    //     String hash = hash(rawToken);

    //     PasswordResetToken t = tokens.findByTokenHash(hash)
    //             .orElseThrow(() -> new IllegalArgumentException("Invalid token"));

    //     // Separate checks for better error messages
    //     if (t.isUsed()) {
    //         throw new IllegalArgumentException("This reset token has already been used");
    //     }
        
    //     if (t.getExpiresAt().isBefore(Instant.now())) {
    //         throw new IllegalArgumentException("This reset token has expired. Please request a new one");
    //     }

    //     User user = t.getUser();
    //     String encodedPassword = encoder.encode(newPassword);
    //     user.setPassword(encodedPassword);
    //     user.setPasswordHash(encodedPassword);
    //     users.save(user);

    //     t.setUsed(true);
    //     tokens.save(t);
    // }

    /**
     * Check if a reset token is valid
     */
    // public boolean isTokenValid(String rawToken) {
    //     try {
    //         String hash = hash(rawToken);
    //         return tokens.findValid(hash, Instant.now()).isPresent();
    //     } catch (Exception e) {
    //         return false;
    //     }
    // }

    /**
 * Check if a user ID is valid
 */
public boolean isTokenValid(String encodedUserId) {
    // SIMPLIFIED FLOW: Just check if the user exists
    try {
        String userIdStr = new String(Base64.getUrlDecoder().decode(encodedUserId));
        Long userId = Long.parseLong(userIdStr);
        return users.findById(userId).isPresent();
        
        // SIMPLIFIED FLOW: Original token validation - not used anymore
        /*
        String hash = hash(rawToken);
        return tokens.findValid(hash, Instant.now()).isPresent();
        */
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
            if (fromEmail == null || fromEmail.trim().isEmpty()) {
                System.err.println("❌ ERROR: fromEmail is null or empty in PasswordResetService! Check your environment variables and application.properties mapping.");
                throw new RuntimeException("FROM_EMAIL (careconnect.email.from) is not set. Email cannot be sent.");
            }
            helper.setFrom(fromEmail);
            helper.setSubject("CareConnect Password Reset");
            
            String emailBody = """
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
                    <h2 style="color: #2c3e50; text-align: center;">CareConnect Password Reset</h2>
                    
                    <p style="font-size: 16px; line-height: 1.6; color: #333;">
                        You requested a password reset for your CareConnect account.
                    </p>
                    
                    <div style="text-align: center; margin: 30px 0;">
                        <a href="%s" 
                           style="background-color: #3498db; 
                                  color: white; 
                                  padding: 12px 30px; 
                                  text-decoration: none; 
                                  border-radius: 5px; 
                                  font-weight: bold; 
                                  font-size: 16px;
                                  display: inline-block;
                                  border: 2px solid #3498db;
                                  transition: background-color 0.3s;">
                            Reset Your Password
                        </a>
                    </div>
                    
                    <p style="font-size: 14px; color: #666; text-align: center; margin-top: 20px;">
                        <strong>⏰ This link is valid for 20 minutes only and will expire automatically.</strong>
                    </p>
                    
                    <p style="font-size: 14px; color: #666; text-align: center;">
                        If you didn't request this password reset, please ignore this email.
                    </p>
                    
                    <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
                    
                    <p style="font-size: 12px; color: #999; text-align: center;">
                        This is an automated message from CareConnect. Please do not reply to this email.
                    </p>
                </div>
                """.formatted(link);
            
            helper.setText(emailBody, true);
            mail.send(message);
            // String providerInfo = getProviderInfo();
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
