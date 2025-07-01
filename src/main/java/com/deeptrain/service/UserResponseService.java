package com.deeptrain.service;

import org.springframework.stereotype.Service;

import com.deeptrain.model.UserResponse;
import com.deeptrain.repository.UserResponseRepository;

import java.time.LocalDateTime;

@Service
public class UserResponseService {

    private final UserResponseRepository repository;

    public UserResponseService(UserResponseRepository repository) {
        this.repository = repository;
    }

    public void saveResponse(String user, String response) {
        UserResponse ur = new UserResponse();
        ur.setUser(user);
        ur.setResponse(response);
        ur.setSubmittedAt(LocalDateTime.now());
        repository.save(ur);
    }
}
