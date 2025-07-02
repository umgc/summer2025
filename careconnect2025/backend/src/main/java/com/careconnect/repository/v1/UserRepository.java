package com.careconnect.repository.v1;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.context.annotation.Profile;

import com.careconnect.model.v1.User;

import java.util.Optional;
import java.util.List;


@Profile("v1")
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmailAndRole(String email, String role);
    boolean existsByEmailAndRole(String email, String role);
    Optional<User> findByVerificationToken(String token);
    List<User> findByNameContainingIgnoreCaseOrEmailContainingIgnoreCase(String name, String email);

}
