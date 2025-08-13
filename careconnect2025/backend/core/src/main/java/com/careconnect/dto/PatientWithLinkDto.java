package com.careconnect.dto;

public record PatientWithLinkDto(
    PatientSummaryDTO patient,
    CaregiverPatientLinkResponse link
) {}
