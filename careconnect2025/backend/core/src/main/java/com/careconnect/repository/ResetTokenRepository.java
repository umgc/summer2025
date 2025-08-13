package com.careconnect.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.careconnect.model.ResetToken;

public interface ResetTokenRepository extends JpaRepository<ResetToken, Long> {

    // Method to find a ResetToken by its token value
    Optional<ResetToken> findByToken(String token);

    // Method to delete a ResetToken by its token value
    void deleteByToken(String token);

}
