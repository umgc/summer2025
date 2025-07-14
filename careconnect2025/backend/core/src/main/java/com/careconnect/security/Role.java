package com.careconnect.security;

public enum Role {
    PATIENT, CAREGIVER, ADMIN, FAMILY_MEMBER;

    // Safe converter with case-insensitive match and custom exception

    public static Role fromString(String value) {
        if (value == null) {
            throw new IllegalArgumentException("Role value cannot be null");
        }
        for (Role role : Role.values()) {
            if (role.name().equalsIgnoreCase(value.trim())) {
                return role;
            }
        }
        throw new IllegalArgumentException("No enum constant for Role: " + value);
    }
}