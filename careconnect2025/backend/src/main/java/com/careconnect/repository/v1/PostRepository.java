package com.careconnect.repository.v1;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v1.Post;

import java.util.List;
import org.springframework.context.annotation.Profile;

@Profile("v1")
@Repository      
public interface PostRepository extends JpaRepository<Post, Long> {
    List<Post> findAllByUserIdOrderByCreatedAtDesc(Long userId);
    List<Post> findAllByOrderByCreatedAtDesc(); // For global feed
}
