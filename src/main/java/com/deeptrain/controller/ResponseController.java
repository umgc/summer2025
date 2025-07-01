package com.deeptrain.controller;

import org.springframework.web.bind.annotation.*;

import com.deeptrain.service.UserResponseService;

import org.springframework.http.ResponseEntity;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ResponseController {

    private final UserResponseService responseService;

    public ResponseController(UserResponseService responseService) {
        this.responseService = responseService;
    }

    @PostMapping("/response")
    public ResponseEntity<String> submitResponse(@RequestBody Map<String, String> payload) {
        String user = payload.get("user");
        String response = payload.get("response");

        responseService.saveResponse(user, response);

        return ResponseEntity.ok("Response submitted successfully");
    }
}

