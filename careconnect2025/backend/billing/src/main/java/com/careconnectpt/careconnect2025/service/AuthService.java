package com.careconnectpt.careconnect2025.service;

import com.careconnectpt.careconnect2025.dto.auth.*;
import com.careconnectpt.careconnect2025.dto.shared.AddressDto;
import com.careconnectpt.careconnect2025.model.user.*;
import com.careconnectpt.careconnect2025.repository.*;
import com.careconnectpt.careconnect2025.security.JwtTokenProvider;
import com.careconnectpt.careconnect2025.security.Role;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository users;
    private final PatientRepository patients;
    private final CaregiverRepository caregivers;
    private final PasswordEncoder encoder;
    private final JwtTokenProvider jwt;

    public AuthService(UserRepository users,
                       PatientRepository patients,
                       CaregiverRepository caregivers,
                       PasswordEncoder encoder,
                       JwtTokenProvider jwt) {
        this.users = users;
        this.patients = patients;
        this.caregivers = caregivers;
        this.encoder = encoder;
        this.jwt = jwt;
    }

    /** ───────────────────────────  LOGIN  ─────────────────────────── */
    public TokenDto login(LoginRequest req) {
        User user = users.findByEmail(req.email())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!encoder.matches(req.password(), user.getPassword()))
            throw new RuntimeException("Invalid credentials");

        return new TokenDto(jwt.createToken(user.getEmail(), user.getRole()));
    }

    /** ─────────────────────  PATIENT SIGN-UP  ─────────────────────── */
    public void registerPatient(PatientRegistration reg) {
        if (users.existsByEmail(reg.credentials().email()))
            throw new RuntimeException("Email already registered");

        /* ---------- User ---------- */
        User user = new User(null, null, null, null);
        user.setEmail(reg.credentials().email());
        user.setPassword(encoder.encode(reg.credentials().password()));
        user.setRole(Role.PATIENT);

        /* ---------- Address ---------- */
        Address addr = toAddress(reg.address());

        /* ---------- Patient ---------- */
        Patient patient = new Patient();
        patient.setFirstName(reg.firstName());
        patient.setLastName(reg.lastName());
        patient.setDob(reg.dob());
        patient.setAddress(addr);
        patient.setUser(user);

        patients.save(patient);              // cascades to User & Address
    }

    /** ────────────────────  CARE-GIVER SIGN-UP  ───────────────────── */
    public void registerCaregiver(CaregiverRegistration reg) {
        if (users.existsByEmail(reg.credentials().email()))
            throw new RuntimeException("Email already registered");

        /* ---------- User ---------- */
        User user = new User(null, null, null, null);
        user.setEmail(reg.credentials().email());
        user.setPassword(encoder.encode(reg.credentials().password()));
        user.setRole(Role.CAREGIVER);

        /* ---------- Address ---------- */
        Address addr = toAddress(reg.address());

        /* ---------- Professional info ---------- */
        ProfessionalInfo prof = new ProfessionalInfo();
        prof.setLicenseNumber(reg.professional().licenseNumber());
        prof.setIssuingState(reg.professional().issuingState());
        prof.setYearsExperience(reg.professional().yearsExperience());

        /* ---------- Care-giver ---------- */
        Caregiver cg = new Caregiver();
        cg.setFirstName(reg.firstName());
        cg.setLastName(reg.lastName());
        cg.setDob(reg.dob());
        cg.setProfessional(prof);
        cg.setAddress(addr);
        cg.setUser(user);

        caregivers.save(cg);
    }

    /** ───────────────────────  helper  ────────────────────────────── */
    private Address toAddress(AddressDto dto) {
        Address a = new Address();
        a.setLine1(dto.line1());
        a.setLine2(dto.line2());
        a.setCity(dto.city());
        a.setState(dto.state());
        a.setZip(dto.zip());
        a.setPhone(dto.phone());
        return a;
    }
}
