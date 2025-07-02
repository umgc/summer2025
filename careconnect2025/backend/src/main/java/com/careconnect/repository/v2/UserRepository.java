package com.careconnect.repository.v2;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Repository;

import com.careconnect.model.v2.User;

import java.util.Optional;

@Profile("v2")
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
