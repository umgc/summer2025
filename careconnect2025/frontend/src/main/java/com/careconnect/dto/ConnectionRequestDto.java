package com.careconnect.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConnectionRequestDto {
    private Long caregiverId;
    private String patientEmail;
    private String relationshipType;
    private String message;
}