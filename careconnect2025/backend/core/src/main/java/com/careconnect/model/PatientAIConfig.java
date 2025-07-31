package com.careconnect.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "patient_ai_config")
public class PatientAIConfig {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "patient_id", nullable = false, unique = true)
    private Long patientId;
    // Explicit getters and setters for compatibility
    public Long getPatientId() { return patientId; }
    public void setPatientId(Long patientId) { this.patientId = patientId; }
    public AIProvider getPreferredAiProvider() { return preferredAiProvider; }
    public void setPreferredAiProvider(AIProvider preferredAiProvider) { this.preferredAiProvider = preferredAiProvider; }
    public String getOpenaiModel() { return openaiModel; }
    public void setOpenaiModel(String openaiModel) { this.openaiModel = openaiModel; }
    public String getDeepseekModel() { return deepseekModel; }
    public void setDeepseekModel(String deepseekModel) { this.deepseekModel = deepseekModel; }
    public Integer getMaxTokens() { return maxTokens; }
    public void setMaxTokens(Integer maxTokens) { this.maxTokens = maxTokens; }
    public Double getTemperature() { return temperature; }
    public void setTemperature(Double temperature) { this.temperature = temperature; }
    public Boolean getIncludeVitalsByDefault() { return includeVitalsByDefault; }
    public void setIncludeVitalsByDefault(Boolean includeVitalsByDefault) { this.includeVitalsByDefault = includeVitalsByDefault; }
    public Boolean getIncludeMedicationsByDefault() { return includeMedicationsByDefault; }
    public void setIncludeMedicationsByDefault(Boolean includeMedicationsByDefault) { this.includeMedicationsByDefault = includeMedicationsByDefault; }
    public Boolean getIncludeMoodPainByDefault() { return includeMoodPainByDefault; }
    public void setIncludeMoodPainByDefault(Boolean includeMoodPainByDefault) { this.includeMoodPainByDefault = includeMoodPainByDefault; }
    public Boolean getIncludeNotesByDefault() { return includeNotesByDefault; }
    public void setIncludeNotesByDefault(Boolean includeNotesByDefault) { this.includeNotesByDefault = includeNotesByDefault; }
    public Boolean getIncludeAllergiesByDefault() { return includeAllergiesByDefault; }
    public void setIncludeAllergiesByDefault(Boolean includeAllergiesByDefault) { this.includeAllergiesByDefault = includeAllergiesByDefault; }
    public Integer getConversationHistoryLimit() { return conversationHistoryLimit; }
    public void setConversationHistoryLimit(Integer conversationHistoryLimit) { this.conversationHistoryLimit = conversationHistoryLimit; }
    
    @Enumerated(EnumType.STRING)
    @Column(name = "preferred_ai_provider", nullable = false)
    @Builder.Default
    private AIProvider preferredAiProvider = AIProvider.OPENAI;
    
    @Column(name = "openai_model")
    @Builder.Default
    private String openaiModel = "gpt-4";
    
    @Column(name = "deepseek_model")
    @Builder.Default
    private String deepseekModel = "deepseek-chat";
    
    @Column(name = "max_tokens")
    @Builder.Default
    private Integer maxTokens = 2000;
    
    @Column(name = "temperature")
    @Builder.Default
    private Double temperature = 0.7;
    
    @Column(name = "include_vitals_by_default")
    @Builder.Default
    private Boolean includeVitalsByDefault = true;
    
    @Column(name = "include_medications_by_default")
    @Builder.Default
    private Boolean includeMedicationsByDefault = true;
    
    @Column(name = "include_mood_pain_by_default")
    @Builder.Default
    private Boolean includeMoodPainByDefault = true;
    
    @Column(name = "include_notes_by_default")
    @Builder.Default
    private Boolean includeNotesByDefault = true;
    
    @Column(name = "include_allergies_by_default")
    @Builder.Default
    private Boolean includeAllergiesByDefault = true;
    
    @Column(name = "system_prompt", columnDefinition = "TEXT")
    private String systemPrompt;
    
    @Column(name = "conversation_history_limit")
    @Builder.Default
    private Integer conversationHistoryLimit = 20;
    
    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        LocalDateTime now = LocalDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
    }
    
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
    
    public enum AIProvider {
        OPENAI("OpenAI"),
        DEEPSEEK("DeepSeek");
        
        private final String displayName;
        
        AIProvider(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
}
