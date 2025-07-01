package com.deeptrain.model;

import com.deeptrain.dto.SessionDto;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import lombok.*;

@Entity
@Data
public class Session {
    @Id
    private String sessionId;

    public SessionDto startSession(String sessionId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public void clearSession(String sessionId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    public SessionDto getSession(String sessionId) {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}
