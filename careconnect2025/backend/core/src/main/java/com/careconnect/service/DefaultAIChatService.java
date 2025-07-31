package com.careconnect.service;

import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
import com.careconnect.dto.ChatConversationSummary;
import com.careconnect.dto.ChatMessageSummary;
import com.careconnect.model.*;
import lombok.Builder;
import com.careconnect.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import dev.langchain4j.memory.ChatMemory;
import dev.langchain4j.model.chat.ChatModel;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DefaultAIChatService implements AIChatService {
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(DefaultAIChatService.class);

    // LangChain4j components (inject or configure as needed)
    private final ChatModel chatModel; // Should be configured for OpenAI or DeepSeek
    // Use a message window memory for demo (20 messages)
    private final ChatMemory chatMemory = MessageWindowChatMemory.withMaxMessages(20);
    // Helper: Get or create patient AI config
    private PatientAIConfig getOrCreatePatientAIConfig(Long patientId) {
        return patientAIConfigRepository.findByPatientIdAndIsActiveTrue(patientId)
                .orElseGet(() -> createDefaultAIConfig(patientId));
    }

    // Helper: Create default AI config
    private PatientAIConfig createDefaultAIConfig(Long patientId) {
        PatientAIConfig config = PatientAIConfig.builder()
                .patientId(patientId)
                .preferredAiProvider(PatientAIConfig.AIProvider.OPENAI)
                .openaiModel("gpt-3.5-turbo")
                .deepseekModel("deepseek-chat")
                .maxTokens(1000)
                .temperature(0.7)
                .conversationHistoryLimit(20)
                .includeVitalsByDefault(true)
                .includeMedicationsByDefault(true)
                .includeNotesByDefault(true)
                .includeMoodPainByDefault(true)
                .includeAllergiesByDefault(true)
                .isActive(true)
                .systemPrompt("You are a healthcare AI assistant. Carefully analyze and summarize the provided patient data (vitals, labs, medications, allergies, and notes). Clearly state what the data shows about the patient's current health. Do not make up information. If the answer is not in the data, say you do not know. Always recommend consulting a healthcare professional for medical decisions.")
                .build();
        return patientAIConfigRepository.save(config);
    }

    // Helper: Get or create conversation
    private ChatConversation getOrCreateConversation(ChatRequest request, PatientAIConfig aiConfig) {
        if (request.getConversationId() != null) {
            Optional<ChatConversation> existing = chatConversationRepository.findByConversationIdAndIsActiveTrue(request.getConversationId());
            if (existing.isPresent()) {
                return existing.get();
            } else {
                // ConversationId provided but not found: create new conversation for user/patient
                ChatConversation newConversation = ChatConversation.builder()
                        .conversationId(UUID.randomUUID().toString())
                        .patientId(request.getPatientId())
                        .userId(request.getUserId())
                        .chatType(request.getChatType())
                        .title(request.getTitle() != null ? request.getTitle() : generateConversationTitle(request.getMessage()))
                        .aiProviderUsed(aiConfig.getPreferredAiProvider())
                        .aiModelUsed(determineModel(request, aiConfig))
                        .isActive(true)
                        .build();
                return chatConversationRepository.save(newConversation);
            }
        }
        // No conversationId provided: create new conversation
        ChatConversation newConversation = ChatConversation.builder()
                .conversationId(UUID.randomUUID().toString())
                .patientId(request.getPatientId())
                .userId(request.getUserId())
                .chatType(request.getChatType())
                .title(request.getTitle() != null ? request.getTitle() : generateConversationTitle(request.getMessage()))
                .aiProviderUsed(aiConfig.getPreferredAiProvider())
                .aiModelUsed(determineModel(request, aiConfig))
                .isActive(true)
                .build();
        return chatConversationRepository.save(newConversation);
    }

    // Helper: Generate conversation title
    private String generateConversationTitle(String firstMessage) {
        if (firstMessage.length() > 50) {
            return firstMessage.substring(0, 47) + "...";
        }
        return firstMessage;
    }

    // Helper: Prepare messages for AI
    private List<Object> prepareMessagesForAI(ChatConversation conversation, String newMessage, String medicalContext, String systemPrompt) {
        List<Object> messages = new ArrayList<>();
        // Use prompt from request if available, else fallback to default
        String prompt = (systemPrompt != null && !systemPrompt.trim().isEmpty())
            ? systemPrompt
            : "You are a healthcare AI assistant. Base your response strictly on the provided patient data (vitals, labs, medications, allergies, and notes) below. Do not make up information. Do not provide any medical advice. When asked, share the pertinent information found in the associated data, and definitely respond that the user should contact their physician to get the answer to the question. If the answer is not in the data, say you do not know. Always recommend consulting a healthcare professional for medical decisions.";
        messages.add(createMessage("system", prompt));
        if (medicalContext != null && !medicalContext.trim().isEmpty()) {
            messages.add(createMessage("system", medicalContext));
        }
        Integer historyLimit = 20;
        if (conversation.getPatientId() != null) {
            PatientAIConfig config = getOrCreatePatientAIConfig(conversation.getPatientId());
            historyLimit = (config != null && config.getConversationHistoryLimit() != null) ? config.getConversationHistoryLimit() : 20;
        }
        List<ChatMessage> recentMessages = chatMessageRepository
                .findTopNByConversationOrderByCreatedAtAsc(conversation, historyLimit);
        for (ChatMessage msg : recentMessages) {
            messages.add(createMessage(msg.getMessageType().getValue(), msg.getContent()));
        }
        messages.add(createMessage("user", newMessage));
        return messages;
    }

    // Helper: Prepare messages for AI (LangChain4j ChatMessage objects)
    private List<dev.langchain4j.data.message.ChatMessage> prepareChatMessagesForAI(ChatConversation conversation, String newMessage, String medicalContext, String systemPrompt) {
        List<dev.langchain4j.data.message.ChatMessage> messages = new ArrayList<>();
        // System prompt as system message
        String prompt = (systemPrompt != null && !systemPrompt.trim().isEmpty())
            ? systemPrompt
            : "You are a healthcare AI assistant. Base your response strictly on the provided patient data (vitals, labs, medications, allergies, and notes) below. Do not make up information. Do not provide any medical advice. When asked, share the pertinent information found in the associated data, and definitely respond that the user should contact their physician to get the answer to the question. If the answer is not in the data, say you do not know. Always recommend consulting a healthcare professional for medical decisions.";
        messages.add(dev.langchain4j.data.message.SystemMessage.from(prompt));
        if (medicalContext != null && !medicalContext.trim().isEmpty()) {
            messages.add(dev.langchain4j.data.message.SystemMessage.from(medicalContext));
        }
        Integer historyLimit = 20;
        if (conversation.getPatientId() != null) {
            PatientAIConfig config = getOrCreatePatientAIConfig(conversation.getPatientId());
            historyLimit = (config != null && config.getConversationHistoryLimit() != null) ? config.getConversationHistoryLimit() : 20;
        }
        List<ChatMessage> recentMessages = chatMessageRepository
                .findTopNByConversationOrderByCreatedAtAsc(conversation, historyLimit);
        for (ChatMessage msg : recentMessages) {
            switch (msg.getMessageType()) {
                case USER -> messages.add(new dev.langchain4j.data.message.UserMessage(msg.getContent()));
                case ASSISTANT -> messages.add(new dev.langchain4j.data.message.AiMessage(msg.getContent()));
                case SYSTEM -> messages.add(dev.langchain4j.data.message.SystemMessage.from(msg.getContent()));
            }
        }
        messages.add(new dev.langchain4j.data.message.UserMessage(newMessage));
        return messages;
    }

    // Helper: Create message map
    private Object createMessage(String role, String content) {
        return Map.of("role", role, "content", content);
    }

    // Helper: Determine model
    private String determineModel(ChatRequest request, PatientAIConfig aiConfig) {
        if (request.getPreferredModel() != null) {
            return request.getPreferredModel();
        }
        return aiConfig.getPreferredAiProvider() == PatientAIConfig.AIProvider.OPENAI ?
                aiConfig.getOpenaiModel() : aiConfig.getDeepseekModel();
    }

    // Disabled: All chat requests are now handled by LangChain4j chatModel. Direct OpenAI/DeepSeek calls are not used.
    // private Mono<ChatProcessingResult> callAIService(ChatProcessingContext context) { /* ...disabled... */ }

    @SuppressWarnings("unchecked")
    private List<OpenAIService.Message> castToOpenAIMessages(List<Object> messages) {
        return (List<OpenAIService.Message>) (List<?>) messages;
    }

    @SuppressWarnings("unchecked")
    private List<DeepSeekService.Message> castToDeepSeekMessages(List<Object> messages) {
        return (List<DeepSeekService.Message>) (List<?>) messages;
    }

    // Helper: Save and build response
    @Transactional
    private ChatResponse saveAndBuildResponse(ChatProcessingResult result) {
        ChatProcessingContext context = result.context;
        Integer tokensUsed = result.tokensUsed != null ? result.tokensUsed : 0;
        ChatMessage userMessage = ChatMessage.builder()
                .conversation(context.conversation)
                .messageType(ChatMessage.MessageType.USER)
                .content(context.messages.get(context.messages.size() - 1).toString())
                .build();
        chatMessageRepository.save(userMessage);
        ChatMessage aiMessage = ChatMessage.builder()
                .conversation(context.conversation)
                .messageType(ChatMessage.MessageType.ASSISTANT)
                .content(result.aiResponse)
                .tokensUsed(tokensUsed)
                .processingTimeMs(result.processingTimeMs)
                .temperatureUsed(context.temperature)
                .aiModelUsed(context.model)
                .contextIncluded(buildContextSummary(context.medicalContext))
                .build();
        ChatMessage savedAiMessage = chatMessageRepository.save(aiMessage);
        context.conversation.setTotalTokensUsed(
                (context.conversation.getTotalTokensUsed() != null ? context.conversation.getTotalTokensUsed() : 0) + tokensUsed
        );
        // Ensure provider/model are set correctly in conversation
        context.conversation.setAiProviderUsed(context.aiConfig.getPreferredAiProvider());
        context.conversation.setAiModelUsed(context.model);
        chatConversationRepository.save(context.conversation);
        ChatResponse resp = new ChatResponse();
        resp.setConversationId(context.conversation.getConversationId());
        resp.setMessage(userMessage.getContent());
        resp.setAiResponse(result.aiResponse);
        resp.setMessageId(savedAiMessage.getId());
        resp.setAiProvider(context.aiConfig.getPreferredAiProvider().name());
        resp.setModelUsed(context.model);
        resp.setTokensUsed(tokensUsed);
        resp.setProcessingTimeMs(result.processingTimeMs);
        resp.setTemperatureUsed(context.temperature);
        resp.setContextIncluded(parseContextIncluded(context.medicalContext));
        resp.setIsNewConversation(context.conversation.getCreatedAt().isAfter(LocalDateTime.now().minusMinutes(1)));
        resp.setTimestamp(LocalDateTime.now());
        resp.setConversationTitle(context.conversation.getTitle());
        resp.setTotalMessagesInConversation(chatMessageRepository.countByConversation(context.conversation));
        resp.setTotalTokensUsedInConversation(context.conversation.getTotalTokensUsed());
        resp.setApproachingTokenLimit(context.conversation.getTotalTokensUsed() > (context.aiConfig.getMaxTokens() * 0.8));
        resp.setSuccess(true);
        return resp;
    }

    // Helper: Build context summary
    private String buildContextSummary(String medicalContext) {
        return medicalContext != null ? "Medical context included" : "No medical context";
    }

    // Helper: Parse context included
    private List<String> parseContextIncluded(String medicalContext) {
        List<String> contextTypes = new ArrayList<>();
        if (medicalContext != null && !medicalContext.trim().isEmpty()) {
            if (medicalContext.contains("Vitals:")) contextTypes.add("vitals");
            if (medicalContext.contains("Medications:")) contextTypes.add("medications");
            if (medicalContext.contains("Clinical Notes:")) contextTypes.add("notes");
            if (medicalContext.contains("Mood/Pain Logs:")) contextTypes.add("mood_pain_logs");
            if (medicalContext.contains("Allergies:")) contextTypes.add("allergies");
        }
        return contextTypes;
    }

    // Helper: Build error response
    private ChatResponse buildErrorResponse(ChatRequest request, String errorMessage) {
        ChatResponse resp = new ChatResponse();
        resp.setConversationId(request.getConversationId());
        resp.setMessage(request.getMessage());
        resp.setSuccess(false);
        resp.setErrorMessage(errorMessage);
        resp.setErrorCode("PROCESSING_ERROR");
        resp.setTimestamp(LocalDateTime.now());
        return resp;
    }

    // Helper: Get patient conversations
    public List<ChatConversationSummary> getPatientConversations(Long patientId) {
        List<ChatConversation> conversations = chatConversationRepository
                .findByPatientIdAndIsActiveTrueOrderByUpdatedAtDesc(patientId);
        return conversations.stream()
                .map(this::convertToConversationSummary)
                .collect(Collectors.toList());
    }

    // Helper: Get conversation messages
    public List<ChatMessageSummary> getConversationMessages(String conversationId) {
        ChatConversation conversation = chatConversationRepository
                .findByConversationIdAndIsActiveTrue(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));
        List<ChatMessage> messages = chatMessageRepository
                .findByConversationOrderByCreatedAtAsc(conversation);
        return messages.stream()
                .map(this::convertToMessageSummary)
                .collect(Collectors.toList());
    }

    // Helper: Deactivate conversation
    @Transactional
    public void deactivateConversation(String conversationId) {
        ChatConversation conversation = chatConversationRepository
                .findByConversationIdAndIsActiveTrue(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));
        conversation.setIsActive(false);
        chatConversationRepository.save(conversation);
    }

    // Helper: Convert to conversation summary
    private ChatConversationSummary convertToConversationSummary(ChatConversation conversation) {
        int messageCount = chatMessageRepository.countByConversation(conversation);
        ChatConversationSummary summary = new ChatConversationSummary();
        summary.setConversationId(conversation.getConversationId());
        summary.setTitle(conversation.getTitle());
        summary.setChatType(conversation.getChatType());
        summary.setAiProvider(conversation.getAiProviderUsed() != null ? conversation.getAiProviderUsed().name() : null);
        summary.setAiModel(conversation.getAiModelUsed());
        summary.setTotalMessages(messageCount);
        summary.setTotalTokensUsed(conversation.getTotalTokensUsed());
        summary.setLastMessageAt(conversation.getUpdatedAt());
        summary.setCreatedAt(conversation.getCreatedAt());
        summary.setIsActive(conversation.getIsActive());
        return summary;
    }

    // Helper: Convert to message summary
    private ChatMessageSummary convertToMessageSummary(ChatMessage message) {
        ChatMessageSummary summary = new ChatMessageSummary();
        summary.setMessageId(message.getId());
        summary.setMessageType(message.getMessageType());
        summary.setContent(message.getContent());
        summary.setTokensUsed(message.getTokensUsed());
        summary.setProcessingTimeMs(message.getProcessingTimeMs());
        summary.setAiModelUsed(message.getAiModelUsed());
        summary.setCreatedAt(message.getCreatedAt());
        return summary;
    }

    // Helper classes
    private static class ChatProcessingContext {
        final Patient patient;
        final PatientAIConfig aiConfig;
        final ChatConversation conversation;
        final List<Object> messages;
        final String model;
        final Double temperature;
        final Integer max_tokens;
        final String medicalContext;
        final long startTime;

        ChatProcessingContext(Patient patient, PatientAIConfig aiConfig, ChatConversation conversation,
                              List<Object> messages, String model, Double temperature, Integer max_tokens,
                              String medicalContext, long startTime) {
            this.patient = patient;
            this.aiConfig = aiConfig;
            this.conversation = conversation;
            this.messages = messages;
            this.model = model;
            this.temperature = temperature;
            this.max_tokens = max_tokens;
            this.medicalContext = medicalContext;
            this.startTime = startTime;
        }
    }

    private static class ChatProcessingResult {
        final ChatProcessingContext context;
        final String aiResponse;
        final Integer tokensUsed;
        final Long processingTimeMs;
        final String error;

        ChatProcessingResult(ChatProcessingContext context, String aiResponse, Integer tokensUsed,
                            Long processingTimeMs, String error) {
            this.context = context;
            this.aiResponse = aiResponse;
            this.tokensUsed = tokensUsed;
            this.processingTimeMs = processingTimeMs;
            this.error = error;
        }
    }
    private final PatientAIConfigRepository patientAIConfigRepository;
    private final ChatConversationRepository chatConversationRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final PatientRepository patientRepository;
    private final OpenAIService openAIService;
    private final DeepSeekService deepSeekService;
    private final MedicalContextService medicalContextService;
    private final PatientContextRetrievalService patientContextRetrievalService;

    @Transactional
    public ChatResponse processChat(ChatRequest request) {
        // Always use LangChain4j chatModel for all chat requests
        if (request.getConversationId() != null && request.getConversationId().trim().isEmpty()) {
            request.setConversationId(null);
        }
        long startTime = System.currentTimeMillis();

        try {
            // Validate patient exists and user has access
            Patient patient = patientRepository.findById(request.getPatientId())
                    .orElseThrow(() -> new IllegalArgumentException("Patient not found"));

            // Get or create patient AI configuration
            PatientAIConfig aiConfig = getOrCreatePatientAIConfig(request.getPatientId());

            // Get or create conversation
            ChatConversation conversation = getOrCreateConversation(request, aiConfig);

            log.info("AIChatService (LangChain4j only) - Using model: {} for patient: {}, user: {}", aiConfig.getOpenaiModel(), request.getPatientId(), request.getUserId());

            // Build medical context
            String medicalContext = medicalContextService.buildPatientContext(
                    request.getPatientId(),
                    request,
                    aiConfig
            );
            log.info("[AIChat] medicalContext: {}", medicalContext);

            // System prompt
            String systemPrompt = null;
            if (request instanceof com.careconnect.dto.ChatRequest) {
                try {
                    java.lang.reflect.Method m = request.getClass().getMethod("getSystemPrompt");
                    Object val = m.invoke(request);
                    if (val != null && !val.toString().trim().isEmpty()) {
                        systemPrompt = val.toString();
                    }
                } catch (Exception ignore) {}
            }
            if (systemPrompt == null) {
                systemPrompt = "You are a healthcare AI assistant. Carefully analyze and summarize the provided patient data (vitals, labs, medications, allergies, and notes). Clearly state what the data shows about the patient's current health. Do not make up information. If the answer is not in the data, say you do not know. Always recommend consulting a healthcare professional for medical decisions.";
            }

            // Prepare messages for AI (as List<ChatMessage> for LangChain4j)
            List<dev.langchain4j.data.message.ChatMessage> messagesForAI = prepareChatMessagesForAI(conversation, request.getMessage(), medicalContext, systemPrompt);
            log.info("[AIChat] messagesForAI (sent to AI): {}", messagesForAI);

            String aiResponse;
            try {
                aiResponse = chatModel.chat(messagesForAI).toString();
            } catch (Exception e) {
                log.error("LangChain4j chat error", e);
                aiResponse = "Sorry, I couldn't process your request.";
            }

            // Build and return ChatResponse
            int totalMessages = chatMessageRepository.countByConversation(conversation);
            Integer totalTokens = chatMessageRepository.sumTokensUsedByConversation(conversation);
            ChatResponse resp = new ChatResponse();
            resp.setConversationId(conversation.getConversationId());
            resp.setMessage(request.getMessage());
            resp.setAiResponse(aiResponse);
            resp.setAiProvider("LANGCHAIN4J");
            resp.setModelUsed(aiConfig.getOpenaiModel());
            resp.setTokensUsed(0);
            resp.setProcessingTimeMs(System.currentTimeMillis() - startTime);
            resp.setTemperatureUsed(request.getTemperature() != null ? request.getTemperature() : 0.1);
            resp.setContextIncluded(List.of("conversation_history", "medical_context"));
            resp.setIsNewConversation(conversation.getCreatedAt().isAfter(LocalDateTime.now().minusMinutes(1)));
            resp.setTimestamp(LocalDateTime.now());
            resp.setConversationTitle(conversation.getTitle());
            resp.setTotalMessagesInConversation(totalMessages);
            resp.setTotalTokensUsedInConversation(totalTokens != null ? totalTokens : 0);
            resp.setApproachingTokenLimit(false);
            resp.setSuccess(true);
            return resp;
        } catch (Exception error) {
            log.error("Error processing chat request: ", error);
            return buildErrorResponse(request, "An error occurred while processing your request");
        }
    }

    // ...all other methods from original AIChatService...
}
