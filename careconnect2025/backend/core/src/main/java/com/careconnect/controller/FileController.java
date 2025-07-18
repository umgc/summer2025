package com.careconnect.controller;

import com.careconnect.service.S3StorageService;
import com.careconnect.repository.UserRepository;
import com.careconnect.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/v1/api/files")
@RequiredArgsConstructor
@Slf4j
public class FileController {

    private final S3StorageService storageService;
    private final UserRepository userRepository;

    @PostMapping("/users/{userId}/upload")
    public ResponseEntity<?> uploadFile(
            @PathVariable Long userId,
            @RequestParam("file") MultipartFile file,
            @RequestParam(value = "category", defaultValue = "documents") String category) {
        
        try {
            log.info("Upload request for user ID: {}, category: {}", userId, category);
            
            // Get user details from database
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
            
            // Get userType from user's role
            String userType = user.getRole().name();
            
            if (file.isEmpty()) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "File is empty"));
            }
            
            if (file.getSize() > 10 * 1024 * 1024) {
                return ResponseEntity.badRequest()
                    .body(Map.of("error", "File size exceeds 10MB limit"));
            }
            
            String filePath = storageService.uploadFile(file, userId, userType, category);
            String fileUrl = storageService.getFileUrl(filePath);
            
            log.info("File uploaded successfully: {} for user: {} ({})", filePath, userId, userType);
            
            return ResponseEntity.ok(Map.of(
                "message", "File uploaded successfully",
                "filePath", filePath,
                "fileUrl", fileUrl,
                "fileName", file.getOriginalFilename(),
                "userId", userId,
                "userType", userType,
                "category", category
            ));
            
        } catch (Exception e) {
            log.error("File upload failed for user {}: {}", userId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "File upload failed: " + e.getMessage()));
        }
    }

    @GetMapping("/users/{userId}/download/{*filePath}")
    public ResponseEntity<byte[]> downloadFile(
            @PathVariable Long userId,
            @PathVariable String filePath) {
        try {
            // Verify user exists and get their role
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
            
            String userType = user.getRole().name().toLowerCase();
            
            // Verify file belongs to this user
            String userPrefix = userType + "_" + userId;
            if (!filePath.startsWith(userPrefix)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
            }
            
            byte[] fileContent = storageService.download(filePath);
            
            return ResponseEntity.ok()
                .header("Content-Disposition", "attachment; filename=\"" + extractFileName(filePath) + "\"")
                .body(fileContent);
                
        } catch (Exception e) {
            log.error("File download failed for user {}, path: {}", userId, filePath, e);
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/users/{userId}/delete/{*filePath}")
    public ResponseEntity<?> deleteFile(
            @PathVariable Long userId,
            @PathVariable String filePath) {
        try {
            // Verify user exists and get their role
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
            
            String userType = user.getRole().name().toLowerCase();
            
            // Verify file belongs to this user
            String userPrefix = userType + "_" + userId;
            if (!filePath.startsWith(userPrefix)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Access denied"));
            }
            
            storageService.deleteFile(filePath);
            
            return ResponseEntity.ok(Map.of("message", "File deleted successfully"));
            
        } catch (Exception e) {
            log.error("File deletion failed for user {}, path: {}", userId, filePath, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "File deletion failed"));
        }
    }

    @GetMapping("/users/{userId}/list")
    public ResponseEntity<?> listUserFiles(
            @PathVariable Long userId,
            @RequestParam(value = "category", required = false) String category) {
        try {
            // Verify user exists and get their role
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
            
            String userType = user.getRole().name();
            
            var files = storageService.listUserFiles(userId, userType);
            
            // Filter by category if specified
            if (category != null && !category.isEmpty()) {
                files = files.stream()
                    .filter(file -> file.contains("/" + category.toLowerCase() + "/"))
                    .toList();
            }
            
            return ResponseEntity.ok(Map.of(
                "files", files,
                "count", files.size(),
                "userId", userId,
                "userType", userType,
                "userRole", user.getRole().name(),
                "category", category != null ? category : "all"
            ));
            
        } catch (Exception e) {
            log.error("Failed to list files for user {}: {}", userId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to list files"));
        }
    }

    @GetMapping("/users/{userId}/categories")
    public ResponseEntity<?> getValidCategories(@PathVariable Long userId) {
        try {
            User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found: " + userId));
            
            var categories = getValidCategoriesForRole(user.getRole());
            
            return ResponseEntity.ok(Map.of(
                "categories", categories,
                "userType", user.getRole().name(),
                "userId", userId
            ));
            
        } catch (Exception e) {
            log.error("Failed to get categories for user {}: {}", userId, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to get categories"));
        }
    }

    private java.util.List<String> getValidCategoriesForRole(com.careconnect.security.Role role) {
        return switch (role) {
            case PATIENT -> java.util.List.of("profile", "documents", "medical-records", "prescriptions", 
                                            "insurance", "reports", "consent-forms", "emergency-contacts");
            case CAREGIVER -> java.util.List.of("profile", "certifications", "documents", "training", 
                                              "background-check", "references", "contracts");
            case FAMILY_MEMBER -> java.util.List.of("profile", "documents", "authorization");
            default -> java.util.List.of("documents");
        };
    }

    private String extractFileName(String filePath) {
        String[] parts = filePath.split("/");
        return parts[parts.length - 1];
    }
}