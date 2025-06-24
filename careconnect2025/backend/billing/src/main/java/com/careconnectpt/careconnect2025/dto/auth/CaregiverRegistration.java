package com.careconnectpt.careconnect2025.dto.auth;

import com.careconnectpt.careconnect2025.dto.shared.AddressDto;
import com.careconnectpt.careconnect2025.dto.shared.ProfessionalInfoDto;

public record CaregiverRegistration(
        String firstName,
        String lastName,
        String dob,
        ProfessionalInfoDto professional,
        AddressDto address,
        Credentials credentials) {}
