package com.careconnect.controller;

import com.careconnect.model.*;
import com.careconnect.service.GamificationService;
import org.springframework.security.core.Authentication;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/gamification")
public class GamificationController {

    private final GamificationService gamificationService;

    @Autowired
    public GamificationController(GamificationService gamificationService) {
        this.gamificationService = gamificationService;
    }

    // 1. Award XP to user
    @PostMapping("/award-xp")
    public ResponseEntity<?> awardXp(@RequestBody Map<String, Object> body) {
        Long userId = Long.valueOf(body.get("userId").toString());
        int amount = Integer.parseInt(body.get("amount").toString());

        XPProgress updatedProgress = gamificationService.awardXp(userId, amount);
        return ResponseEntity.ok(updatedProgress);
    }

    @GetMapping("/progress/{userId}")
    public ResponseEntity<?> getXpProgress(@PathVariable Long userId, Authentication authentication) {
        // JWT-based authentication - get user from security context
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(401).body("Authentication required");
        }

        // For JWT, you can get user details from authentication
        String userEmail = authentication.getName();
        // Additional validation can be added here if needed

        return gamificationService.getXpProgress(userId)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.status(404).body(null));
    }

    // 3. Get earned achievements for a user
    @GetMapping("/achievements/{userId}")
    public ResponseEntity<List<UserAchievement>> getUserAchievements(@PathVariable Long userId) {
        return ResponseEntity.ok(gamificationService.getUserAchievements(userId));
    }

    // 4. Get full list of all achievements (earned + unearned)
    @GetMapping("/all-achievements")
    public ResponseEntity<List<Achievement>> getAllAchievements() {
        return ResponseEntity.ok(gamificationService.getAllAchievements());
    }
}
