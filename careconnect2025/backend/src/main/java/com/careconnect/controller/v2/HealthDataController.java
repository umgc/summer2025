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
@RequestMapping("/v2/api/health")
public class HealthDataController {
    
	@GetMapping("/symptoms/default")
    public ResponseEntity<String> getDefaultSymptoms() { return ResponseEntity.ok("Default symptoms"); }
    
	@PostMapping("/symptoms/custom")
    public ResponseEntity<String> addCustomSymptom() { return ResponseEntity.ok("Custom symptom added"); }
   
	@PostMapping("/symptoms/{id}/response")
    public ResponseEntity<String> respondToSymptom(@PathVariable String id) { return ResponseEntity.ok("Symptom response recorded"); }
   
	@GetMapping("/patients/{id}/symptoms")
    public ResponseEntity<String> listSymptoms(@PathVariable String id) { return ResponseEntity.ok("Symptoms for patient: " + id); }
    
	@GetMapping("/patients/{id}/mood-trends")
    public ResponseEntity<String> getMoodTrends(@PathVariable String id) { return ResponseEntity.ok("Mood trends"); }
	
	@GetMapping("/patients/{id}/meals/log")
    public ResponseEntity<String> viewMealsLog(@PathVariable String id) { return ResponseEntity.ok("Symptom response recorded"); }
   
	@PostMapping("/patients/{id}/meals/log")
    public ResponseEntity<String> insertMealsLog(@PathVariable String id) { return ResponseEntity.ok("Symptoms for patient: " + id); }
    
	@PostMapping("/patients/{id}/moods")
    public ResponseEntity<String> logPatientMood(@PathVariable String id) { return ResponseEntity.ok("Mood trends"); }
}