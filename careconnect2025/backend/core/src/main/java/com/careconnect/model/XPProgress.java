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
@Table(name = "xp_progress")
public class XPProgress {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private int xp;

    private int level;

    @Column(name = "user_id")
    private Long userId;

    private LocalDateTime updatedAt = LocalDateTime.now();

    // Explicit setters to ensure compilation works if Lombok isn't processing
    public void setUserId(Long userId) { this.userId = userId; }
    public void setXp(int xp) { this.xp = xp; }
    public void setLevel(int level) { this.level = level; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    // Explicit getters to ensure compilation works if Lombok isn't processing
    public int getXp() { return xp; }
    public int getLevel() { return level; }
    public Long getUserId() { return userId; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }

    // Getters and Setters
}
