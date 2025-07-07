package com.deeptrain.model;
import java.util.List;
import java.util.Map;

import com.deeptrain.util.MapToJsonConverter;

import jakarta.persistence.Convert;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "node_blocks")
public class NodeBlock {

    @Id
    private String id;

    private float offsetX;
    private float offsetY;
    private String title;
    private String type;
    private String description;

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

    @Convert(converter = MapToJsonConverter.class)
    @ElementCollection
    private List<Map<String, String>> questions;
}