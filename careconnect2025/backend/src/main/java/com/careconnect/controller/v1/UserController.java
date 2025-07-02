package com.careconnect.controller.v1;

import com.careconnect.dto.v1.UserResponse;
import com.careconnect.model.v1.User;
import com.careconnect.repository.v1.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.context.annotation.Profile;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

@Profile("v1")
@RestController
@RequestMapping("/api/users")
@CrossOrigin(originPatterns = {
        "http://localhost:3000",
        "http://10.0.2.2:8080",
        "http://localhost:8080"
}, allowCredentials = "true")
public class UserController {

    @Autowired
    private UserRepository userRepo;

    @GetMapping("/search")
    public ResponseEntity<List<UserResponse>> searchUsers(
            @RequestParam String query,
            @RequestParam Long currentUserId) {

        List<User> users = userRepo.findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(query, query);

        Optional<User> currentUserOpt = userRepo.findById(currentUserId);
        if (currentUserOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Collections.emptyList());
        }

        User currentUser = currentUserOpt.get();

        List<UserResponse> response = users.stream()
                .filter(user -> !(
                        user.getId().equals(currentUserId) &&
                                user.getEmail().equalsIgnoreCase(currentUser.getEmail()) &&
                                user.getRole().equalsIgnoreCase(currentUser.getRole())
                )) // exclude self (same ID + same role + same email)
                .map(user -> new UserResponse(
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getRole(),
                        user.getProfileImageUrl()))
                .toList();

        return ResponseEntity.ok(response);
    }

}
