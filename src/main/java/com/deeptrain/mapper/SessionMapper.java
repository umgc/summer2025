package com.deeptrain.mapper;

import com.deeptrain.dto.SessionDto;
import com.deeptrain.model.Session;

public class SessionMapper {
    public static SessionDto toDto(Session session) {
        SessionDto dto = new SessionDto();
        dto.setSessionId(session.getSessionId());
        return dto;
    }

    public static Session toEntity(SessionDto dto) {
        Session session = new Session();
        session.setSessionId(dto.getSessionId());
        return session;
    }
}
