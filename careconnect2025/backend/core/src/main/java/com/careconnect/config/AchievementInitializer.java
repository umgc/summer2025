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
        try {
            createAchievementIfNotExists("Verified Email", "Awarded for verifying your email.", "verified-icon.png");
            createAchievementIfNotExists("First Login", "Awarded for logging in for the first time.", "login-icon.png");
        } catch (Exception e) {
            // Log the error but don't fail application startup
            System.err.println("Failed to initialize achievements: " + e.getMessage());
        }
    }

    private void createAchievementIfNotExists(String title, String description, String icon) {
        try {
            if (achievementRepository.findByTitle(title).isEmpty()) {
                Achievement achievement = new Achievement();
                achievement.setTitle(title);
                achievement.setDescription(description);
                achievement.setIcon(icon);
                achievementRepository.save(achievement);
            }
        } catch (Exception e) {
            // Log the error but continue with other achievements
            System.err.println("Failed to create achievement '" + title + "': " + e.getMessage());
        }
    }
}
