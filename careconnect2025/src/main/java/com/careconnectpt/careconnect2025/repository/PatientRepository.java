package com.careconnectpt.careconnect2025.repository;


import com.careconnectpt.careconnect2025.model.user.Patient;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PatientRepository extends JpaRepository<Patient, Long> { }