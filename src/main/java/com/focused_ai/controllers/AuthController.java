package com.focused_ai.controllers;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.focused_ai.models.moodle.MoodleLoginRequest;
import com.focused_ai.services.GoogleClassroomService;
import com.focused_ai.services.MoodleService;
import com.focused_ai.utils.JwtUtil;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final MoodleService moodleService;
    private final GoogleClassroomService googleClassroomService;
    private final JwtUtil jwtUtils;

    public AuthController(MoodleService moodleService, GoogleClassroomService googleClassroomService,
            JwtUtil jwtUtils) {
        this.moodleService = moodleService;
        this.googleClassroomService = googleClassroomService;
        this.jwtUtils = jwtUtils;
    }

    @PostMapping("/moodle")
    public ResponseEntity<?> moodleLogin(@RequestBody MoodleLoginRequest loginRequest) {
        System.out.println("AuthService: Received Moodle login request for user: " + loginRequest.getUsername());

        try {
            Map<String, String> moodleUserData = moodleService.moodleAuthenticate(
                    loginRequest.getMoodleUrl(),
                    loginRequest.getUsername(),
                    loginRequest.getPassword());
            System.out.println("jwt about to be created");
            String jwt = jwtUtils.generateMoodleToken(moodleUserData.get("id"), loginRequest.getUsername(),
                    moodleUserData.get("role"), loginRequest.getMoodleUrl(), moodleUserData.get("webServiceToken"));

            System.out.println("jwt created");

            Map<String, String> response = Map.of(
                    "id", moodleUserData.get("id"),
                    "role", moodleUserData.get("role"),
                    "jwt", jwt);

            return ResponseEntity.ok().body(response);
        } catch (Exception e) {
            System.err.println("AuthService: Moodle login failed: " + e.getMessage());
            return ResponseEntity.status(401).body(e.getMessage());
        }
    }

    @PostMapping("/google")
    public ResponseEntity<?> googleLogin(@RequestBody Map<String, String> payload) {
        String serverAuthCode = payload.get("serverAuthCode");
        String userId = payload.get("userId");
        String email = payload.get("email");

        System.out.println("AuthService: Received Google auth request for user: " + email);

        try {
            Map<String, String> googleUserData = googleClassroomService.googleAuthenticate(serverAuthCode, userId);

            String jwt = jwtUtils.generateGoogleToken(userId,
                    email, googleUserData.get("role"), googleUserData.get("accessToken"),
                    googleUserData.get("refreshToken"), Long.parseLong(googleUserData.get("expiry")));

            Map<String, String> response = Map.of(
                    "id", userId,
                    "role", googleUserData.get("role"),
                    "jwt", jwt);
            return ResponseEntity.ok().body(response);
        } catch (Exception e) {
            System.err.println("AuthService: Google login failed: " + e.getMessage());
            return ResponseEntity.status(401).body(e.getMessage());
        }
    }

    @GetMapping("/debug")
    public ResponseEntity<String> debug() {
        System.out.println("=== DEBUG ENDPOINT CALLED ===");
        return ResponseEntity.ok()
                .header("Content-Type", "text/plain")
                .body("Debug endpoint reached successfully");
    }
}