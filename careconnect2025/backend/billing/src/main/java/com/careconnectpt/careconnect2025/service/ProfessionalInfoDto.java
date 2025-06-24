package com.careconnectpt.careconnect2025.service;

import com.careconnectpt.careconnect2025.model.user.*;
import com.careconnectpt.careconnect2025.repository.*;
import com.careconnectpt.careconnect2025.security.JwtTokenProvider;
import com.careconnectpt.careconnect2025.security.Role;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

public record ProfessionalInfoDto(String licenseNumber, String issuingState, int yearsExperience) {}
