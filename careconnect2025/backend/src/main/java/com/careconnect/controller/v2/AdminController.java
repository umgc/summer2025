package com.careconnect.controller.v2;

import java.util.ArrayList;
import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.context.annotation.Profile;

import com.careconnect.dto.v2.User;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/admin")
public class AdminController {
	
    @GetMapping("/users")
    public ResponseEntity<List<User>> listUsers() { 
    	List<User> users = new ArrayList<User>();
    	return ResponseEntity.ok(users);
    	}
    
    @GetMapping("/audit-logs")
    public ResponseEntity<String> getAuditLogs() { return ResponseEntity.ok("Audit logs"); }
   
    @GetMapping("/system-status")
    public ResponseEntity<String> getSystemStatus() { return ResponseEntity.ok("System is healthy"); }
}