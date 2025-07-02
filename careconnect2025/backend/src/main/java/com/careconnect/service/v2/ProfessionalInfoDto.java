package com.careconnect.service.v2;

import com.careconnect.repository.v2.*;
import com.careconnect.security.v2.JwtTokenProvider;
import com.careconnect.security.v2.Role;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

public record ProfessionalInfoDto(String licenseNumber, String issuingState, int yearsExperience) {}
