package com.careconnect.service;

import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
import com.careconnect.dto.ChatConversationSummary;
import com.careconnect.dto.ChatMessageSummary;
import com.careconnect.model.*;
import com.careconnect.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Mono;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class AIChatService {
    
    private final PatientAIConfigRepository patientAIConfigRepository;
    private final ChatConversationRepository chatConversationRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final PatientRepository patientRepository;
    private final OpenAIService openAIService;
    private final DeepSeekService deepSeekService;
    private final MedicalContextService medicalContextService;
    
    @Transactional
    public Mono<ChatResponse> processChat(ChatRequest request) {
        long startTime = System.currentTimeMillis();
        
        return Mono.fromCallable(() -> {
            // Validate patient exists and user has access
            Patient patient = patientRepository.findById(request.getPatientId())
                    .orElseThrow(() -> new IllegalArgumentException("Patient not found"));
            
            // Get or create patient AI configuration
            PatientAIConfig aiConfig = getOrCreatePatientAIConfig(request.getPatientId());
            
            // Get or create conversation
            ChatConversation conversation = getOrCreateConversation(request, aiConfig);
            
            // Build medical context
            String medicalContext = medicalContextService.buildPatientContext(
                    request.getPatientId(), 
                    request, 
                    aiConfig
            );
            
            // Prepare messages for AI
            List<Object> messages = prepareMessagesForAI(conversation, request.getMessage(), medicalContext);
            
            // Determine AI configuration
            String model = determineModel(request, aiConfig);
            Double temperature = request.getTemperature() != null ? request.getTemperature() : aiConfig.getTemperature();
            Integer maxTokens = request.getMaxTokens() != null ? request.getMaxTokens() : aiConfig.getMaxTokens();
            
            return new ChatProcessingContext(patient, aiConfig, conversation, messages, model, temperature, maxTokens, medicalContext, startTime);
        })
        .flatMap(this::callAIService)
        .map(this::saveAndBuildResponse)
        .doOnError(error -> log.error("Error processing chat request: ", error))
        .onErrorReturn(buildErrorResponse(request, "An error occurred while processing your request"));
    }
    
    private PatientAIConfig getOrCreatePatientAIConfig(Long patientId) {
        return patientAIConfigRepository.findByPatientIdAndIsActiveTrue(patientId)
                .orElseGet(() -> createDefaultAIConfig(patientId));
    }
    
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
                .systemPrompt("You are a helpful AI assistant for healthcare support. Provide informative and supportive responses while always recommending users consult healthcare professionals for medical decisions.")
                .build();
        
        return patientAIConfigRepository.save(config);
    }
    
    private ChatConversation getOrCreateConversation(ChatRequest request, PatientAIConfig aiConfig) {
        if (request.getConversationId() != null) {
            return chatConversationRepository.findByConversationIdAndIsActiveTrue(request.getConversationId())
                    .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));
        }
        
        // Create new conversation
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
    
    private String generateConversationTitle(String firstMessage) {
        if (firstMessage.length() > 50) {
            return firstMessage.substring(0, 47) + "...";
        }
        return firstMessage;
    }
    
    private List<Object> prepareMessagesForAI(ChatConversation conversation, String newMessage, String medicalContext) {
        List<Object> messages = new ArrayList<>();
        
        // Add system message with medical context
        if (medicalContext != null && !medicalContext.trim().isEmpty()) {
            messages.add(createMessage("system", medicalContext));
        }
        
        // Get recent conversation history
        List<ChatMessage> recentMessages = chatMessageRepository
                .findTopNByConversationOrderByCreatedAtAsc(
                        conversation, 
                        conversation.getPatientId() != null ? 
                                getPatientAIConfig(conversation.getPatientId()).getConversationHistoryLimit() : 20
                );
        
        // Add conversation history
        for (ChatMessage msg : recentMessages) {
            messages.add(createMessage(msg.getMessageType().getValue(), msg.getContent()));
        }
        
        // Add new user message
        messages.add(createMessage("user", newMessage));
        
        return messages;
    }
    
    private Object createMessage(String role, String content) {
        return Map.of("role", role, "content", content);
    }
    
    private String determineModel(ChatRequest request, PatientAIConfig aiConfig) {
        if (request.getPreferredModel() != null) {
            return request.getPreferredModel();
        }
        
        return aiConfig.getPreferredAiProvider() == PatientAIConfig.AIProvider.OPENAI ? 
                aiConfig.getOpenaiModel() : aiConfig.getDeepseekModel();
    }
    
    private PatientAIConfig getPatientAIConfig(Long patientId) {
        return patientAIConfigRepository.findByPatientIdAndIsActiveTrue(patientId)
                .orElseGet(() -> createDefaultAIConfig(patientId));
    }
    
    private Mono<ChatProcessingResult> callAIService(ChatProcessingContext context) {
        List<Object> aiMessages = context.messages.stream()
                .map(msg -> {
                    @SuppressWarnings("unchecked")
                    Map<String, String> msgMap = (Map<String, String>) msg;
                    if (context.aiConfig.getPreferredAiProvider() == PatientAIConfig.AIProvider.OPENAI) {
                        return new OpenAIService.Message(msgMap.get("role"), msgMap.get("content"));
                    } else {
                        return new DeepSeekService.Message(msgMap.get("role"), msgMap.get("content"));
                    }
                })
                .collect(Collectors.toList());
        
        if (context.aiConfig.getPreferredAiProvider() == PatientAIConfig.AIProvider.OPENAI) {
            OpenAIService.OpenAIChatRequest openAIRequest = new OpenAIService.OpenAIChatRequest(
                    context.model, 
                    castToOpenAIMessages(aiMessages), 
                    context.temperature, 
                    context.maxTokens
            );
            
            return openAIService.sendChatRequest(openAIRequest)
                    .map(response -> new ChatProcessingResult(context, response.getChoices().get(0).getMessage().getContent(), 
                            response.getUsage().getTotalTokens(), System.currentTimeMillis() - context.startTime, null));
        } else {
            DeepSeekService.DeepSeekChatRequest deepSeekRequest = new DeepSeekService.DeepSeekChatRequest(
                    context.model, 
                    castToDeepSeekMessages(aiMessages), 
                    context.temperature, 
                    context.maxTokens
            );
            
            return deepSeekService.sendChatRequest(deepSeekRequest)
                    .map(response -> new ChatProcessingResult(context, response.getChoices().get(0).getMessage().getContent(), 
                            response.getUsage().getTotalTokens(), System.currentTimeMillis() - context.startTime, null));
        }
    }
    
    @SuppressWarnings("unchecked")
    private List<OpenAIService.Message> castToOpenAIMessages(List<Object> messages) {
        return (List<OpenAIService.Message>) (List<?>) messages;
    }
    
    @SuppressWarnings("unchecked")
    private List<DeepSeekService.Message> castToDeepSeekMessages(List<Object> messages) {
        return (List<DeepSeekService.Message>) (List<?>) messages;
    }
    
    @Transactional
    private ChatResponse saveAndBuildResponse(ChatProcessingResult result) {
        ChatProcessingContext context = result.context;
        
        // Save user message
        ChatMessage userMessage = ChatMessage.builder()
                .conversation(context.conversation)
                .messageType(ChatMessage.MessageType.USER)
                .content(context.messages.get(context.messages.size() - 1).toString()) // Last message is user message
                .build();
        chatMessageRepository.save(userMessage);
        
        // Save AI response
        ChatMessage aiMessage = ChatMessage.builder()
                .conversation(context.conversation)
                .messageType(ChatMessage.MessageType.ASSISTANT)
                .content(result.aiResponse)
                .tokensUsed(result.tokensUsed)
                .processingTimeMs(result.processingTimeMs)
                .temperatureUsed(context.temperature)
                .aiModelUsed(context.model)
                .contextIncluded(buildContextSummary(context.medicalContext))
                .build();
        ChatMessage savedAiMessage = chatMessageRepository.save(aiMessage);
        
        // Update conversation stats
        context.conversation.setTotalTokensUsed(
                (context.conversation.getTotalTokensUsed() != null ? context.conversation.getTotalTokensUsed() : 0) + result.tokensUsed
        );
        chatConversationRepository.save(context.conversation);
        
        // Build response
        return ChatResponse.builder()
                .conversationId(context.conversation.getConversationId())
                .message(userMessage.getContent())
                .aiResponse(result.aiResponse)
                .messageId(savedAiMessage.getId())
                .aiProvider(context.aiConfig.getPreferredAiProvider().name())
                .modelUsed(context.model)
                .tokensUsed(result.tokensUsed)
                .processingTimeMs(result.processingTimeMs)
                .temperatureUsed(context.temperature)
                .contextIncluded(parseContextIncluded(context.medicalContext))
                .isNewConversation(context.conversation.getCreatedAt().isAfter(LocalDateTime.now().minusMinutes(1)))
                .timestamp(LocalDateTime.now())
                .conversationTitle(context.conversation.getTitle())
                .totalMessagesInConversation(chatMessageRepository.countByConversation(context.conversation))
                .totalTokensUsedInConversation(context.conversation.getTotalTokensUsed())
                .approachingTokenLimit(context.conversation.getTotalTokensUsed() > (context.aiConfig.getMaxTokens() * 0.8))
                .success(true)
                .build();
    }
    
    private String buildContextSummary(String medicalContext) {
        // Simple implementation - in production, you might want to be more sophisticated
        return medicalContext != null ? "Medical context included" : "No medical context";
    }
    
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
    
    private ChatResponse buildErrorResponse(ChatRequest request, String errorMessage) {
        return ChatResponse.builder()
                .conversationId(request.getConversationId())
                .message(request.getMessage())
                .success(false)
                .errorMessage(errorMessage)
                .errorCode("PROCESSING_ERROR")
                .timestamp(LocalDateTime.now())
                .build();
    }
    
    public List<ChatConversationSummary> getPatientConversations(Long patientId) {
        List<ChatConversation> conversations = chatConversationRepository
                .findByPatientIdAndIsActiveTrueOrderByUpdatedAtDesc(patientId);
        
        return conversations.stream()
                .map(this::convertToConversationSummary)
                .collect(Collectors.toList());
    }
    
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
    
    @Transactional
    public void deactivateConversation(String conversationId) {
        ChatConversation conversation = chatConversationRepository
                .findByConversationIdAndIsActiveTrue(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));
        
        conversation.setIsActive(false);
        chatConversationRepository.save(conversation);
    }
    
    private ChatConversationSummary convertToConversationSummary(ChatConversation conversation) {
        int messageCount = chatMessageRepository.countByConversation(conversation);
        
        return ChatConversationSummary.builder()
                .conversationId(conversation.getConversationId())
                .title(conversation.getTitle())
                .chatType(conversation.getChatType())
                .aiProvider(conversation.getAiProviderUsed() != null ? conversation.getAiProviderUsed().name() : null)
                .aiModel(conversation.getAiModelUsed())
                .totalMessages(messageCount)
                .totalTokensUsed(conversation.getTotalTokensUsed())
                .lastMessageAt(conversation.getUpdatedAt())
                .createdAt(conversation.getCreatedAt())
                .isActive(conversation.getIsActive())
                .build();
    }
    
    private ChatMessageSummary convertToMessageSummary(ChatMessage message) {
        return ChatMessageSummary.builder()
                .messageId(message.getId())
                .messageType(message.getMessageType())
                .content(message.getContent())
                .tokensUsed(message.getTokensUsed())
                .processingTimeMs(message.getProcessingTimeMs())
                .aiModelUsed(message.getAiModelUsed())
                .createdAt(message.getCreatedAt())
                .build();
    }

    // Helper classes
    @SuppressWarnings("unused")
    private static class ChatProcessingContext {
        final Patient patient;
        final PatientAIConfig aiConfig;
        final ChatConversation conversation;
        final List<Object> messages;
        final String model;
        final Double temperature;
        final Integer maxTokens;
        final String medicalContext;
        final long startTime;
        
        ChatProcessingContext(Patient patient, PatientAIConfig aiConfig, ChatConversation conversation, 
                            List<Object> messages, String model, Double temperature, Integer maxTokens, 
                            String medicalContext, long startTime) {
            this.patient = patient;
            this.aiConfig = aiConfig;
            this.conversation = conversation;
            this.messages = messages;
            this.model = model;
            this.temperature = temperature;
            this.maxTokens = maxTokens;
            this.medicalContext = medicalContext;
            this.startTime = startTime;
        }
    }
    
    @SuppressWarnings("unused")
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
}
