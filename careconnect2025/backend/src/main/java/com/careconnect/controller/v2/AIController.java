package com.careconnect.controller.v2;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.careconnect.dto.v2.ChatRequest;
import com.careconnect.dto.v2.ChatResponse;
import com.careconnect.service.v2.ChatBotService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/chat")
public class AIController {

    private final ChatBotService bot;

    @Autowired
    public AIController(ChatBotService bot) {
        this.bot = bot;
    }

    @PostMapping
    public ResponseEntity<ChatResponse> chat(
            @RequestHeader("X-Session-Id") String sessionId,
            @Valid @RequestBody ChatRequest request) {

        String answer = bot.ask(sessionId, request.getMessage());
        return ResponseEntity.ok(new ChatResponse(answer));
    }
    
    @PostMapping("/mood-detection")
    public ResponseEntity<String> detectMood() { return ResponseEntity.ok("Mood detected"); }
}