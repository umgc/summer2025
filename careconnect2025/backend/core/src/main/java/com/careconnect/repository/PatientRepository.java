package com.careconnect.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import com.careconnect.model.Patient;
import com.careconnect.model.User;

public interface PatientRepository extends JpaRepository<Patient, Long> {
    Optional<Patient> findByUser(User user);
    boolean existsByUser(User user);
}