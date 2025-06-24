package com.careconnectpt.careconnect2025.repository;


import com.careconnectpt.careconnect2025.model.user.Caregiver;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CaregiverRepository extends JpaRepository<Caregiver, Long> { }