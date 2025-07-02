package com.careconnect.repository.v2;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v2.Patient;
import com.careconnect.model.v2.User;

import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

@Profile("v2")
@Repository
public interface PatientRepository extends JpaRepository<Patient, Long> {
    List<Patient> findByCaregiverId(Long caregiverId);
    Optional<Patient> findByUser(User user);

}