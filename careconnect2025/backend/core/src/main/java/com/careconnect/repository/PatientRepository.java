package com.careconnect.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import com.careconnect.model.Patient;
import com.careconnect.model.User;

public interface PatientRepository extends JpaRepository<Patient, Long> {
    List<Patient> findByCaregiverId(Long caregiverId);
    Optional<Patient> findByUser(User user);

}