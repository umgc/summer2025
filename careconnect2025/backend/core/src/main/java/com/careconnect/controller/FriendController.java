package com.careconnect.controller;

import com.careconnect.model.FriendRequest;
import com.careconnect.model.Friendship;
import com.careconnect.model.User;
import com.careconnect.repository.FriendRequestRepository;
import com.careconnect.repository.FriendshipRepository;
import com.careconnect.repository.UserRepository;
import com.careconnect.service.GamificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/v1/api/friends")
public class FriendController {

    @Autowired
    private GamificationService gamificationService;

    @Autowired
    private FriendRequestRepository friendRequestRepo;

    @Autowired
    private UserRepository userRepo;

    @Autowired
    private FriendshipRepository friendshipRepository;

    // ✅ 1. Send friend request
    @PostMapping("/request")
    public ResponseEntity<?> sendFriendRequest(@RequestBody Map<String, Long> payload) {
        Long fromUserId = payload.get("fromUserId");
        Long toUserId = payload.get("toUserId");

        boolean exists = friendRequestRepo.existsByFromUserIdAndToUserId(fromUserId, toUserId);
        if (exists) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Friend request already sent.");
        }

        FriendRequest request = new FriendRequest();
        request.setFromUserId(fromUserId);
        request.setToUserId(toUserId);
        request.setStatus("pending");
        request.setCreatedAt(new Date());

        friendRequestRepo.save(request);
        return ResponseEntity.status(HttpStatus.CREATED).body("Friend request sent.");
    }

    // ✅ 2. Get all pending friend requests TO a user
    @GetMapping("/requests/{userId}")
    public ResponseEntity<List<Map<String, Object>>> getPendingRequests(@PathVariable Long userId) {
        List<FriendRequest> requests = friendRequestRepo.findByToUserIdAndStatus(userId, "pending");

        List<Map<String, Object>> result = new ArrayList<>();
        for (FriendRequest req : requests) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", req.getId());
            map.put("fromUserId", req.getFromUserId());
            map.put("toUserId", req.getToUserId());
            map.put("status", req.getStatus());
            map.put("createdAt", req.getCreatedAt());

            userRepo.findById(req.getFromUserId()).ifPresent(user -> {
                map.put("from_username", user.getName());
                map.put("from_email", user.getEmail());
            });

            result.add(map);
        }

        return ResponseEntity.ok(result);
    }

    // ✅ 3. Accept a friend request
    @PostMapping("/accept")
    public ResponseEntity<?> acceptFriendRequest(@RequestBody Map<String, Long> body) {
        Long requestId = body.get("requestId");

        Optional<FriendRequest> opt = friendRequestRepo.findById(requestId);
        if (opt.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Request not found");

        FriendRequest req = opt.get();
        if (!"pending".equals(req.getStatus())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Request already handled");
        }

        req.setStatus("accepted");
        friendRequestRepo.save(req);

        Optional<User> fromUserOpt = userRepo.findById(req.getFromUserId());
        Optional<User> toUserOpt = userRepo.findById(req.getToUserId());

        if (fromUserOpt.isEmpty() || toUserOpt.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("User not found");
        }

        User fromUser = fromUserOpt.get();
        User toUser = toUserOpt.get();

        Friendship friendship = Friendship.builder()
                .user1(fromUser)
                .user2(toUser)
                .status("CONFIRMED")
                .build();

        friendshipRepository.save(friendship);

        long friendCount = friendshipRepository.countByUserId(fromUser.getId());

        if (friendCount == 1) { // this is the first confirmed friend added
            gamificationService.unlockAchievement(
                    fromUser.getId(), "Added First Friend", 50
            );
        }

        return ResponseEntity.ok("Friend request accepted and friendship created");
    }

    // ✅ 4. Reject a friend request
    @PostMapping("/reject")
    public ResponseEntity<?> rejectFriendRequest(@RequestBody Map<String, Long> body) {
        Long requestId = body.get("requestId");

        Optional<FriendRequest> opt = friendRequestRepo.findById(requestId);
        if (opt.isEmpty()) return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Request not found");

        FriendRequest req = opt.get();
        if (!"pending".equals(req.getStatus())) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("Request already handled");
        }

        req.setStatus("rejected");
        friendRequestRepo.save(req);

        return ResponseEntity.ok("Friend request rejected");
    }

    @GetMapping("/list/{userId}")
    public ResponseEntity<List<Map<String, Object>>> getFriends(@PathVariable Long userId) {
        List<FriendRequest> acceptedRequests = friendRequestRepo.findByStatus("accepted");

        List<Long> friendIds = new ArrayList<>();
        for (FriendRequest req : acceptedRequests) {
            if (req.getFromUserId().equals(userId)) {
                friendIds.add(req.getToUserId());
            } else if (req.getToUserId().equals(userId)) {
                friendIds.add(req.getFromUserId());
            }
        }

        List<Map<String, Object>> friends = new ArrayList<>();
        for (Long id : friendIds) {
            userRepo.findById(id).ifPresent(user -> {
                Map<String, Object> map = new HashMap<>();
                map.put("id", user.getId());
                map.put("name", user.getName());
                map.put("email", user.getEmail());
                friends.add(map);
            });
        }

        return ResponseEntity.ok(friends);
    }

}
