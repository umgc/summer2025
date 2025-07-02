package com.careconnect.controller.v2;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api")
public class HealthCheck {

	   @GetMapping("/health")
	    public ResponseEntity<String> healthCheck() {
	        return ResponseEntity.ok("Careconnect Services are up and running!");
	    }
	    
}
