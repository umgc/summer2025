package com.careconnect.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "user_achievements")
public class UserAchievement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "user_id")
    private Long userId;

    @ManyToOne
    @JoinColumn(name = "achievement_id")
    private Achievement achievement;

    private LocalDateTime earnedAt = LocalDateTime.now();

    // Explicit setters to ensure compilation works if Lombok isn't processing
    public void setUserId(Long userId) { this.userId = userId; }
    public void setAchievement(Achievement achievement) { this.achievement = achievement; }
    public void setEarnedAt(LocalDateTime earnedAt) { this.earnedAt = earnedAt; }

    // Explicit getters to ensure compilation works if Lombok isn't processing
    public Achievement getAchievement() { return achievement; }
    public Long getUserId() { return userId; }
    public LocalDateTime getEarnedAt() { return earnedAt; }
}
