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
    
    @Builder.Default
    private String openaiModel = "gpt-4";
    @Builder.Default
    private String deepseekModel = "deepseek-chat";

    @Min(value = 100, message = "Max tokens must be at least 100")
    @Max(value = 8000, message = "Max tokens cannot exceed 8000")
    @Builder.Default
    private Integer maxTokens = 2000;

    @DecimalMin(value = "0.0", message = "Temperature must be between 0.0 and 2.0")
    @DecimalMax(value = "2.0", message = "Temperature must be between 0.0 and 2.0")
    @Builder.Default
    private Double temperature = 0.7;

    @Min(value = 5, message = "Conversation history limit must be at least 5")
    @Max(value = 100, message = "Conversation history limit cannot exceed 100")
    @Builder.Default
    private Integer conversationHistoryLimit = 20;

    // Default context inclusion preferences
    @Builder.Default
    private Boolean includeVitalsByDefault = true;
    @Builder.Default
    private Boolean includeMedicationsByDefault = true;
    @Builder.Default
    private Boolean includeNotesByDefault = true;
    @Builder.Default
    private Boolean includeMoodPainLogsByDefault = true;
    @Builder.Default
    private Boolean includeAllergiesByDefault = true;

    @Builder.Default
    private Boolean isActive = true;

    private String systemPrompt;
}
