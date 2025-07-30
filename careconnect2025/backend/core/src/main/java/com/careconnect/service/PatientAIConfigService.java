    // ...existing code...
package com.careconnect.service;

import com.careconnect.dto.PatientAIConfigDTO;
import com.careconnect.model.PatientAIConfig;
import com.careconnect.repository.PatientAIConfigRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class PatientAIConfigService {
    // ...existing code...
    public PatientAIConfig convertDTOToEntity(PatientAIConfigDTO dto) {
        return convertToEntity(dto);
    }
    
    private final PatientAIConfigRepository patientAIConfigRepository;
    
    public PatientAIConfigDTO getPatientAIConfig(Long patientId) {
        PatientAIConfig config = patientAIConfigRepository.findByPatientIdAndIsActiveTrue(patientId)
                .orElseGet(() -> {
                    log.info("No AI configuration found for patient {}. Creating default configuration.", patientId);
                    return createDefaultConfig(patientId);
                });
        
        return convertToDTO(config);
    }
    
    @Transactional
    private PatientAIConfig createDefaultConfig(Long patientId) {
        PatientAIConfig defaultConfig = PatientAIConfig.builder()
                .patientId(patientId)
                .preferredAiProvider(PatientAIConfig.AIProvider.OPENAI)
                .openaiModel("gpt-4")
                .deepseekModel("deepseek-chat")
                .maxTokens(2000)
                .temperature(0.7)
                .conversationHistoryLimit(20)
                .includeVitalsByDefault(true)
                .includeMedicationsByDefault(true)
                .includeNotesByDefault(true)
                .includeMoodPainByDefault(true)
                .includeAllergiesByDefault(true)
                .isActive(true)
                .systemPrompt("You are a helpful AI assistant specialized in healthcare. Provide accurate, empathetic responses while ensuring patient safety and privacy.")
                .build();
                
        return patientAIConfigRepository.save(defaultConfig);
    }
    
    @Transactional
    public PatientAIConfigDTO savePatientAIConfig(PatientAIConfigDTO configDTO) {
        PatientAIConfig config;
        
        if (configDTO.getId() != null) {
            // Update existing config
            config = patientAIConfigRepository.findById(configDTO.getId())
                    .orElseThrow(() -> new IllegalArgumentException("Configuration not found"));
            updateConfigFromDTO(config, configDTO);
        } else {
            // Create new config - deactivate existing ones first
            patientAIConfigRepository.findByPatientId(configDTO.getPatientId())
                    .forEach(existingConfig -> {
                        existingConfig.setIsActive(false);
                        patientAIConfigRepository.save(existingConfig);
                    });
            
            config = convertToEntity(configDTO);
        }
        
        PatientAIConfig savedConfig = patientAIConfigRepository.save(config);
        return convertToDTO(savedConfig);
    }
    
    @Transactional
    public void deactivatePatientAIConfig(Long patientId) {
        PatientAIConfig config = patientAIConfigRepository.findByPatientIdAndIsActiveTrue(patientId)
                .orElseThrow(() -> new IllegalArgumentException("AI configuration not found for patient"));
        
        config.setIsActive(false);
        patientAIConfigRepository.save(config);
    }
    
    private PatientAIConfigDTO convertToDTO(PatientAIConfig config) {
        return PatientAIConfigDTO.builder()
                .id(config.getId())
                .patientId(config.getPatientId())
                .aiProvider(config.getPreferredAiProvider())
                .openaiModel(config.getOpenaiModel())
                .deepseekModel(config.getDeepseekModel())
                .maxTokens(config.getMaxTokens())
                .temperature(config.getTemperature())
                .conversationHistoryLimit(config.getConversationHistoryLimit())
                .includeVitalsByDefault(config.getIncludeVitalsByDefault())
                .includeMedicationsByDefault(config.getIncludeMedicationsByDefault())
                .includeNotesByDefault(config.getIncludeNotesByDefault())
                .includeMoodPainLogsByDefault(config.getIncludeMoodPainByDefault())
                .includeAllergiesByDefault(config.getIncludeAllergiesByDefault())
                .isActive(config.getIsActive())
                .systemPrompt(config.getSystemPrompt())
                .build();
    }
    
    private PatientAIConfig convertToEntity(PatientAIConfigDTO dto) {
        return PatientAIConfig.builder()
                .patientId(dto.getPatientId())
                .preferredAiProvider(dto.getAiProvider())
                .openaiModel(dto.getOpenaiModel() != null ? dto.getOpenaiModel() : "gpt-4")
                .deepseekModel(dto.getDeepseekModel() != null ? dto.getDeepseekModel() : "deepseek-chat")
                .maxTokens(dto.getMaxTokens() != null ? dto.getMaxTokens() : 2000)
                .temperature(dto.getTemperature() != null ? dto.getTemperature() : 0.7)
                .conversationHistoryLimit(dto.getConversationHistoryLimit() != null ? dto.getConversationHistoryLimit() : 20)
                .includeVitalsByDefault(dto.getIncludeVitalsByDefault() != null ? dto.getIncludeVitalsByDefault() : true)
                .includeMedicationsByDefault(dto.getIncludeMedicationsByDefault() != null ? dto.getIncludeMedicationsByDefault() : true)
                .includeNotesByDefault(dto.getIncludeNotesByDefault() != null ? dto.getIncludeNotesByDefault() : true)
                .includeMoodPainByDefault(dto.getIncludeMoodPainLogsByDefault() != null ? dto.getIncludeMoodPainLogsByDefault() : true)
                .includeAllergiesByDefault(dto.getIncludeAllergiesByDefault() != null ? dto.getIncludeAllergiesByDefault() : true)
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .systemPrompt(dto.getSystemPrompt())
                .build();
    }
    
    private void updateConfigFromDTO(PatientAIConfig config, PatientAIConfigDTO dto) {
        config.setPreferredAiProvider(dto.getAiProvider());
        config.setOpenaiModel(dto.getOpenaiModel() != null ? dto.getOpenaiModel() : "gpt-4");
        config.setDeepseekModel(dto.getDeepseekModel() != null ? dto.getDeepseekModel() : "deepseek-chat");
        config.setMaxTokens(dto.getMaxTokens() != null ? dto.getMaxTokens() : 2000);
        config.setTemperature(dto.getTemperature() != null ? dto.getTemperature() : 0.7);
        config.setConversationHistoryLimit(dto.getConversationHistoryLimit() != null ? dto.getConversationHistoryLimit() : 20);
        config.setIncludeVitalsByDefault(dto.getIncludeVitalsByDefault() != null ? dto.getIncludeVitalsByDefault() : true);
        config.setIncludeMedicationsByDefault(dto.getIncludeMedicationsByDefault() != null ? dto.getIncludeMedicationsByDefault() : true);
        config.setIncludeNotesByDefault(dto.getIncludeNotesByDefault() != null ? dto.getIncludeNotesByDefault() : true);
        config.setIncludeMoodPainByDefault(dto.getIncludeMoodPainLogsByDefault() != null ? dto.getIncludeMoodPainLogsByDefault() : true);
        config.setIncludeAllergiesByDefault(dto.getIncludeAllergiesByDefault() != null ? dto.getIncludeAllergiesByDefault() : true);
        config.setSystemPrompt(dto.getSystemPrompt());
        config.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
    }
}
