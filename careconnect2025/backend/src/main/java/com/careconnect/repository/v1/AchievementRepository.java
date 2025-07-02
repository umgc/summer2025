package com.careconnect.repository.v1;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import com.careconnect.model.v1.Achievement;
import org.springframework.context.annotation.Profile;


import java.util.Optional;

@Profile("v1")
@Repository                       
public interface AchievementRepository extends JpaRepository<Achievement, Long> {
    Optional<Achievement> findByTitle(String title);
}
