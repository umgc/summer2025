package com.careconnect.service;

import com.careconnect.model.Post;
import com.careconnect.repository.CommentRepository;
import com.careconnect.repository.PostRepository;
import com.careconnect.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class FeedService {

    private final PostRepository postRepository;
    private final CommentRepository commentRepository;
    private final UserRepository userRepository;


    @Autowired
    public FeedService(PostRepository postRepository, CommentRepository commentRepository, UserRepository userRepository) {
        this.postRepository = postRepository;
        this.commentRepository = commentRepository;
        this.userRepository = userRepository;
    }


    public List<Map<String, Object>> getAllPostsWithExtras() {
        List<Post> posts = postRepository.findAllByOrderByCreatedAtDesc();
        List<Map<String, Object>> result = new ArrayList<>();

        for (Post post : posts) {
            Map<String, Object> map = new HashMap<>();
            map.put("id", post.getId());
            map.put("content", post.getContent());
            map.put("createdAt", post.getCreatedAt());
            map.put("imageUrl", post.getImageUrl());
            map.put("userId", post.getUserId());

            // Get comment count
            int commentCount = commentRepository.countByPostId(post.getId());
            map.put("commentCount", commentCount);

            // Get username
            String username = userRepository.findById(post.getUserId())
                    .map(user -> user.getName())
                    .orElse("Unknown");
            map.put("username", username);

            result.add(map);
        }
        return result;
    }
    // Create a new post (with optional image URL)
    public Post createPost(Long userId, String content, String imageUrl) {
        Post post = new Post();
        post.setUserId(userId);
        post.setContent(content);
        post.setCreatedAt(LocalDateTime.now());
        post.setImageUrl(imageUrl);  // ✅ Assign uploaded image path
        return postRepository.save(post);
    }

    // Fetch all posts globally
    public List<Post> getAllPosts() {
        return postRepository.findAllByOrderByCreatedAtDesc();
    }

    // Fetch posts by a specific user
    public List<Post> getPostsByUser(Long userId) {
        return postRepository.findAllByUserIdOrderByCreatedAtDesc(userId);
    }
}