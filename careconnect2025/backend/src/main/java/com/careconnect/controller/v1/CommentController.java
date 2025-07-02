package com.careconnect.controller.v1;

import com.careconnect.model.v1.Comment;
import com.careconnect.service.v1.CommentService;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.context.annotation.Profile;

import java.util.List;

@Profile("v1")
@RestController
@RequestMapping("/api/comments")
@CrossOrigin(originPatterns = {
        "http://localhost:3000", // avoid hardcoded ...
        "http://10.0.2.2:8080",
        "http://localhost:8080"
}, allowCredentials = "true")
public class CommentController {

    @Autowired
    private CommentService commentService;

    @GetMapping("/post/{postId}")
    public ResponseEntity<?> getCommentsForPost(@PathVariable Long postId, HttpSession session) {
        Object userId = session.getAttribute("userId");
        if (userId == null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not authenticated");
        }
        List<Comment> comments = commentService.getCommentsForPost(postId);
        return ResponseEntity.ok(comments);
    }

    @PostMapping("/post/{postId}")
    public ResponseEntity<?> addCommentToPost(
            @PathVariable Long postId,
            @RequestBody Comment comment,
            HttpSession session
    ) {
        Object sessionUserId = session.getAttribute("userId");
        if (sessionUserId == null || !sessionUserId.toString().equals(String.valueOf(comment.getUserId()))) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Not authenticated");
        }
        Comment saved = commentService.addComment(postId, comment.getUserId(), comment.getUsername(), comment.getContent());
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }
}
