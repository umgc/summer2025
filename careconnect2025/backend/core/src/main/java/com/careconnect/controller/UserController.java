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
                .filter(u -> !(
                        u.getId().equals(currentUserId) &&
                                u.getEmail().equalsIgnoreCase(currentUser.getEmail()) &&
                                u.getRole().equals(currentUser.getRole())
                )) // exclude self (same ID + same role + same email)
                .map(u -> new UserResponse(
                        u.getId(),
                        u.getName(),
                        u.getEmail(),
                        u.getRole(),
                        Boolean.TRUE.equals(u.getIsVerified()),
                        u.getProfileImageUrl(),
                        u.getStatus()
                ))
                .toList();

        return ResponseEntity.ok(response);
    }

}
