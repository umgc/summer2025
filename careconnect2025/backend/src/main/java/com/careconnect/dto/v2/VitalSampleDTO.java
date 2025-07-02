package com.careconnect.dto.v2;

import lombok.Builder;

import java.time.Instant;
import java.util.List;

@Builder
public record VitalSampleDTO(
        Long patientId,
        Instant timestamp,
        Double heartRate,
        Double spo2,
        Integer systolic,
        Integer diastolic,
        Double weight
) {}