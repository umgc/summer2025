package com.careconnect.service;

import java.util.List;

import com.careconnect.dto.ChatRequest;
import com.careconnect.dto.ChatResponse;
import dev.langchain4j.model.chat.ChatModel;
import dev.langchain4j.memory.ChatMemory;
import dev.langchain4j.memory.chat.MessageWindowChatMemory;
import dev.langchain4j.data.message.ChatMessage;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.model.openai.OpenAiChatModel;
import org.springframework.beans.factory.annotation.Value;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

import com.careconnect.model.Patient;
import com.careconnect.model.UserAIConfig;
import com.careconnect.repository.PatientRepository;
import com.careconnect.service.MedicalContextService;
import com.careconnect.service.PatientContextRetrievalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;

@Primary
@Service

public class LangChainAIChatService implements AIChatService {
    private final ChatModel chatModel;
    private final String modelProvider;
    private final Map<Long, ChatMemory> chatMemories = new ConcurrentHashMap<>();
    private final PatientRepository patientRepository;
    private final MedicalContextService medicalContextService;
    private final PatientContextRetrievalService patientContextRetrievalService;
    private final UserAIConfigService userAIConfigService;

    // Add userId field for compatibility
    private Long userId;

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    @Autowired
    public LangChainAIChatService(
            @Value("${ai.model.provider:openai}") String modelProvider,
            @Value("${openai.api.key:}") String openAiApiKey,
            PatientRepository patientRepository,
            MedicalContextService medicalContextService,
            PatientContextRetrievalService patientContextRetrievalService,
            UserAIConfigService userAIConfigService) {
        this.modelProvider = modelProvider;
        this.chatModel = OpenAiChatModel.builder()
            .apiKey(openAiApiKey)
            .modelName("gpt-3.5-turbo") 
            .build();
        this.patientRepository = patientRepository;
        this.medicalContextService = medicalContextService;
        this.patientContextRetrievalService = patientContextRetrievalService;
        this.userAIConfigService = userAIConfigService;
    }
    private ChatMemory getMemory(Long patientId) {
        // Keep last 20 messages per patient (in-memory, for demo)
        return chatMemories.computeIfAbsent(patientId, id -> MessageWindowChatMemory.withMaxMessages(20));
    }

    @Override
    public List<com.careconnect.dto.ChatConversationSummary> getPatientConversations(Long patientId) {
        throw new UnsupportedOperationException("Not implemented in LangChainAIChatService");
    }

    @Override
    public List<com.careconnect.dto.ChatMessageSummary> getConversationMessages(String conversationId) {
        throw new UnsupportedOperationException("Not implemented in LangChainAIChatService");
    }

    @Override
    public void deactivateConversation(String conversationId) {
        throw new UnsupportedOperationException("Not implemented in LangChainAIChatService");
    }

