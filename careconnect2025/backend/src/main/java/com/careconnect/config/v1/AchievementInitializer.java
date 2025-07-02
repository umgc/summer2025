package com.careconnect.config.v1;

import com.careconnect.model.v1.Achievement;
import com.careconnect.repository.v1.AchievementRepository;
import org.springframework.context.annotation.Profile;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Profile("v1") 
@Component
public class AchievementInitializer {

    @Autowired
    private AchievementRepository achievementRepository;

    @PostConstruct
    public void initAchievements() {
        createAchievementIfNotExists("Verified Email", "Awarded for verifying your email.", "verified-icon.png");
        createAchievementIfNotExists("First Login", "Awarded for logging in for the first time.", "login-icon.png");
    }

    private void createAchievementIfNotExists(String title, String description, String icon) {
        if (achievementRepository.findByTitle(title).isEmpty()) {
            Achievement achievement = new Achievement();
            achievement.setTitle(title);
            achievement.setDescription(description);
            achievement.setIcon(icon);  
            achievementRepository.save(achievement);
            System.out.println("Created achievement: " + title);
        } else {
            System.out.println("Achievement already exists: " + title);
        }
    }
}
