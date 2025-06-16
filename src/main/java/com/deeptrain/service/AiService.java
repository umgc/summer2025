package com.deeptrain.service;

import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;

@Service
public class AiService {

    private final WebClient webClient = WebClient.create("https://api.deepseek.ai");

    public String generateFeedback(String prompt) {
        // Call external LLM API
        return webClient.post()
                .uri("/v1/generate")
                .bodyValue("{\"prompt\":\"" + prompt + "\"}")
                .retrieve()
                .bodyToMono(String.class)
                .block();
    }
}