    @Override
    public ChatResponse processChat(ChatRequest request) {
        // Normalize conversationId: treat empty string as null, and generate if missing
        if (request.getConversationId() != null && request.getConversationId().trim().isEmpty()) {
            request.setConversationId(null);
        }
        final String generatedConversationId;
        if (request.getConversationId() == null) {
            String newId = java.util.UUID.randomUUID().toString();
            request.setConversationId(newId);
            generatedConversationId = newId;
        } else {
            generatedConversationId = null;
        }
        try {
            // Always set userId from request before using it
            this.userId = request.getUserId();
            // Defensive: Validate request
            if (request == null) {
                throw new IllegalArgumentException("ChatRequest cannot be null");
            }
            if (request.getUserId() == null) {
                throw new IllegalArgumentException("User ID is required");
            }
            if (request.getMessage() == null || request.getMessage().trim().isEmpty()) {
                throw new IllegalArgumentException("Message cannot be empty");
            }

            // Defensive: Validate dependencies
            if (chatModel == null) {
                throw new IllegalStateException("ChatModel is not configured");
            }
            if (patientRepository == null) {
                throw new IllegalStateException("PatientRepository is not configured");
            }
            if (medicalContextService == null) {
                throw new IllegalStateException("MedicalContextService is not configured");
            }
            if (patientContextRetrievalService == null) {
                throw new IllegalStateException("PatientContextRetrievalService is not configured");
            }

            // Use userId to find patient instead of patientId
            Long userId = request.getUserId();
            if (userId == null) {
                throw new IllegalArgumentException("User ID is required and was null");
            }
            // Find patient by user_id instead of patient_id
            Patient patient = patientRepository.findByUserId(userId)
                .orElseThrow(() -> new IllegalArgumentException("Patient not found for user ID: " + userId));
            
            // Get the actual patient ID for other operations
            Long patientId = patient.getId();
            UserAIConfig aiConfig;
            try {
                var aiConfigDTO = userAIConfigService.getUserAIConfig(userId, patientId);
                aiConfig = userAIConfigService.convertDTOToEntity(aiConfigDTO);
                if (aiConfig == null) {
                    // No config found, create and persist default
                    aiConfig = UserAIConfig.builder()
                        .userId(userId)
                        .patientId(patientId)
                        .preferredAiProvider(UserAIConfig.AIProvider.OPENAI)
                        .isActive(true)
                        .conversationHistoryLimit(20)
                        .maxTokens(1000)
                        .temperature(0.7)
                        .includeVitalsByDefault(false)
                        .includeMedicationsByDefault(false)
                        .includeNotesByDefault(false)
                        .includeMoodPainByDefault(false)
                        .includeAllergiesByDefault(false)
                        .systemPrompt(null)
                        .build();
                    try {
                        userAIConfigService.saveUserAIConfig(userAIConfigService.convertToDTO(aiConfig));
                    } catch (Exception saveEx) {
                        System.out.println("[AIChat] Failed to persist default config: " + saveEx.getMessage());
                    }
                }
            } catch (Exception ex) {
                System.out.println("[AIChat] No valid user AI config found, using default config.");
                aiConfig = UserAIConfig.builder()
                    .userId(userId)
                    .patientId(patientId)
                    .preferredAiProvider(UserAIConfig.AIProvider.OPENAI)
                    .isActive(true)
                    .conversationHistoryLimit(20)
                    .maxTokens(1000)
                    .temperature(0.7)
                    .includeVitalsByDefault(true)
                    .includeMedicationsByDefault(true)
                    .includeNotesByDefault(true)
                    .includeMoodPainByDefault(true)
                    .includeAllergiesByDefault(true)
                    .systemPrompt(null)
                    .build();
                try {
                    userAIConfigService.saveUserAIConfig(userAIConfigService.convertToDTO(aiConfig));
                } catch (Exception saveEx) {
                    System.out.println("[AIChat] Failed to persist default config: " + saveEx.getMessage());
                }
            }
            final String CYAN = "\u001B[36;1m";
            final String RESET = "\u001B[0m";
            System.out.println(CYAN + "[DEBUG] Using patientId: " + patientId + RESET);
            System.out.println(CYAN + "[DEBUG] Patient entity: " + patient + RESET);

            // Build medical context using MedicalContextService
            String medicalContext = medicalContextService.buildPatientContext(patientId, request, aiConfig);
            System.out.println(CYAN + "[DEMO] Final context to embed:\n" + medicalContext + RESET);
            if (!medicalContext.isEmpty()) {
                try {
                    System.out.println(CYAN + "[DEMO] Indexing context for embeddings..." + RESET);
                    patientContextRetrievalService.indexPatientContext(patientId, medicalContext);
                    System.out.println(CYAN + "[DEMO] Context indexed for embeddings." + RESET);
                } catch (Exception e) {
                    System.out.println(CYAN + "[DEMO] Embedding/indexing error: " + e.getMessage() + RESET);
                }
            }
            java.util.List<String> relevantSegments = List.of();
            try {
                relevantSegments = patientContextRetrievalService.retrieveRelevantContext(request.getMessage(), 3);
                System.out.println(CYAN + "[DEMO] Retrieved relevant context segments: " + relevantSegments + RESET);
            } catch (Exception e) {
                System.out.println(CYAN + "[DEMO] Error retrieving relevant context: " + e.getMessage() + RESET);
            }
            String optimizedContext = medicalContext;

            // Chat memory support: always use conversationId (now always present)
            String memoryKey = request.getConversationId();
            ChatMemory memory = chatMemories.computeIfAbsent(memoryKey.hashCode() * 1L, id -> MessageWindowChatMemory.withMaxMessages(20));
            System.out.println(CYAN + "[DEMO] Chat memory before user message: " + memory.messages() + RESET);
            // Add user message to memory
            memory.add(new UserMessage(request.getMessage()));

            // System prompt logic
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
                systemPrompt = "You are a healthcare AI assistant.\n"
                    + "Use only the provided patient data (vitals, labs, medications, allergies, notes, gender, age, etc.) to answer questions.\n"
                    + "If the answer is not in the data, say you do not know.\n"
                    + "Never provide medical advice or diagnosis.\n"
                    + "Always remind the patient to consult their healthcare provider for medical decisions.\n"
                    + "Be concise, factual, and clear.";
            }

            // Compose prompt: system prompt + context + chat history + user message
            StringBuilder promptBuilder = new StringBuilder();
            promptBuilder.append("SYSTEM PROMPT: ").append(systemPrompt).append("\n\n");
            promptBuilder.append("INSTRUCTION: Use only the following patient data to answer the user's question. If the answer is not present, say you do not know.\n\n");
            promptBuilder.append(medicalContext).append("\n\n");
            // Add chat history if present (excluding current user message)
            if (memory.messages().size() > 1) {
                promptBuilder.append("CONVERSATION HISTORY:\n");
                for (int i = 0; i < memory.messages().size() - 1; i++) {
                    ChatMessage msg = memory.messages().get(i);
                    String msgText = msg.toString();
                    promptBuilder.append(msg.type()).append(": ").append(msgText).append("\n");
                }
                promptBuilder.append("\n");
            }
            promptBuilder.append("USER QUESTION: ").append(request.getMessage());
            String prompt = promptBuilder.toString();
            boolean isGeneral = optimizedContext.isEmpty();
            System.out.println(CYAN + "[AIChat] Prompt sent to LLM:\n" + prompt + RESET);

            String aiResponse;
            try {
                var response = chatModel.chat(prompt);
                aiResponse = response != null ? response.toString() : null;
                System.out.println(CYAN + "[AIChat] AI response: " + aiResponse + RESET);
            } catch (Exception e) {
                System.out.println(CYAN + "[AIChat] LLM call failed: " + e.getMessage() + RESET);
                throw new IllegalStateException("LLM call failed: " + e.getMessage(), e);
            }
            if (aiResponse == null || aiResponse.trim().isEmpty()) {
                System.out.println("[AIChat] AI response was empty");
                throw new IllegalStateException("AI response was empty");
            }
            // Always append the healthcare provider reminder if not present
            String reminder = "Always consult with your healthcare provider for medical advice, diagnosis, or treatment decisions.";
            if (!aiResponse.toLowerCase().contains("consult")) {
                aiResponse = aiResponse.trim() + "\n\n" + reminder;
            }
            // Add AI response to memory
            memory.add(new AiMessage(aiResponse));
            System.out.println(CYAN + "[AIChat] Chat memory after AI response: " + memory.messages() + RESET);

            // Populate as many fields as possible
            java.time.LocalDateTime timestamp = java.time.LocalDateTime.now();
            String aiProvider = modelProvider;
            String modelUsed = modelProvider;
            String message = prompt;
            String conversationId = request.getConversationId();
            Long messageId = null;
            String conversationTitle = (message != null && message.length() > 32) ? message.substring(0, 32) + "..." : message;
            Integer totalMessagesInConversation = memory.messages() != null ? memory.messages().size() : null;
            return ChatResponse.builder()
                .success(true)
                .aiResponse(aiResponse)
                .modelUsed(modelUsed)
                .aiProvider(aiProvider)
                .tokensUsed(null)
                .contextIncluded(relevantSegments)
                .errorMessage(isGeneral ? "No patient context found, processed as a general question." : null)
                .conversationId(conversationId != null ? conversationId : generatedConversationId)
                .message(message)
                .messageId(messageId)
                .timestamp(timestamp)
                .conversationTitle(conversationTitle)
                .totalMessagesInConversation(totalMessagesInConversation)
                .totalTokensUsedInConversation(null)
                .temperatureUsed(null)
                .processingTimeMs(null)
                .isNewConversation(generatedConversationId != null)
                .approachingTokenLimit(null)
                .build();
        } catch (Exception e) {
            return ChatResponse.builder()
                .success(false)
                .errorMessage(e.getMessage() != null ? e.getMessage() : "Unknown error")
                .errorCode("LANGCHAIN_ERROR")
                .build();
        }
    }
}

