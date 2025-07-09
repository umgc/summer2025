package com.careconnect.controller;

import com.careconnect.model.*;
import com.careconnect.security.service.GamificationService;
import jakarta.servlet.http.HttpSession;
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
    public ResponseEntity<?> getXpProgress(@PathVariable Long userId, HttpSession session) {
        // 🔍 Debug print statements
        System.out.println("Session ID: " + session.getId());
        System.out.println("Session UserID: " + session.getAttribute("userId"));

        Object sessionUserId = session.getAttribute("userId");

        if (sessionUserId == null || !sessionUserId.toString().equals(userId.toString())) {
            return ResponseEntity.status(403).body(1);
        }

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
