package com.deeptrain.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Data
public class SimulationResponse {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String userId;
    private String questionId;
    private String userAnswer;
    private boolean isCorrect;
    private int score;
    private String feedback;
}
