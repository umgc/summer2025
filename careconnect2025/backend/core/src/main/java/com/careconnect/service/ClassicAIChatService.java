package com.careconnect.service;

import java.util.List;

import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
// import reactor.core.publisher.Mono; // Removed Mono import
import org.springframework.stereotype.Service;
public class ClassicAIChatService implements AIChatService {
    @Override
    public List<com.careconnect.dto.ChatConversationSummary> getPatientConversations(Long patientId) {
        throw new UnsupportedOperationException("Not implemented in ClassicAIChatService");
    }

    @Override
    public List<com.careconnect.dto.ChatMessageSummary> getConversationMessages(String conversationId) {
        throw new UnsupportedOperationException("Not implemented in ClassicAIChatService");
    }

    @Override
    public void deactivateConversation(String conversationId) {
        throw new UnsupportedOperationException("Not implemented in ClassicAIChatService");
    }
    @Override
    public ChatResponse processChat(ChatRequest request) {
        return ChatResponse.builder()
                .success(true)
                .aiResponse("Classic AI response")
                .build();
    }
    // ...other methods as needed
}
