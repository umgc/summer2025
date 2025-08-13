package com.careconnect.service;

import com.careconnect.model.*;
import com.careconnect.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Service
public class GamificationService {

    private final XPProgressRepository xpProgressRepository;
    private final AchievementRepository achievementRepository;
    private final UserAchievementRepository userAchievementRepository;

    @Autowired
    public GamificationService(
            XPProgressRepository xpProgressRepository,
            AchievementRepository achievementRepository,
            UserAchievementRepository userAchievementRepository
    ) {
        this.xpProgressRepository = xpProgressRepository;
        this.achievementRepository = achievementRepository;
        this.userAchievementRepository = userAchievementRepository;
    }

    private int calculateLevel(int xp) {
        return xp / 50 + 1;
    }

    public XPProgress awardXp(Long userId, int amount) {
        XPProgress progress = xpProgressRepository.findByUserId(userId)
                .orElseGet(() -> {
                    XPProgress xp = new XPProgress();
                    xp.setUserId(userId);
                    xp.setXp(0);
                    xp.setLevel(1);
                    return xp;
                });

        int newXp = progress.getXp() + amount;
        progress.setXp(newXp);
        progress.setLevel(calculateLevel(newXp));
        progress.setUpdatedAt(LocalDateTime.now());

        return xpProgressRepository.save(progress);
    }

    public void grantAchievement(Long userId, Long achievementId) {
        Achievement achievement = achievementRepository.findById(achievementId)
                .orElseThrow(() -> new RuntimeException("Achievement not found"));

        // Avoid duplicate grant
        boolean alreadyHas = userAchievementRepository.findByUserId(userId)
                .stream()
                .anyMatch(ua -> ua.getAchievement().getId().equals(achievementId));

        if (!alreadyHas) {
            UserAchievement userAchievement = new UserAchievement();
            userAchievement.setUserId(userId);
            userAchievement.setAchievement(achievement);
            userAchievement.setEarnedAt(LocalDateTime.now());

            userAchievementRepository.save(userAchievement);
        }
    }

    public List<Achievement> getAllAchievements() {
        return achievementRepository.findAll();
    }

    public List<UserAchievement> getUserAchievements(Long userId) {
        return userAchievementRepository.findByUserId(userId);
    }

    public Optional<XPProgress> getXpProgress(Long userId) {
        return xpProgressRepository.findByUserId(userId);
    }

    public void unlockAchievement(Long userId, String achievementTitle, int xp) {
        // Find achievement by name
        Optional<Achievement> achievementOpt = achievementRepository.findByTitle(achievementTitle);
        if (achievementOpt.isEmpty()) return;

        Achievement achievement = achievementOpt.get();

        // Check if already unlocked
        boolean alreadyUnlocked = userAchievementRepository.existsByUserIdAndAchievementId(userId, achievement.getId());
        if (alreadyUnlocked) return;

        // Award XP
        awardXp(userId, xp);

        // Save user achievement
        UserAchievement userAchievement = new UserAchievement();
        userAchievement.setUserId(userId);
        userAchievement.setAchievement(achievement);
        userAchievement.setEarnedAt(LocalDateTime.now()); // ✅ correct method name
        userAchievementRepository.save(userAchievement);
    }

}
