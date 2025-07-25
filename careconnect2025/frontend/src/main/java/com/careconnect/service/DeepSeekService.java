package com.careconnect.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;
import lombok.extern.slf4j.Slf4j;
import reactor.core.publisher.Mono;

import java.time.Duration;
import java.util.List;

@Slf4j
@Service
public class DeepSeekService {
    
    private final WebClient webClient;
    
    @Value("${deepseek.api.key:}")
    private String apiKey;
    
    @Value("${deepseek.api.url:https://api.deepseek.com/v1}")
    private String apiUrl;
    
    public DeepSeekService() {
        this.webClient = WebClient.builder()
                .baseUrl(apiUrl)
                .build();
    }
    
    public Mono<DeepSeekResponse> sendChatRequest(DeepSeekChatRequest request) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            return Mono.error(new IllegalStateException("DeepSeek API key is not configured"));
        }
        
        log.info("Sending chat request to DeepSeek with model: {}", request.getModel());
        
        return webClient.post()
                .uri("/chat/completions")
                .header("Authorization", "Bearer " + apiKey)
                .header("Content-Type", "application/json")
                .bodyValue(request)
                .retrieve()
                .bodyToMono(DeepSeekResponse.class)
                .timeout(Duration.ofSeconds(30))
                .doOnSuccess(response -> log.info("DeepSeek request successful. Tokens used: {}", 
                    response.getUsage() != null ? response.getUsage().getTotalTokens() : "unknown"))
                .doOnError(WebClientResponseException.class, ex -> 
                    log.error("DeepSeek API error: {} - {}", ex.getStatusCode(), ex.getResponseBodyAsString()))
                .onErrorMap(WebClientResponseException.class, ex -> 
                    new DeepSeekException("DeepSeek API error: " + ex.getMessage(), ex));
    }
    
    // DTO Classes
    public static class DeepSeekChatRequest {
        private String model;
        private List<Message> messages;
        private Double temperature;
        private Integer maxTokens;
        private Boolean stream = false;
        
        public DeepSeekChatRequest(String model, List<Message> messages, Double temperature, Integer maxTokens) {
            this.model = model;
            this.messages = messages;
            this.temperature = temperature;
            this.maxTokens = maxTokens;
        }
        
        // Getters and setters
        public String getModel() { return model; }
        public void setModel(String model) { this.model = model; }
        public List<Message> getMessages() { return messages; }
        public void setMessages(List<Message> messages) { this.messages = messages; }
        public Double getTemperature() { return temperature; }
        public void setTemperature(Double temperature) { this.temperature = temperature; }
        public Integer getMaxTokens() { return maxTokens; }
        public void setMaxTokens(Integer maxTokens) { this.maxTokens = maxTokens; }
        public Boolean getStream() { return stream; }
        public void setStream(Boolean stream) { this.stream = stream; }
    }
    
    public static class Message {
        private String role;
        private String content;
        
        public Message(String role, String content) {
            this.role = role;
            this.content = content;
        }
        
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
        public String getContent() { return content; }
        public void setContent(String content) { this.content = content; }
    }
    
    public static class DeepSeekResponse {
        private String id;
        private String object;
        private Long created;
        private String model;
        private List<Choice> choices;
        private Usage usage;
        
        // Getters and setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getObject() { return object; }
        public void setObject(String object) { this.object = object; }
        public Long getCreated() { return created; }
        public void setCreated(Long created) { this.created = created; }
        public String getModel() { return model; }
        public void setModel(String model) { this.model = model; }
        public List<Choice> getChoices() { return choices; }
        public void setChoices(List<Choice> choices) { this.choices = choices; }
        public Usage getUsage() { return usage; }
        public void setUsage(Usage usage) { this.usage = usage; }
    }
    
    public static class Choice {
        private Integer index;
        private Message message;
        private String finishReason;
        
        public Integer getIndex() { return index; }
        public void setIndex(Integer index) { this.index = index; }
        public Message getMessage() { return message; }
        public void setMessage(Message message) { this.message = message; }
        public String getFinishReason() { return finishReason; }
        public void setFinishReason(String finishReason) { this.finishReason = finishReason; }
    }
    
    public static class Usage {
        private Integer promptTokens;
        private Integer completionTokens;
        private Integer totalTokens;
        
        public Integer getPromptTokens() { return promptTokens; }
        public void setPromptTokens(Integer promptTokens) { this.promptTokens = promptTokens; }
        public Integer getCompletionTokens() { return completionTokens; }
        public void setCompletionTokens(Integer completionTokens) { this.completionTokens = completionTokens; }
        public Integer getTotalTokens() { return totalTokens; }
        public void setTotalTokens(Integer totalTokens) { this.totalTokens = totalTokens; }
    }
    
    public static class DeepSeekException extends RuntimeException {
        public DeepSeekException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
