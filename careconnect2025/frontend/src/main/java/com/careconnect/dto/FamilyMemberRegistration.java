package com.careconnect.dto;

public record FamilyMemberRegistration(
    String firstName,
    String lastName,
    String email,
    String phone,
    AddressDto address,
    String relationship,
    Long patientUserId
) {}
