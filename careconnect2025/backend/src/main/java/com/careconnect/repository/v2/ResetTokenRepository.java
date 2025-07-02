package com.careconnect.repository.v2;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v2.ResetToken;

@Profile("v2")
@Repository
public interface ResetTokenRepository extends JpaRepository<ResetToken, Long> {

    // Method to find a ResetToken by its token value
    Optional<ResetToken> findByToken(String token);

    // Method to delete a ResetToken by its token value
    void deleteByToken(String token);

}
