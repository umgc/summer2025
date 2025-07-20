package com.focused_ai.controllers;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class TestController {

    @GetMapping("/test")
    public ResponseEntity<String> test() {
        System.out.println("=== TEST CONTROLLER CALLED ===");
        return ResponseEntity.ok("Test returned successfully");
    }
}