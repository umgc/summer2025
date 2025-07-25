package com.careconnect.repository;

import com.careconnect.model.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Optional;

public interface PasswordResetTokenRepo extends JpaRepository<PasswordResetToken, Long> {
    @Query("SELECT t FROM PasswordResetToken t WHERE t.tokenHash = :hash AND t.expiresAt > :now AND t.used = false")
    Optional<PasswordResetToken> findValid(@Param("hash") String hash, @Param("now") Instant now);

    // Find the most recent token for a user
    @Query("SELECT t FROM PasswordResetToken t WHERE t.user = :user ORDER BY t.expiresAt DESC")
    Optional<PasswordResetToken> findByUser(@Param("user") com.careconnect.model.User user);

    // Find token by hash regardless of expiration or used status
    Optional<PasswordResetToken> findByTokenHash(String tokenHash);
}

