package com.careconnect.dto;

import com.careconnect.model.Patient;

public record PatientWithLinkDto(
    Patient patient,
    CaregiverPatientLinkResponse link
) {}
