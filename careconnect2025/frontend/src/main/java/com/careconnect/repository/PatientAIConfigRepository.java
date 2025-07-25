package com.careconnect.repository;

import com.careconnect.model.PatientAIConfig;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PatientAIConfigRepository extends JpaRepository<PatientAIConfig, Long> {
    
    Optional<PatientAIConfig> findByPatientIdAndIsActiveTrue(Long patientId);
    
    List<PatientAIConfig> findByPatientId(Long patientId);
    
    List<PatientAIConfig> findByIsActiveTrue();
    
    boolean existsByPatientIdAndIsActiveTrue(Long patientId);
}
