package com.careconnect.dto;

import lombok.Data;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Metrics {
    private Long id;
    private String metricType;
    private Double value;
    private String unit;
    private LocalDateTime timestamp;
    private Long patientId;
    private String source; // "fitbit", "manual", etc.
}
