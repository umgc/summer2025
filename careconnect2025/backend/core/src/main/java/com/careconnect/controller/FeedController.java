package com.careconnect.controller;
import com.careconnect.security.service.FeedService;
import org.springframework.beans.factory.annotation.Value;
import com.careconnect.model.Post;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/feed")
public class FeedController {

    @Value("${careconnect.upload.dir}")
    private String uploadDir;

    @Autowired
    private FeedService feedService;

    @GetMapping("/all")
    public ResponseEntity<?> getGlobalFeed(HttpSession session) {
        Object userId = session.getAttribute("userId");

        System.out.println("🧪 [FeedController] Session ID: " + session.getId());
        System.out.println("🧪 [FeedController] Session userId: " + userId);

        if (userId == null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not authenticated");
        }

        List<Post> posts = feedService.getAllPosts();
        return ResponseEntity.ok(posts);
    }


    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserFeed(@PathVariable Long userId, HttpSession session) {
        Object sessionUserId = session.getAttribute("userId");
        if (sessionUserId == null || !sessionUserId.toString().equals(userId.toString())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
        }

        List<Post> posts = feedService.getPostsByUser(userId);
        return ResponseEntity.ok(posts);
    }

    @PostMapping(value = "/create", consumes = "multipart/form-data")
    public ResponseEntity<?> createPost(
            @RequestParam("userId") Long userId,
            @RequestParam("content") String content,
            @RequestPart(value = "image", required = false) MultipartFile imageFile,
            HttpSession session
    ) {
        Object sessionUserId = session.getAttribute("userId");
        if (sessionUserId == null || !sessionUserId.toString().equals(userId.toString())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not authenticated");
        }

        try {
            String imageUrl = null;

            // Ensure the upload directory exists
            File uploadFolder = new File(uploadDir);
            if (!uploadFolder.exists()) {
                boolean created = uploadFolder.mkdirs();
                if (!created) {
                    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                            .body("Failed to create upload directory");
                }
            }

            // Handle image upload if present
            if (imageFile != null && !imageFile.isEmpty()) {
                String extension = "";
                String originalName = imageFile.getOriginalFilename();
                int dotIndex = (originalName != null) ? originalName.lastIndexOf('.') : -1;
                if (dotIndex > 0) {
                    extension = originalName.substring(dotIndex);
                }
                String filename = UUID.randomUUID() + extension;
                File destination = new File(uploadFolder, filename);
                imageFile.transferTo(destination);
                imageUrl = "/uploads/" + filename; // URL for client
            }

            Post post = feedService.createPost(userId, content, imageUrl);
            return ResponseEntity.status(HttpStatus.CREATED).body(post);

        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error saving image: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error creating post: " + e.getMessage());
        }
    }


}

