package com.deeptrain.mapper;

import com.deeptrain.dto.NodeBlockDto;
import com.deeptrain.model.NodeBlock;

public class NodeBlockMapper {

    public static NodeBlock toEntity(NodeBlockDto dto) {
        return NodeBlock.builder()
                .blockId(dto.getId())
                .type(dto.getType())
                .title(dto.getTitle())
                .offsetX(dto.getOffsetX())
                .offsetY(dto.getOffsetY())
                .welcomeMessage(dto.getWelcomeMessage())
                .lessonType(dto.getLessonType())
                .lessonContent(dto.getLessonContent())
                .estimatedTime(dto.getEstimatedTime())
                .quizTitle(dto.getQuizTitle())
                .passingScore(dto.getPassingScore())
                .timeLimit(dto.getTimeLimit())
                .conditionExpression(dto.getConditionExpression())
                .truePathLabel(dto.getTruePathLabel())
                .falsePathLabel(dto.getFalsePathLabel())
                .checkpointTitle(dto.getCheckpointTitle())
                .checkpointNote(dto.getCheckpointNote())
                .domain(dto.getDomain())
                .build();
    }

    public static NodeBlockDto toDto(NodeBlock entity) {
        NodeBlockDto dto = new NodeBlockDto();
        dto.setId(entity.getBlockId());
        dto.setType(entity.getType());
        dto.setTitle(entity.getTitle());
        dto.setOffsetX(entity.getOffsetX());
        dto.setOffsetY(entity.getOffsetY());
        dto.setWelcomeMessage(entity.getWelcomeMessage());
        dto.setLessonType(entity.getLessonType());
        dto.setLessonContent(entity.getLessonContent());
        dto.setEstimatedTime(entity.getEstimatedTime());
        dto.setQuizTitle(entity.getQuizTitle());
        dto.setPassingScore(entity.getPassingScore());
        dto.setTimeLimit(entity.getTimeLimit());
        dto.setConditionExpression(entity.getConditionExpression());
        dto.setTruePathLabel(entity.getTruePathLabel());
        dto.setFalsePathLabel(entity.getFalsePathLabel());
        dto.setCheckpointTitle(entity.getCheckpointTitle());
        dto.setCheckpointNote(entity.getCheckpointNote());
        dto.setDomain(entity.getDomain());
        return dto;
    }
}
