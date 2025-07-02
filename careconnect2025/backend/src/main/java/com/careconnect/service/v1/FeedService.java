    package com.careconnect.service.v1;

    import com.careconnect.model.v1.Post;
    import com.careconnect.repository.v1.PostRepository;

    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.stereotype.Service;
    import org.springframework.context.annotation.Profile;

    import java.time.LocalDateTime;
    import java.util.List;

    @Profile("v1")
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
