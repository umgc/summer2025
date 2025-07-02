package com.careconnect.repository.v2;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;

import com.careconnect.model.v2.Achievement;

@Profile("v2")
@Repository
public interface AchievementRepository extends JpaRepository<Achievement, Long> {

}