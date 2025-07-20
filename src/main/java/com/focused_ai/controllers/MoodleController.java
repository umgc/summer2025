package com.focused_ai.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.focused_ai.models.domain.CourseList;
import com.focused_ai.services.MoodleService;
import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/moodle")
@RequiredArgsConstructor
public class MoodleController {

    private final MoodleService moodleService;

    @GetMapping("/courses")
    public ResponseEntity<CourseList> getCourses(
            @RequestHeader("Authorization") String header) {
        String jwt = header.substring(7);
        return ResponseEntity.ok(moodleService.getCourses(jwt));
    }
}