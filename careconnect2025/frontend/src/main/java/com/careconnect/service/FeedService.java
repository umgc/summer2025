    package com.careconnect.service;

    import com.careconnect.model.Post;
    import com.careconnect.repository.PostRepository;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.stereotype.Service;

    import java.time.LocalDateTime;
    import java.util.List;

    @Service
    public class FeedService {

        private final PostRepository postRepository;

        @Autowired
        public FeedService(PostRepository postRepository) {
            this.postRepository = postRepository;
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
