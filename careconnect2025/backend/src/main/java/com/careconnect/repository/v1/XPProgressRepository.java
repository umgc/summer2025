package com.careconnect.repository.v1;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v1.XPProgress;

import java.util.Optional;

@Profile("v1")
@Repository      
public interface XPProgressRepository extends JpaRepository<XPProgress, Long> {
    Optional<XPProgress> findByUserId(Long userId);
}
