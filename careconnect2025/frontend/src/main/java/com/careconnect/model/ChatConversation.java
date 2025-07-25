package com.careconnect.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Entity
@Table(name = "chat_conversations")
public class ChatConversation {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "conversation_id", unique = true, nullable = false)
    private String conversationId; // UUID for namespace isolation
    
    @Column(name = "patient_id", nullable = false)
    private Long patientId;
    
    @Column(name = "user_id", nullable = false)
    private Long userId; // Who initiated the chat (patient, caregiver, family)
    
    @Enumerated(EnumType.STRING)
    @Column(name = "chat_type")
    private ChatType chatType;
    
    @Column(name = "title")
    private String title;
    
    @Enumerated(EnumType.STRING)
    @Column(name = "ai_provider_used")
    private PatientAIConfig.AIProvider aiProviderUsed;
    
    @Column(name = "ai_model_used")
    private String aiModelUsed;
    
    @Column(name = "total_tokens_used")
    private Integer totalTokensUsed = 0;
    
    @Column(name = "is_active")
    private Boolean isActive = true;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private List<ChatMessage> messages;
    
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
    
    public enum ChatType {
        MEDICAL_CONSULTATION("Medical Consultation"),
        GENERAL_SUPPORT("General Support"),
        MEDICATION_INQUIRY("Medication Inquiry"),
        MOOD_PAIN_SUPPORT("Mood & Pain Support"),
        EMERGENCY_GUIDANCE("Emergency Guidance"),
        LIFESTYLE_ADVICE("Lifestyle Advice");
        
        private final String displayName;
        
        ChatType(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
}
