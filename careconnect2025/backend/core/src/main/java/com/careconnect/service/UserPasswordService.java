package com.careconnect.service;

import com.careconnect.model.User;
import com.careconnect.model.PasswordResetToken;
import com.careconnect.repository.UserRepository;
import com.careconnect.repository.PasswordResetTokenRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.apache.commons.codec.digest.DigestUtils;
import java.time.Instant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class UserPasswordService {
    
    private static final Logger logger = LoggerFactory.getLogger(UserPasswordService.class);
    
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordResetTokenRepo passwordResetTokenRepo;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Reset password for user by username (email) and reset token
     * This method now handles BOTH verification tokens (from patient registration) 
     * AND password reset tokens for backward compatibility
     */
    // public void resetPasswordWithToken(String username, String resetToken, String newPassword) {
    //     logger.debug("🔧 Starting password reset for username: {}", username);
    //     logger.debug("🔧 Raw reset token received: {}", resetToken);
        
    //     // Find user by email
    //     User user = userRepository.findByEmail(username)
    //             .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
    //     logger.debug("🔧 User found: ID={}, Email={}, Role={}, Verified={}", 
    //             user.getId(), user.getEmail(), user.getRole(), user.getIsVerified());

    //     // FIRST: Check if this is a verification token (for new users from patient registration)
    //     if (user.getVerificationToken() != null && user.getVerificationToken().equals(resetToken)) {
    //         logger.debug("🔧 Token matches verification token - handling as password setup for new user");
            
    //         // This is a verification token from patient registration
    //         if (Boolean.TRUE.equals(user.getIsVerified())) {
    //             logger.error("❌ User already verified, cannot setup password again: {}", username);
    //             throw new IllegalArgumentException("Password already set up for this account");
    //         }
            
    //         // Set up password for new user
    //         String encodedPassword = passwordEncoder.encode(newPassword);
    //         user.setPassword(encodedPassword);
    //         user.setPasswordHash(encodedPassword);
    //         user.setIsVerified(true);
    //         user.setVerificationToken(null); // Clear verification token
    //         userRepository.save(user);
            
    //         logger.debug("🔧 Password setup completed successfully for new user: {}", username);
    //         return;
    //     }
        
    //     // SECOND: Handle as password reset token (existing flow)
    //     logger.debug("🔧 Not a verification token - handling as password reset token");
        
    //     // Hash the provided token to match against stored hash
    //     String tokenHash = DigestUtils.sha256Hex(resetToken);
    //     logger.debug("🔧 Hashed token: {}", tokenHash);
        
    //     Instant currentTime = Instant.now();
    //     logger.debug("🔧 Current time: {}", currentTime);
        
    //     // First, let's check if the token exists at all (without validation)
    //     passwordResetTokenRepo.findByTokenHash(tokenHash).ifPresentOrElse(
    //         token -> {
    //             logger.debug("🔧 Reset token found in database:");
    //             logger.debug("🔧   - Token ID: {}", token.getId());
    //             logger.debug("🔧   - User ID: {}", token.getUser().getId());
    //             logger.debug("🔧   - Expires at: {}", token.getExpiresAt());
    //             logger.debug("🔧   - Is used: {}", token.isUsed());
    //             logger.debug("🔧   - Time until expiry: {} seconds", 
    //                 java.time.Duration.between(currentTime, token.getExpiresAt()).getSeconds());
                
    //             if (token.getExpiresAt().isBefore(currentTime)) {
    //                 logger.error("❌ Reset token has expired! Expired at: {}, Current time: {}", 
    //                     token.getExpiresAt(), currentTime);
    //             }
    //             if (token.isUsed()) {
    //                 logger.error("❌ Reset token has already been used!");
    //             }
    //         },
    //         () -> {
    //             logger.error("❌ No reset token found with hash: {}", tokenHash);
    //             logger.debug("🔧 Looking for all reset tokens for user ID: {}", user.getId());
    //             passwordResetTokenRepo.findAll().forEach(t -> {
    //                 if (t.getUser().getId().equals(user.getId())) {
    //                     logger.debug("🔧 Found reset token for user: hash={}, expires={}, used={}", 
    //                         t.getTokenHash(), t.getExpiresAt(), t.isUsed());
    //                 }
    //             });
    //         }
    //     );

    //     // Find valid token in PasswordResetToken table
    //     PasswordResetToken passwordResetTokenEntity = passwordResetTokenRepo.findValid(tokenHash, currentTime)
    //             .orElseThrow(() -> new IllegalArgumentException("Invalid or expired reset token"));

    //     logger.debug("🔧 Valid reset token found, proceeding with password reset");

    //     // Verify the token belongs to this user
    //     if (!passwordResetTokenEntity.getUser().getId().equals(user.getId())) {
    //         logger.error("❌ Reset token belongs to user ID: {}, but reset requested for user ID: {}", 
    //             passwordResetTokenEntity.getUser().getId(), user.getId());
    //         throw new IllegalArgumentException("Reset token does not belong to this user");
    //     }

    //     // Update password
    //     String encodedPassword = passwordEncoder.encode(newPassword);
    //     user.setPassword(encodedPassword);
    //     user.setPasswordHash(encodedPassword);
    //     userRepository.save(user);
        
    //     logger.debug("🔧 Password updated successfully via reset token");

    //     // Mark token as used
    //     passwordResetTokenEntity.setUsed(true);
    //     passwordResetTokenRepo.save(passwordResetTokenEntity);
        
    //     logger.debug("🔧 Reset token marked as used, password reset complete");
    // }

/**
 * Reset password for user by username (email) and reset token
 * This method now handles BOTH verification tokens (from patient registration) 
 * AND password reset tokens for backward compatibility
 */
public void resetPasswordWithToken(String username, String resetToken, String newPassword) {
    logger.debug("🔧 Starting password reset for username: {}", username);
    logger.debug("🔧 Raw reset token received: {}", resetToken);
    
    // Find user by email
    User user = userRepository.findByEmail(username)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
    
    logger.debug("🔧 User found: ID={}, Email={}, Role={}, Verified={}", 
            user.getId(), user.getEmail(), user.getRole(), user.getIsVerified());

    // FIRST: Check if this is a verification token (for new users from patient registration)
    if (user.getVerificationToken() != null && user.getVerificationToken().equals(resetToken)) {
        logger.debug("🔧 Token matches verification token - handling as password setup for new user");
        
        // This is a verification token from patient registration
        if (Boolean.TRUE.equals(user.getIsVerified())) {
            logger.error("❌ User already verified, cannot setup password again: {}", username);
            throw new IllegalArgumentException("Password already set up for this account");
        }
        
        // Set up password for new user
        String encodedPassword = passwordEncoder.encode(newPassword);
        user.setPassword(encodedPassword);
        user.setPasswordHash(encodedPassword);
        user.setIsVerified(true);
        user.setVerificationToken(null); // Clear verification token
        userRepository.save(user);
        
        logger.debug("🔧 Password setup completed successfully for new user: {}", username);
        return;
    }
    
    // SIMPLIFIED FLOW: Try to decode the token as a base64-encoded user ID
    logger.debug("🔧 Attempting simplified token processing as base64-encoded user ID");
    
    try {
        // Try to decode the token as a base64-encoded user ID
        String decodedUserId = new String(java.util.Base64.getUrlDecoder().decode(resetToken));
        long tokenUserId = Long.parseLong(decodedUserId);
        
        // Verify the encoded user ID matches the requested user
        if (user.getId() == tokenUserId) {
            logger.debug("🔧 Reset token successfully decoded as user ID: {}", tokenUserId);
            
            // Update password
            String encodedPassword = passwordEncoder.encode(newPassword);
            user.setPassword(encodedPassword);
            user.setPasswordHash(encodedPassword);
            userRepository.save(user);
            
            logger.debug("🔧 Password updated successfully via simplified token flow");
            return;
        } else {
            logger.error("❌ Decoded user ID ({}) doesn't match requested user ID ({})", 
                tokenUserId, user.getId());
        }
    } catch (Exception e) {
        // If decoding fails, continue with the original token validation flow
        logger.debug("🔧 Not a base64-encoded user ID, continuing with traditional token validation");
    }
    
    // LEGACY FLOW: Handle as password reset token (existing flow)
    logger.debug("🔧 Handling as traditional password reset token");
    
    // Hash the provided token to match against stored hash
    String tokenHash = DigestUtils.sha256Hex(resetToken);
    logger.debug("🔧 Hashed token: {}", tokenHash);
    
    Instant currentTime = Instant.now();
    logger.debug("🔧 Current time: {}", currentTime);
    
    // First, let's check if the token exists at all (without validation)
    passwordResetTokenRepo.findByTokenHash(tokenHash).ifPresentOrElse(
        token -> {
            logger.debug("🔧 Reset token found in database:");
            logger.debug("🔧   - Token ID: {}", token.getId());
            logger.debug("🔧   - User ID: {}", token.getUser().getId());
            logger.debug("🔧   - Expires at: {}", token.getExpiresAt());
            logger.debug("🔧   - Is used: {}", token.isUsed());
            logger.debug("🔧   - Time until expiry: {} seconds", 
                java.time.Duration.between(currentTime, token.getExpiresAt()).getSeconds());
            
            if (token.getExpiresAt().isBefore(currentTime)) {
                logger.error("❌ Reset token has expired! Expired at: {}, Current time: {}", 
                    token.getExpiresAt(), currentTime);
            }
            if (token.isUsed()) {
                logger.error("❌ Reset token has already been used!");
            }
        },
        () -> {
            logger.error("❌ No reset token found with hash: {}", tokenHash);
            logger.debug("🔧 Looking for all reset tokens for user ID: {}", user.getId());
            passwordResetTokenRepo.findAll().forEach(t -> {
                if (t.getUser().getId().equals(user.getId())) {
                    logger.debug("🔧 Found reset token for user: hash={}, expires={}, used={}", 
                        t.getTokenHash(), t.getExpiresAt(), t.isUsed());
                }
            });
        }
    );

    // Find valid token in PasswordResetToken table
    PasswordResetToken passwordResetTokenEntity = passwordResetTokenRepo.findValid(tokenHash, currentTime)
            .orElseThrow(() -> new IllegalArgumentException("Invalid or expired reset token"));

    logger.debug("🔧 Valid reset token found, proceeding with password reset");

    // Verify the token belongs to this user
    if (!passwordResetTokenEntity.getUser().getId().equals(user.getId())) {
        logger.error("❌ Reset token belongs to user ID: {}, but reset requested for user ID: {}", 
            passwordResetTokenEntity.getUser().getId(), user.getId());
        throw new IllegalArgumentException("Reset token does not belong to this user");
    }

    // Update password
    String encodedPassword = passwordEncoder.encode(newPassword);
    user.setPassword(encodedPassword);
    user.setPasswordHash(encodedPassword);
    userRepository.save(user);
    
    logger.debug("🔧 Password updated successfully via reset token");

    // Mark token as used
    passwordResetTokenEntity.setUsed(true);
    passwordResetTokenRepo.save(passwordResetTokenEntity);
    
    logger.debug("🔧 Reset token marked as used, password reset complete");
}
    /**
     * Set up password for new users using verification token (from patient registration)
     */
    public void setupPasswordWithVerificationToken(String username, String verificationToken, String newPassword) {
        logger.debug("🔧 Setting up password for user: {}", username);
        logger.debug("🔧 Verification token: {}", verificationToken);
        
        // Find user by email
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> {
                    logger.error("❌ User not found: {}", username);
                    return new RuntimeException("User not found");
                });
        
        logger.debug("🔧 Found user: id={}, role={}, verified={}", user.getId(), user.getRole(), user.getIsVerified());
        
        // Check if verification token matches
        if (user.getVerificationToken() == null || !user.getVerificationToken().equals(verificationToken)) {
            logger.error("❌ Invalid verification token for user: {}", username);
            throw new RuntimeException("Invalid verification token");
        }
        
        // Check if user is already verified (password already set)
        if (Boolean.TRUE.equals(user.getIsVerified())) {
            logger.error("❌ User already verified, cannot setup password again: {}", username);
            throw new RuntimeException("Password already set up for this account");
        }
        
        // Encode and set new password
        String encodedPassword = passwordEncoder.encode(newPassword);
        user.setPassword(encodedPassword);
        user.setPasswordHash(encodedPassword);
        
        // Mark user as verified and clear verification token
        user.setIsVerified(true);
        user.setVerificationToken(null);
        
        // Save user
        userRepository.save(user);
        
        logger.debug("🔧 Password setup completed successfully for user: {}", username);
    }
}
