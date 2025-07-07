package com.careconnect.config;

import com.careconnect.model.Achievement;
import com.careconnect.repository.AchievementRepository;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

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
            achievement.setIcon(icon);  // ✅ set icon here
            achievementRepository.save(achievement);
            System.out.println("Created achievement: " + title);
        } else {
            System.out.println("Achievement already exists: " + title);
        }
    }
}
