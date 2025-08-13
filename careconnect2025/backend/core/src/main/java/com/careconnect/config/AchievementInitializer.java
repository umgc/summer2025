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
            createAchievementIfNotExists("First Login", "Awarded for logging in for the first time.", "login-icon.png");
            createAchievementIfNotExists(
                    "Made a Friend",
                    "Awarded for adding your first friend.",
                    "friend-icon.png"
            );
            createAchievementIfNotExists(
                    "Added Family Member",
                    "Awarded for adding your first family member.",
                    "family-icon.png"
            );
            createAchievementIfNotExists("First Post Created", "Awarded for creating your first post.", "post-icon.png");
            createAchievementIfNotExists("5-Day Streak", "Awarded for logging in 5 days in a row.", "streak-icon.png");

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
