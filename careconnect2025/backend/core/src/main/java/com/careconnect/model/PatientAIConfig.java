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
    
    @Enumerated(EnumType.STRING)
    @Column(name = "preferred_ai_provider", nullable = false)
    private AIProvider preferredAiProvider = AIProvider.OPENAI;
    
    @Column(name = "openai_model")
    private String openaiModel = "gpt-4";
    
    @Column(name = "deepseek_model")
    private String deepseekModel = "deepseek-chat";
    
    @Column(name = "max_tokens")
    private Integer maxTokens = 2000;
    
    @Column(name = "temperature")
    private Double temperature = 0.7;
    
    @Column(name = "include_vitals_by_default")
    private Boolean includeVitalsByDefault = true;
    
    @Column(name = "include_medications_by_default")
    private Boolean includeMedicationsByDefault = true;
    
    @Column(name = "include_mood_pain_by_default")
    private Boolean includeMoodPainByDefault = true;
    
    @Column(name = "include_notes_by_default")
    private Boolean includeNotesByDefault = true;
    
    @Column(name = "include_allergies_by_default")
    private Boolean includeAllergiesByDefault = true;
    
    @Column(name = "system_prompt", columnDefinition = "TEXT")
    private String systemPrompt;
    
    @Column(name = "conversation_history_limit")
    private Integer conversationHistoryLimit = 20;
    
    @Column(name = "is_active")
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
