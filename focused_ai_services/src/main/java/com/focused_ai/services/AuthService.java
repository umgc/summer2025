package com.focused_ai.services;

import java.util.Map;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.focused_ai.utils.JwtUtil;

@RestController
@RequestMapping("/auth")
public class AuthService {

    private final MoodleService moodleService;
    private final GoogleClassroomService googleClassroomService;
    private final JwtUtil jwtUtils;

    public AuthService(MoodleService moodleService, GoogleClassroomService googleClassroomService, JwtUtil jwtUtils) {
        this.moodleService = moodleService;
        this.googleClassroomService = googleClassroomService;
        this.jwtUtils = jwtUtils;
    }

    @PostMapping("/moodle")
    public ResponseEntity<?> moodleLogin(@RequestBody LoginRequest loginRequest, HttpServletRequest request) {
        System.out.println("AuthService: Received Moodle login request for user: " + loginRequest.getUsername());
        System.out.println("AuthService: Moodle URL: " + loginRequest.getMoodleUrl());

        try {
            // Store the Moodle URL in the session for this user
            HttpSession session = request.getSession();
            session.setAttribute("moodleUrl", loginRequest.getMoodleUrl());
            System.out.println("AuthService: Stored Moodle URL in session: " + loginRequest.getMoodleUrl());

            Map<String, String> moodleUserData = moodleService.moodleAuthenticate(
                loginRequest.getMoodleUrl(),
                loginRequest.getUsername(),
                loginRequest.getPassword()
            );

            String jwt = jwtUtils.generateToken("moodle", moodleUserData.get("id"), loginRequest.getUsername(),
                    moodleUserData.get("role"));

            Map<String, String> response = Map.of(
                    "id", moodleUserData.get("id"),
                    "role", moodleUserData.get("role"),
                    "token", jwt);

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
            // return role and access token
            Map<String, String> googleUserData = googleClassroomService.googleAuthenticate(serverAuthCode, userId);

            String jwt = jwtUtils.generateToken("googleClassroom", userId,
                    email, googleUserData.get("role"));

            Map<String, String> response = Map.of(
                    "id", userId,
                    "role", googleUserData.get("role"),
                    "token", jwt);

            return ResponseEntity.ok().body(response);
        } catch (Exception e) {
            System.err.println("AuthService: Google login failed: " + e.getMessage());
            return ResponseEntity.status(401).body(e.getMessage());
        }
    }
}