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

@Service
public class UserPasswordService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordResetTokenRepo passwordResetTokenRepo;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Reset password for user by username (email) and reset token
     * Uses the dedicated PasswordResetToken table for validation
     */
    public void resetPasswordWithToken(String username, String resetToken, String newPassword) {
        // Find user by email
        User user = userRepository.findByEmail(username)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        // Hash the provided token to match against stored hash
        String tokenHash = DigestUtils.sha256Hex(resetToken);

        // Find valid token in PasswordResetToken table
        PasswordResetToken passwordResetTokenEntity = passwordResetTokenRepo.findValid(tokenHash, Instant.now())
                .orElseThrow(() -> new IllegalArgumentException("Invalid or expired reset token"));

        // Verify the token belongs to this user
        if (!passwordResetTokenEntity.getUser().getId().equals(user.getId())) {
            throw new IllegalArgumentException("Reset token does not belong to this user");
        }

        // Update password
        String encodedPassword = passwordEncoder.encode(newPassword);
        user.setPassword(encodedPassword);
        user.setPasswordHash(encodedPassword);
        userRepository.save(user);

        // Mark token as used
        passwordResetTokenEntity.setUsed(true);
        passwordResetTokenRepo.save(passwordResetTokenEntity);
    }
}
