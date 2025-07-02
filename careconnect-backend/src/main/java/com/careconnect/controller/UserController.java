package com.careconnect.controller;

import com.careconnect.dto.UserResponse;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/users")
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
