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
    
    private final PatientAIConfigRepository patientAIConfigRepository;
    
    public PatientAIConfigDTO getPatientAIConfig(Long patientId) {
        PatientAIConfig config = patientAIConfigRepository.findByPatientIdAndIsActiveTrue(patientId)
                .orElseThrow(() -> new IllegalArgumentException("AI configuration not found for patient"));
        
        return convertToDTO(config);
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
                .openaiModel(dto.getOpenaiModel())
                .deepseekModel(dto.getDeepseekModel())
                .maxTokens(dto.getMaxTokens())
                .temperature(dto.getTemperature())
                .conversationHistoryLimit(dto.getConversationHistoryLimit())
                .includeVitalsByDefault(dto.getIncludeVitalsByDefault())
                .includeMedicationsByDefault(dto.getIncludeMedicationsByDefault())
                .includeNotesByDefault(dto.getIncludeNotesByDefault())
                .includeMoodPainByDefault(dto.getIncludeMoodPainLogsByDefault())
                .includeAllergiesByDefault(dto.getIncludeAllergiesByDefault())
                .isActive(dto.getIsActive() != null ? dto.getIsActive() : true)
                .systemPrompt(dto.getSystemPrompt())
                .build();
    }
    
    private void updateConfigFromDTO(PatientAIConfig config, PatientAIConfigDTO dto) {
        config.setPreferredAiProvider(dto.getAiProvider());
        config.setOpenaiModel(dto.getOpenaiModel());
        config.setDeepseekModel(dto.getDeepseekModel());
        config.setMaxTokens(dto.getMaxTokens());
        config.setTemperature(dto.getTemperature());
        config.setConversationHistoryLimit(dto.getConversationHistoryLimit());
        config.setIncludeVitalsByDefault(dto.getIncludeVitalsByDefault());
        config.setIncludeMedicationsByDefault(dto.getIncludeMedicationsByDefault());
        config.setIncludeNotesByDefault(dto.getIncludeNotesByDefault());
        config.setIncludeMoodPainByDefault(dto.getIncludeMoodPainLogsByDefault());
        config.setIncludeAllergiesByDefault(dto.getIncludeAllergiesByDefault());
        config.setSystemPrompt(dto.getSystemPrompt());
        if (dto.getIsActive() != null) {
            config.setIsActive(dto.getIsActive());
        }
    }
}
