package com.careconnect.repository;

import com.careconnect.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.List;
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    Optional<User> findByEmailAndRole(String email, String role);
    boolean existsByEmailAndRole(String email, String role);
    Optional<User> findByVerificationToken(String token);
    List<User> findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(String name, String email);

}
