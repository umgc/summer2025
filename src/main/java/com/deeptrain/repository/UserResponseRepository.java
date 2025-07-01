package com.deeptrain.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.deeptrain.model.UserResponse;

public interface UserResponseRepository extends JpaRepository<UserResponse, Long> {
}
