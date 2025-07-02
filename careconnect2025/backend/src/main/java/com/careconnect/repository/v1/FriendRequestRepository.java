package com.careconnect.repository.v1;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;
import com.careconnect.model.v1.FriendRequest;

import java.util.List;

@Profile("v1")
@Repository      
public interface FriendRequestRepository extends JpaRepository<FriendRequest, Long> {
    boolean existsByFromUserIdAndToUserId(Long fromUserId, Long toUserId);
    List<FriendRequest> findByToUserIdAndStatus(Long toUserId, String status);
    List<FriendRequest> findByStatus(String status);

}
