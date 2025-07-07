package com.deeptrain.controller;


import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/llm")
@CrossOrigin(origins = "*")
public class LLMController {
    @PostMapping("/generate")
    public String generate(@RequestBody String prompt) {
        return "This is a mock AI response for prompt: " + prompt;
    }
}