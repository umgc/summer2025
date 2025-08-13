package com.careconnect.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.Optional;
import com.careconnect.model.Patient;
import com.careconnect.model.User;

public interface PatientRepository extends JpaRepository<Patient, Long> {
    Optional<Patient> findByUser(User user);
    boolean existsByUser(User user);
    boolean existsByIdAndUserId(Long id, Long userId);
    Optional<Patient> findByUserId(Long userId);
@Query("SELECT COUNT(p) > 0 FROM Patient p JOIN CaregiverPatientLink cpl " +
           "ON p.user.id = cpl.patientUser.id " +
           "WHERE p.id = :patientId AND cpl.caregiverUser.id = :caregiverId " +
           "AND cpl.status = 'ACTIVE'")
    boolean hasAccessByCaregiverId(@Param("patientId") Long patientId, 
                                  @Param("caregiverId") Long caregiverId);

}