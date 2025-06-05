package com.careconnectpt.careconnect2025.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
public class HealthCheck {

	   @GetMapping("/health")
	    public ResponseEntity<String> healthCheck() {
	        return ResponseEntity.ok("Careconnect Services are up and running!");
	    }
	    
}
