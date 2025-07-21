package com.careconnect.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class FallbackController {
    @RequestMapping("/**")
    public ResponseEntity<?> fallback(HttpServletRequest request) {
        return new ResponseEntity<>("No handler found for path: " + request.getRequestURI(), HttpStatus.NOT_FOUND);
    }
}
