package com.careconnect.dto;

import com.careconnect.model.Allergy.AllergyType;
import com.careconnect.model.Allergy.AllergySeverity;
import lombok.Builder;

@Builder
public record AllergyDTO(
        Long id,
        Long patientId,
        String allergen,
        AllergyType allergyType,
        AllergySeverity severity,
        String reaction,
        String notes,
        String diagnosedDate,
        Boolean isActive
) {}
