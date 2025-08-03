package com.careconnect.service;

import com.careconnect.dto.UserAIConfigDTO;
import com.careconnect.model.UserAIConfig;
import com.careconnect.repository.UserAIConfigRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserAIConfigService {
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(UserAIConfigService.class);
    public UserAIConfig convertDTOToEntity(UserAIConfigDTO dto) {
        return convertToEntity(dto);
    }
    private final UserAIConfigRepository userAIConfigRepository;

    // Add missing methods for controller compatibility
    public UserAIConfigDTO saveUserAIConfig(UserAIConfigDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Config DTO cannot be null");
        UserAIConfig entity = convertDTOToEntity(dto);
        UserAIConfig saved;
        if (dto.getId() != null) {
            // Update existing config
            saved = userAIConfigRepository.save(entity);
        } else {
            // Create new config
            saved = userAIConfigRepository.save(entity);
        }
        if (saved == null || saved.getId() == null) {
            throw new IllegalStateException("Failed to save AI config for user " + dto.getUserId() + (dto.getPatientId() != null ? ", patient " + dto.getPatientId() : ""));
        }
        return convertToDTO(saved);
    }

    public void deactivateUserAIConfig(Long userId, Long patientId) {
        // Dummy implementation for build
    }

    public UserAIConfigDTO getUserAIConfig(Long userId, Long patientId) {
        UserAIConfig config;
        if (patientId != null) {
            config = userAIConfigRepository.findByUserIdAndPatientIdAndIsActiveTrue(userId, patientId)
                    .orElseGet(() -> {
                        log.info("No AI configuration found for user {}, patient {}. Creating default configuration.", userId, patientId);
                        return createDefaultConfig(userId, patientId);
                    });
        } else {
            config = userAIConfigRepository.findByUserIdAndIsActiveTrue(userId)
                    .orElseGet(() -> {
                        log.info("No AI configuration found for user {}. Creating default configuration.", userId);
                        return createDefaultConfig(userId, null);
                    });
        }
        return convertToDTO(config);
    }

    @Transactional
    private UserAIConfig createDefaultConfig(Long userId, Long patientId) {
        UserAIConfig config = UserAIConfig.builder()
                .userId(userId)
                .patientId(patientId)
                .preferredAiProvider(UserAIConfig.AIProvider.OPENAI)
                .openaiModel("gpt-3.5-turbo")
                .maxTokens(1024)
                .temperature(0.7)
                .conversationHistoryLimit(20)
                .systemPrompt("You are a helpful assistant.")
                .includeVitalsByDefault(true)
                .includeMedicationsByDefault(true)
                .includeNotesByDefault(true)
                .includeMoodPainByDefault(true)
                .includeAllergiesByDefault(true)
                .isActive(true)
                .build();
        UserAIConfig saved = userAIConfigRepository.save(config);
        if (saved == null || saved.getId() == null) {
            throw new IllegalStateException("Failed to create default AI config for user " + userId + (patientId != null ? ", patient " + patientId : ""));
        }
        return saved;
    }
    private UserAIConfig convertToEntity(UserAIConfigDTO dto) {
        UserAIConfig.AIProvider provider;
        try {
            String providerStr = dto.getAiProvider() != null ? dto.getAiProvider().name() : null;
            if (providerStr == null || providerStr.equalsIgnoreCase("DEFAULT")) {
                provider = UserAIConfig.AIProvider.OPENAI;
            } else {
                provider = UserAIConfig.AIProvider.valueOf(providerStr.toUpperCase());
            }
        } catch (Exception e) {
            provider = UserAIConfig.AIProvider.OPENAI;
        }
        return UserAIConfig.builder()
                .userId(dto.getUserId())
                .patientId(dto.getPatientId())
                .preferredAiProvider(provider)
                .openaiModel(dto.getOpenaiModel())
                .deepseekModel(dto.getDeepseekModel())
                .maxTokens(dto.getMaxTokens())
                .temperature(dto.getTemperature())
                .conversationHistoryLimit(dto.getConversationHistoryLimit())
                .systemPrompt(dto.getSystemPrompt())
                .includeVitalsByDefault(dto.getIncludeVitalsByDefault())
                .includeMedicationsByDefault(dto.getIncludeMedicationsByDefault())
                .includeNotesByDefault(dto.getIncludeNotesByDefault())
                .includeMoodPainByDefault(dto.getIncludeMoodPainLogsByDefault())
                .includeAllergiesByDefault(dto.getIncludeAllergiesByDefault())
                .isActive(dto.getIsActive())
                .build();
    }
    public UserAIConfigDTO convertToDTO(UserAIConfig config) {
        if (config == null) return null;
        UserAIConfigDTO dto = new UserAIConfigDTO();
        dto.setUserId(config.getUserId());
        dto.setPatientId(config.getPatientId());
        // Map DEFAULT to OPENAI for compatibility
        UserAIConfig.AIProvider provider = config.getPreferredAiProvider();
        if (provider == UserAIConfig.AIProvider.DEFAULT) {
            dto.setAiProvider(UserAIConfig.AIProvider.OPENAI);
        } else {
            dto.setAiProvider(provider);
        }
        dto.setOpenaiModel(config.getOpenaiModel());
        dto.setDeepseekModel(config.getDeepseekModel());
        dto.setMaxTokens(config.getMaxTokens());
        dto.setTemperature(config.getTemperature());
        dto.setConversationHistoryLimit(config.getConversationHistoryLimit());
        dto.setSystemPrompt(config.getSystemPrompt());
        dto.setIncludeVitalsByDefault(config.getIncludeVitalsByDefault());
        dto.setIncludeMedicationsByDefault(config.getIncludeMedicationsByDefault());
        dto.setIncludeNotesByDefault(config.getIncludeNotesByDefault());
        dto.setIncludeMoodPainLogsByDefault(config.getIncludeMoodPainByDefault());
        dto.setIncludeAllergiesByDefault(config.getIncludeAllergiesByDefault());
        dto.setIsActive(config.getIsActive());
        return dto;
    }
}
