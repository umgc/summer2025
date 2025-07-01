package com.deeptrain.mapper;

import com.deeptrain.model.StudentStat;
import com.deeptrain.dto.StudentStatDto;

public class StudentStatMapper {

    public static StudentStatDto toDto(StudentStat entity) {
        return new StudentStatDto(
            entity.getTitle(),
            entity.getValue(),
            entity.getChange(),
            entity.getIcon()
        );
    }

    public static StudentStat toEntity(StudentStatDto dto) {
        StudentStat entity = new StudentStat();
        entity.setTitle(dto.getTitle());
        entity.setValue(dto.getValue());
        entity.setChange(dto.getChange());
        entity.setIcon(dto.getIcon());
        return entity;
    }
}
