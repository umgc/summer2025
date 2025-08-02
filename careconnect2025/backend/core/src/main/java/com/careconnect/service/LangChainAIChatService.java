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
import com.careconnect.service.PatientService;
import com.careconnect.dto.EnhancedPatientProfileDTO;
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
    private final PatientService patientService;
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
            PatientService patientService,
            UserAIConfigService userAIConfigService) {
        this.modelProvider = modelProvider;
        this.chatModel = OpenAiChatModel.builder()
            .apiKey(openAiApiKey)
            .modelName("gpt-3.5-turbo") 
            .build();
        this.patientRepository = patientRepository;
        this.patientService = patientService;
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
            if (patientService == null) {
                throw new IllegalStateException("PatientService is not configured");
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

            // Get enhanced patient profile with all medical data
            String medicalContext = "";
            boolean isGeneral = true;
            
            try {
                var enhancedProfileOpt = patientService.getEnhancedPatientProfile(patientId);
                if (enhancedProfileOpt.isPresent()) {
                    EnhancedPatientProfileDTO profile = enhancedProfileOpt.get();
                    medicalContext = buildMedicalContextFromProfile(profile, aiConfig);
                    isGeneral = medicalContext.isEmpty();
                    System.out.println(CYAN + "[DEMO] Enhanced profile retrieved successfully" + RESET);
                    System.out.println(CYAN + "[DEMO] Medical context built:\n" + medicalContext + RESET);
                } else {
                    System.out.println(CYAN + "[DEMO] No enhanced profile found for patient" + RESET);
                }
            } catch (Exception e) {
                System.out.println(CYAN + "[DEMO] Error getting enhanced profile: " + e.getMessage() + RESET);
            }

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

            // Populate response fields
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
                .contextIncluded(List.of()) // No longer using embedding retrieval
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

    /**
     * Build medical context string from enhanced patient profile
     */
    private String buildMedicalContextFromProfile(EnhancedPatientProfileDTO profile, UserAIConfig aiConfig) {
        StringBuilder context = new StringBuilder();
        
        // Add all available metadata scales for AI understanding
        context.append(buildMetadataContext());
        context.append("\n");
        
        // Patient basic information (excluding name and personal identifiers)
        context.append("PATIENT INFORMATION:\n");
        if (profile.dob() != null) {
            context.append("Date of Birth: ").append(profile.dob()).append("\n");
        }
        if (profile.gender() != null) {
            context.append("Gender: ").append(profile.gender()).append("\n");
        }
        context.append("\n");

        // Include medical data based on AI config preferences
        // Comment out AI config checks - include all enhanced patient data by default
        if (/* aiConfig.isIncludeAllergiesByDefault() && */ profile.allergies() != null && !profile.allergies().isEmpty()) {
            context.append("ALLERGIES:\n");
            for (var allergy : profile.allergies()) {
                context.append("- ").append(allergy.allergen());
                if (allergy.severity() != null) {
                    context.append(" (Severity: ").append(allergy.severity()).append(")");
                }
                if (allergy.reaction() != null && !allergy.reaction().trim().isEmpty()) {
                    context.append(" - Reaction: ").append(allergy.reaction());
                }
                context.append("\n");
            }
            context.append("\n");
        }

        if (/* aiConfig.isIncludeMedicationsByDefault() && */ profile.activeMedications() != null && !profile.activeMedications().isEmpty()) {
            context.append("CURRENT MEDICATIONS:\n");
            for (var medication : profile.activeMedications()) {
                context.append("- ").append(medication.medicationName());
                if (medication.dosage() != null) {
                    context.append(" - ").append(medication.dosage());
                }
                if (medication.frequency() != null) {
                    context.append(" (").append(medication.frequency()).append(")");
                }
                context.append("\n");
            }
            context.append("\n");
        }

        if (/* aiConfig.isIncludeVitalsByDefault() && */ profile.latestVitals() != null) {
            var vitals = profile.latestVitals();
            context.append("LATEST VITAL SIGNS:\n");
            if (vitals.heartRate() != null) {
                context.append("- Heart Rate: ").append(vitals.heartRate()).append(" bpm\n");
            }
            if (vitals.spo2() != null) {
                context.append("- SpO2: ").append(vitals.spo2()).append("%\n");
            }
            if (vitals.systolic() != null && vitals.diastolic() != null) {
                context.append("- Blood Pressure: ").append(vitals.systolic()).append("/").append(vitals.diastolic()).append(" mmHg\n");
            }
            if (vitals.weight() != null) {
                context.append("- Weight: ").append(vitals.weight()).append(" lbs\n");
            }
            if (vitals.timestamp() != null) {
                context.append("- Recorded: ").append(vitals.timestamp()).append("\n");
            }
            context.append("\n");
        }

        if (/* aiConfig.isIncludeMoodPainByDefault() && */ profile.latestMoodPain() != null) {
            var moodPain = profile.latestMoodPain();
            context.append("LATEST MOOD & PAIN:\n");
            if (moodPain.moodValue() != null) {
                context.append("- Mood Level: ").append(moodPain.moodValue()).append("/10\n");
            }
            if (moodPain.painValue() != null) {
                context.append("- Pain Level: ").append(moodPain.painValue()).append("/10\n");
            }
            if (moodPain.note() != null && !moodPain.note().trim().isEmpty()) {
                context.append("- Note: ").append(moodPain.note()).append("\n");
            }
            if (moodPain.timestamp() != null) {
                context.append("- Recorded: ").append(moodPain.timestamp()).append("\n");
            }
            context.append("\n");
        }

        // Add medical summary if available
        if (profile.medicalSummary() != null) {
            var summary = profile.medicalSummary();
            context.append("MEDICAL SUMMARY:\n");
            context.append("- Health Status: ").append(summary.overallHealthStatus()).append("\n");
            context.append("- Total Allergies: ").append(summary.totalAllergies()).append("\n");
            context.append("- Active Medications: ").append(summary.activeMedications()).append("\n");
            if (summary.lastActivityDate() != null) {
                context.append("- Last Activity: ").append(summary.lastActivityDate()).append("\n");
            }
            context.append("\n");
        }

        return context.toString();
    }

    /**
     * Build comprehensive metadata context for AI understanding
     * This method is reusable and scalable for adding new metadata types
     */
    private String buildMetadataContext() {
        StringBuilder metadata = new StringBuilder();
        metadata.append("=== HEALTHCARE SCALES & REFERENCES ===\n\n");
        
        // Add all available scales
        metadata.append(buildMoodScaleMetadata());
        metadata.append(buildPainScaleMetadata());
        // Future scales can be easily added here:
        // metadata.append(buildAnxietyScaleMetadata());
        // metadata.append(buildFatigueScaleMetadata());
        // metadata.append(buildSleepQualityScaleMetadata());
        
        return metadata.toString();
    }

    /**
     * Build mood scale metadata
     */
    private String buildMoodScaleMetadata() {
        // Define mood scale data structure for easy maintenance
        var moodScale = java.util.List.of(
            new ScaleItem(0, "😡", "Angry"),
            new ScaleItem(1, "😐", "Sad"),
            new ScaleItem(2, "😫", "Tired"),
            new ScaleItem(3, "😨", "Fearful"),
            new ScaleItem(4, "😑", "Neutral"),
            new ScaleItem(5, "😊", "Happy")
        );

        return buildScaleReference("MOOD SCALE", "(0-5)", moodScale);
    }

    /**
     * Build pain scale metadata
     */
    private String buildPainScaleMetadata() {
        // Define pain scale data structure for easy maintenance
        var painScale = java.util.List.of(
            new ScaleItem(0, "😊", "No Pain", "No pain"),
            new ScaleItem(1, "🙂", "Very Mild", "Pain is very mild, barely noticeable"),
            new ScaleItem(2, "😐", "Minor", "Minor pain, annoying"),
            new ScaleItem(3, "😕", "Noticeable", "Noticeable pain, may distract you"),
            new ScaleItem(4, "😒", "Moderate", "Moderate pain, can ignore while active"),
            new ScaleItem(5, "😞", "Moderately Strong", "Moderately strong pain"),
            new ScaleItem(6, "😖", "Stronger", "Moderately stronger pain"),
            new ScaleItem(7, "😫", "Strong", "Strong pain, prevents normal activities"),
            new ScaleItem(8, "😰", "Very Strong", "Very strong pain, hard to do anything"),
            new ScaleItem(9, "😭", "Hard to Tolerate", "Very hard to tolerate"),
            new ScaleItem(10, "😱", "Worst Pain", "Worst pain possible")
        );

        return buildScaleReference("PAIN SCALE", "(0-10)", painScale);
    }

    /**
     * Generic method to build scale reference text
     */
    private String buildScaleReference(String scaleName, String range, java.util.List<ScaleItem> items) {
        StringBuilder scale = new StringBuilder();
        scale.append(scaleName).append(" REFERENCE ").append(range).append(":\n");
        
        for (ScaleItem item : items) {
            scale.append(item.value).append(": ");
            if (item.emoji != null) {
                scale.append(item.emoji).append(" ");
            }
            scale.append(item.label);
            if (item.description != null && !item.description.equals(item.label)) {
                scale.append(" - ").append(item.description);
            }
            scale.append("\n");
        }
        scale.append("\n");
        
        return scale.toString();
    }

    /**
     * Data structure for scale items to make metadata management easier
     */
    private static class ScaleItem {
        final int value;
        final String emoji;
        final String label;
        final String description;

        ScaleItem(int value, String emoji, String label) {
            this(value, emoji, label, null);
        }

        ScaleItem(int value, String emoji, String label, String description) {
            this.value = value;
            this.emoji = emoji;
            this.label = label;
            this.description = description;
        }
    }
}

