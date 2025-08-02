package com.careconnect.repository;

import com.careconnect.model.Message;
import jakarta.annotation.PostConstruct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {

    @PostConstruct
    public default void test() {
        System.out.println("✅ MessageRepository initialized");
    }
    // Get messages between two users, ordered by timestamp
    @Query("SELECT m FROM Message m " +
            "WHERE (m.senderId = :user1 AND m.receiverId = :user2) " +
            "OR (m.senderId = :user2 AND m.receiverId = :user1) " +
            "ORDER BY m.timestamp ASC")
    List<Message> findConversation(@Param("user1") Long user1, @Param("user2") Long user2);

    // Optionally for inbox preview: last message per user
    @Query("SELECT m FROM Message m WHERE m.senderId = :userId OR m.receiverId = :userId ORDER BY m.timestamp DESC")
    List<Message> findAllUserMessages(@Param("userId") Long userId);
}