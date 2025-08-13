package com.careconnect.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import lombok.extern.slf4j.Slf4j;

import java.time.Duration;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class OpenAIService {
    
    private final com.fasterxml.jackson.databind.ObjectMapper objectMapper;
    
    @Value("${openai.api.key:}")
    private String apiKey;
    
    @Value("${openai.api.url:https://api.openai.com/v1}")
    private String apiUrl;

    @org.springframework.beans.factory.annotation.Autowired
    public OpenAIService(com.fasterxml.jackson.databind.ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }
    
    public OpenAIResponse sendChatRequest(OpenAIChatRequest request) {
        if (apiKey == null || apiKey.trim().isEmpty()) {
            throw new IllegalStateException("OpenAI API key is not configured");
        }

        try {
            // Reset any legacy maxTokens field if present via reflection (defensive)
            try {
                java.lang.reflect.Field legacyField = request.getClass().getDeclaredField("maxTokens");
                legacyField.setAccessible(true);
                legacyField.set(request, null);
            } catch (NoSuchFieldException ignore) {}
            String jsonPayload = objectMapper.writeValueAsString(request);
        } catch (Exception e) {
        }

        throw new UnsupportedOperationException("Synchronous OpenAI call not yet implemented");
    }
    
    // DTO Classes
    @com.fasterxml.jackson.annotation.JsonIgnoreProperties(ignoreUnknown = true)
    public static class OpenAIChatRequest {
        private String model;
        private List<Message> messages;
        private Double temperature;
        @com.fasterxml.jackson.annotation.JsonProperty("max_tokens")
        private Integer max_tokens;
        private Boolean stream = false;

        public OpenAIChatRequest(String model, List<Message> messages, Double temperature, Integer max_tokens) {
            this.model = model;
            this.messages = messages;
            this.temperature = temperature;
            this.max_tokens = max_tokens;
        }

        // Getters and setters
        public String getModel() { return model; }
        public void setModel(String model) { this.model = model; }
        public List<Message> getMessages() { return messages; }
        public void setMessages(List<Message> messages) { this.messages = messages; }
        public Double getTemperature() { return temperature; }
        public void setTemperature(Double temperature) { this.temperature = temperature; }
        public Integer getMax_tokens() { return max_tokens; }
        public void setMax_tokens(Integer max_tokens) { this.max_tokens = max_tokens; }
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
    
    public static class OpenAIResponse {
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
    
    public static class OpenAIException extends RuntimeException {
        public OpenAIException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
