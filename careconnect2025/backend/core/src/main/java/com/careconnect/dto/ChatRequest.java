package com.careconnect.dto;

import com.careconnect.model.ChatConversation;
import com.careconnect.service.MedicalDataAnonymizer.AnonymizationLevel;
import jakarta.validation.constraints.*;
import lombok.*;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRequest {
    
    @NotBlank(message = "Message content is required")
    @Size(max = 5000, message = "Message content cannot exceed 5000 characters")
    private String message;
    
    private String conversationId; // Optional - will create new if not provided
    
    @NotNull(message = "Patient ID is required")
    private Long patientId;
    
    @NotNull(message = "User ID is required")
    private Long userId;
    
    @Builder.Default
    private ChatConversation.ChatType chatType = ChatConversation.ChatType.GENERAL_SUPPORT;
    
    // Context override options
    private Boolean includeVitals;
    private Boolean includeMedications;
    private Boolean includeNotes;
    private Boolean includeMoodPainLogs;
    private Boolean includeAllergies;
    
    // AI Configuration overrides
    private Double temperature;
    private Integer maxTokens;
    private String preferredModel;
    
    // Additional context
    private List<String> additionalContext;
    
    private String title; // Optional conversation title
    
    // Privacy and anonymization settings
    @Builder.Default
    private AnonymizationLevel anonymizationLevel = AnonymizationLevel.MODERATE;
    
    @Builder.Default
    private Boolean enableDifferentialPrivacy = false;
    
    @Builder.Default
    private Boolean statisticalSummaryOnly = false;
    
    @Builder.Default
    private Boolean privacyConsent = false;
    
    private Integer dataRetentionDays; // Override default retention
    
    // Convenience methods for boolean checks
    public boolean isIncludeVitals() {
        return includeVitals != null ? includeVitals : false;
    }
    
    public boolean isIncludeMedications() {
        return includeMedications != null ? includeMedications : false;
    }
    
    public boolean isIncludeNotes() {
        return includeNotes != null ? includeNotes : false;
    }
    
    public boolean isIncludeMoodPainLogs() {
        return includeMoodPainLogs != null ? includeMoodPainLogs : false;
    }
    
    public boolean isIncludeAllergies() {
        return includeAllergies != null ? includeAllergies : false;
    }
    
    public boolean isEnableDifferentialPrivacy() {
        return enableDifferentialPrivacy != null ? enableDifferentialPrivacy : false;
    }
    
    public boolean isStatisticalSummaryOnly() {
        return statisticalSummaryOnly != null ? statisticalSummaryOnly : false;
    }
    
    public boolean isPrivacyConsent() {
        return privacyConsent != null ? privacyConsent : false;
    }
}
