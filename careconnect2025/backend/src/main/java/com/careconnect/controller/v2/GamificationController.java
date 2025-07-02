package com.careconnect.controller.v2;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@RestController
@RequestMapping("/v2/api/gamification")
public class GamificationController {
    @GetMapping("/me")
    public String me() { return "{\"level\":1, \"xp\":20}"; }
}
