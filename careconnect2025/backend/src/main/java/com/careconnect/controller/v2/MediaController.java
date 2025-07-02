package com.careconnect.controller.v2;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/media")
public class MediaController {
    @PostMapping("/upload")
    public ResponseEntity<String> uploadMedia() { return ResponseEntity.ok("Media uploaded"); }
    @GetMapping("/{id}")
    public ResponseEntity<String> getMedia(@PathVariable String id) { return ResponseEntity.ok("Media file: " + id); }
    @DeleteMapping("/{id}")
    public ResponseEntity<String> deleteMedia(@PathVariable String id) { return ResponseEntity.ok("Deleted media: " + id); }
}