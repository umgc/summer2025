package com.careconnect.repository;

import com.careconnect.model.XPProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface XPProgressRepository extends JpaRepository<XPProgress, Long> {
    Optional<XPProgress> findByUserId(Long userId);
}
