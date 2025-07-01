package com.deeptrain.dto;

import lombok.Data;

@Data
public class NodeBlockDto {
    private String id;
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
