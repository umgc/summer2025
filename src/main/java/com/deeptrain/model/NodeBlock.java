package com.deeptrain.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "node_blocks")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NodeBlock {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String blockId; // Matches NodeBlockDto.id
    private String type;
    private String title;
    private float offsetX;
    private float offsetY;

    private String welcomeMessage;
    private String lessonType;
    private String lessonContent;
    private String estimatedTime;
    private String quizTitle;
    private String passingScore;
    private String timeLimit;
    private String conditionExpression;
    private String truePathLabel;
    private String falsePathLabel;
    private String checkpointTitle;
    private String checkpointNote;
    private String domain;
}
