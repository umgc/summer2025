package com.careconnectpt.careconnect2025.dto.auth;

import com.careconnectpt.careconnect2025.dto.shared.AddressDto;

public record PatientRegistration(
        String firstName,
        String lastName,
        String dob,
        AddressDto address,
        Credentials credentials) {}