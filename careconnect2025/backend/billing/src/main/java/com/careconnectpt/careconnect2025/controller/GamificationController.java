package com.careconnectpt.careconnect2025.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/gamification")
public class GamificationController {
    @GetMapping("/me")
    public String me() { return "{\"level\":1, \"xp\":20}"; }
}
