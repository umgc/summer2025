package com.focused_ai.controllers;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.focused_ai.models.Course;
import com.focused_ai.services.GoogleClassroomService;
import com.focused_ai.utils.JwtUtil;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/google")
@RequiredArgsConstructor
public class GoogleController {
    private final GoogleClassroomService googleService;
    private final JwtUtil jwtUtil;

    @GetMapping("/courses")
    public ResponseEntity<List<Course>> getCourses(
        @RequestHeader("Authorization") String token
    ) {
        String userId = jwtUtil.extractUserId(token.substring(7));
        return ResponseEntity.ok(googleService.getCourses(userId));
    }
}
