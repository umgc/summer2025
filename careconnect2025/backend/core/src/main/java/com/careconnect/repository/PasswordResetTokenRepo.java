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
}

