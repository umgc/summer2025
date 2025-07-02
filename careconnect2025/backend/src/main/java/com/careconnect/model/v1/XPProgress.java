package com.careconnect.model.v1;

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

    // Getters and Setters
}
