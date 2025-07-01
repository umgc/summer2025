package com.deeptrain.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

import com.deeptrain.model.DeepSeekResponse;



@Component
public class DeepSeekClient {

    private final WebClient webClient;

    public DeepSeekClient(@Value("${deepseek.api.base-url}") String baseUrl) {
        this.webClient = WebClient.builder()
            .baseUrl(baseUrl)
            .build();
    }

    public DeepSeekResponse evaluate(String prompt) {
        return webClient.post()
            .uri("/evaluate")
            .bodyValue(new PromptRequest(prompt))
            .retrieve()
            .bodyToMono(DeepSeekResponse.class)
            .block();  // blocking to keep it simple; avoid in reactive flow
    }

    static class PromptRequest {
        private String prompt;

        public PromptRequest(String prompt) {
            this.prompt = prompt;
        }

        public String getPrompt() {
            return prompt;
        }

        public void setPrompt(String prompt) {
            this.prompt = prompt;
        }
    }
}
