package com.careconnect.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;

@Entity
@Table(name = "patient_allergy")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Allergy {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "patient_id", nullable = false)
    private Patient patient;
    
    @Column(name = "allergen", nullable = false)
    private String allergen; // e.g., "Peanuts", "Penicillin", "Latex"
    
    @Column(name = "allergy_type")
    @Enumerated(EnumType.STRING)
    private AllergyType allergyType;
    
    @Column(name = "severity")
    @Enumerated(EnumType.STRING)
    private AllergySeverity severity;
    
    @Column(name = "reaction", columnDefinition = "TEXT")
    private String reaction; // Description of reaction (e.g., "Hives, difficulty breathing")
    
    @Column(name = "notes", columnDefinition = "TEXT")
    private String notes; // Additional notes from healthcare provider
    
    @Column(name = "diagnosed_date")
    private String diagnosedDate; // When allergy was first diagnosed
    
    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true; // Whether allergy is still active
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
    
    @Column(name = "updated_at")
    private Instant updatedAt;
    
    @PrePersist
    protected void onCreate() {
        Instant now = Instant.now();
        this.createdAt = now;
        this.updatedAt = now;
        if (this.isActive == null) {
            this.isActive = true;
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }
    
    public enum AllergyType {
        FOOD("Food Allergy"),
        MEDICATION("Medication Allergy"),
        ENVIRONMENTAL("Environmental Allergy"),
        CONTACT("Contact Allergy"),
        SEASONAL("Seasonal Allergy"),
        OTHER("Other");
        
        private final String displayName;
        
        AllergyType(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    public enum AllergySeverity {
        MILD("Mild"),
        MODERATE("Moderate"),
        SEVERE("Severe"),
        LIFE_THREATENING("Life-threatening");
        
        private final String displayName;
        
        AllergySeverity(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
}
