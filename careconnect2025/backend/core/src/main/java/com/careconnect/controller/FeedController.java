package com.careconnect.controller;
import com.careconnect.dto.PostWithCommentCountDto;
import org.springframework.beans.factory.annotation.Value;
import com.careconnect.model.Post;
import com.careconnect.service.FeedService;
import com.careconnect.repository.UserRepository;
import com.careconnect.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/api/feed")
@Tag(name = "Feed", description = "Social feed management endpoints for posts and content sharing")
@SecurityRequirement(name = "JWT Authentication")
public class FeedController {

    @Value("${careconnect.upload.dir}")
    private String uploadDir;

    @Autowired
    private FeedService feedService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/all")
    @Operation(
        summary = "Get global feed",
        description = "Retrieve all posts from the global feed. Requires authentication."
    )
    @ApiResponses({
        @ApiResponse(
            responseCode = "200",
            description = "Global feed retrieved successfully",
            content = @Content(
                mediaType = "application/json",
                    schema = @Schema(implementation = PostWithCommentCountDto.class, type = "array")
            )
        ),
        @ApiResponse(
            responseCode = "403",
            description = "Not authenticated",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(value = """
                    {
                        "error": "Not authenticated"
                    }
                    """)
            )
        )
    })
    public ResponseEntity<?> getGlobalFeed() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not authenticated");
        }

        List<PostWithCommentCountDto> posts = feedService.getAllPostsWithCommentCount();
        return ResponseEntity.ok(posts);
    }

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserFeed(@PathVariable Long userId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not authenticated");
        }

        // Get user from JWT token (email is the subject)
        String email = authentication.getName();
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User not found");
        }

        // Allow users to view their own feed, or admins to view any feed
        if (!user.getId().equals(userId) && !user.getRole().name().equals("ADMIN")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
        }

        List<Post> posts = feedService.getPostsByUser(userId);
        return ResponseEntity.ok(posts);
    }

    @PostMapping(value = "/create", consumes = "multipart/form-data")
    public ResponseEntity<?> createPost(
            @RequestParam("userId") Long userId,
            @RequestParam("content") String content,
            @RequestPart(value = "image", required = false) MultipartFile imageFile
    ) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not authenticated");
        }

        // Get user from JWT token (email is the subject)
        String email = authentication.getName();
        User user = userRepository.findByEmail(email).orElse(null);
        if (user == null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User not found");
        }

        // Verify the post belongs to the authenticated user
        if (!user.getId().equals(userId)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Cannot create post as another user");
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

