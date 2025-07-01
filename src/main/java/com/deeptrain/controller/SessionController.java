package com.deeptrain.controller;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.deeptrain.dto.SessionDto;
import com.deeptrain.service.SessionService;

import lombok.RequiredArgsConstructor;

@RestController
@RequestMapping("/api/session")
@RequiredArgsConstructor
public class SessionController {

    private final SessionService sessionService;

    @PostMapping("/start")
    public SessionDto startSession(@RequestBody SessionDto request) {
        return sessionService.startSession(request.getSessionId());
    }

    @DeleteMapping("/clear/{sessionId}")
    public void clearSession(@PathVariable String sessionId) {
        sessionService.clearSession(sessionId);
    }

    @GetMapping("/{sessionId}")
    public SessionDto getSession(@PathVariable String sessionId) {
        return sessionService.getSession(sessionId);
    }
}
