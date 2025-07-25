package com.careconnect.dto;

import com.careconnect.model.PatientAIConfig.AIProvider;
import jakarta.validation.constraints.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PatientAIConfigDTO {
    
    private Long id;
    
    @NotNull(message = "Patient ID is required")
    private Long patientId;
    
    @NotNull(message = "AI provider is required")
    private AIProvider aiProvider;
    
    private String openaiModel;
    private String deepseekModel;
    
    @Min(value = 100, message = "Max tokens must be at least 100")
    @Max(value = 8000, message = "Max tokens cannot exceed 8000")
    private Integer maxTokens;
    
    @DecimalMin(value = "0.0", message = "Temperature must be between 0.0 and 2.0")
    @DecimalMax(value = "2.0", message = "Temperature must be between 0.0 and 2.0")
    private Double temperature;
    
    @Min(value = 5, message = "Conversation history limit must be at least 5")
    @Max(value = 100, message = "Conversation history limit cannot exceed 100")
    private Integer conversationHistoryLimit;
    
    // Default context inclusion preferences
    private Boolean includeVitalsByDefault;
    private Boolean includeMedicationsByDefault;
    private Boolean includeNotesByDefault;
    private Boolean includeMoodPainLogsByDefault;
    private Boolean includeAllergiesByDefault;
    
    private Boolean isActive;
    
    private String systemPrompt;
}
