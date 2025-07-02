package com.careconnect.repository.v2;

import org.springframework.data.jpa.repository.JpaRepository;
import com.careconnect.model.v2.User;
import com.careconnect.model.v2.Caregiver;
import com.careconnect.service.v2.CaregiverService;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Profile("v2")
@Repository
public interface CaregiverRepository extends JpaRepository<Caregiver, Long> {
    Optional<Caregiver> findByUser(User user);
 }