package com.careconnect.controller.v2;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/schedules")
public class ScheduleController {
	
    @PostMapping("/template")
    public ResponseEntity<String> createTemplate() { return ResponseEntity.ok("Template created"); }
   
    @PostMapping("/custom")
    public ResponseEntity<String> createCustomTask() { return ResponseEntity.ok("Custom task created"); }
    
    @GetMapping("/patient/{id}")
    public ResponseEntity<String> getSchedule(@PathVariable String id) { return ResponseEntity.ok("Schedule for patient " + id); }
   
    @PostMapping("/shifts")
    public ResponseEntity<String> assignShift() { return ResponseEntity.ok("Shift assigned"); }
    
    @GetMapping("/calendar/shared")
    public ResponseEntity<String> getSharedCalendar() { return ResponseEntity.ok("Shared calendar"); }
}
