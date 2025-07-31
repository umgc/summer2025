package com.careconnect.service;

import java.util.List;

import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;

public interface AIChatService {
    ChatResponse processChat(ChatRequest request);

    // Conversation management
    List<com.careconnect.dto.ChatConversationSummary> getPatientConversations(Long patientId);
    List<com.careconnect.dto.ChatMessageSummary> getConversationMessages(String conversationId);
    void deactivateConversation(String conversationId);
}
