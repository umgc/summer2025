package com.careconnect.service.v2;

import java.time.Instant;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import java.time.temporal.ChronoUnit;
import com.careconnect.model.v2.Address;
import com.careconnect.dto.v2.AddressDto;
import com.careconnect.dto.v2.CaregiverRegistration;
import com.careconnect.dto.v2.LoginRequest;
import com.careconnect.dto.v2.LoginResponse;
import com.careconnect.dto.v2.PatientRegistration;
import com.careconnect.model.v2.Caregiver;
import com.careconnect.model.v2.Patient;
import com.careconnect.model.v2.ProfessionalInfo;
import com.careconnect.model.v2.User;
import com.careconnect.repository.v2.CaregiverRepository;
import com.careconnect.repository.v2.PatientRepository;
import com.careconnect.repository.v2.UserRepository;
import com.careconnect.security.v2.JwtTokenProvider;
import com.careconnect.security.v2.Role;
import com.careconnectpt.exception.v2.AppException;
import com.careconnectpt.exception.v2.AuthenticationException;
import com.careconnectpt.exception.v2.RegistrationException;
import com.careconnect.dto.v2.ProfessionalInfoDto;
import org.springframework.context.annotation.Profile;

@Profile("v2")
@Service
public class AuthService {

    private final UserRepository users;
    private final PatientRepository patients;
    private final CaregiverRepository caregivers;
    private final PasswordEncoder encoder;
    private final JwtTokenProvider jwt;
    private Long patientId;
    private Long caregiverId;
    public AuthService(UserRepository users,
                       PatientRepository patients,
                       CaregiverRepository caregivers,
                       PasswordEncoder encoder,
                       JwtTokenProvider jwt
                       ) {
        this.users = users;
        this.patients = patients;
        this.caregivers = caregivers;
        this.encoder = encoder;
        this.jwt = jwt;
    }

    /** ───────────────────────────  LOGIN  ─────────────────────────── */
    public LoginResponse login(LoginRequest req) {
    User user = users.findByEmail(req.getEmail())
            .orElseThrow(() -> new AuthenticationException("Invalid credentials"));

    System.out.println("Raw: " + req.getPassword());
    System.out.println("Hash: " + user.getPassword());
    System.out.println("Match: " + encoder.matches(req.getPassword(), user.getPassword()));
    if (!encoder.matches(req.getPassword(), user.getPassword()))
        throw new AuthenticationException("Invalid credentials");

    Long patientId = null;
    Long caregiverId = null;

    switch (user.getRole()) {
        case PATIENT -> {
            Patient patient = patients.findByUser(user).orElse(null);
            if (patient != null) patientId = patient.getId();
        }
        case CAREGIVER -> {
            Caregiver caregiver = caregivers.findByUser(user).orElse(null);
            if (caregiver != null) caregiverId = caregiver.getId();
        }
        // Optionally handle FAMILY_MEMBER, ADMIN, etc.
    }

    return LoginResponse.builder()
            .id(user.getId())
            .email(user.getEmail())
            .role(user.getRole())
            .token(jwt.createToken(user.getEmail(), user.getRole()))
            .patientId(patientId)
            .caregiverId(caregiverId)
            .build();
    }

   public Patient registerPatient(PatientRegistration reg) {
   if (users.existsByEmail(reg.getEmail()))
        throw new RegistrationException("Email already registered");

    User user = User.builder()
            .email(reg.getEmail())
            .password(encoder.encode(reg.getPassword()))
            .role(Role.PATIENT)
            .build();

    Address addr = toAddress(reg.getAddress());

    Caregiver caregiver = null;
    if (reg.getCaregiverId() != null) {
        caregiver = caregivers.findById(reg.getCaregiverId())
                .orElseThrow(() -> new RegistrationException("Caregiver not found"));
    }

    Patient patient = Patient.builder()
            .firstName(reg.getFirstName())
            .lastName(reg.getLastName())
            .dob(reg.getDob())
            .email(reg.getEmail())
            .phone(reg.getPhone())
            .address(addr)
            .user(user)
            .caregiver(caregiver)
            .relationship(reg.getRelationship())
            .build();

    try {
        return patients.save(patient);
     } catch (Exception e) {
        throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR,
                "Exception occurred while saving patient to the database");
     }
    }

    public Caregiver registerCaregiver(CaregiverRegistration reg) {
    if (users.existsByEmail(reg.getCredentials().getEmail()))
        throw new RegistrationException("Email already registered");

    User user = new User();
    user.setEmail(reg.getCredentials().getEmail());
    user.setPassword(encoder.encode(reg.getCredentials().getPassword()));
    user.setRole(Role.CAREGIVER);

    Address addr = toAddress(reg.getAddress());

    ProfessionalInfoDto profDto = reg.getProfessional();
    ProfessionalInfo prof = new ProfessionalInfo();
    prof.setLicenseNumber(profDto.getLicenseNumber());
    prof.setIssuingState(profDto.getIssuingState());
    prof.setYearsExperience(profDto.getYearsExperience());

    String caregiverType = reg.getCaregiverType();
    if (caregiverType == null || caregiverType.isBlank()) {
        caregiverType = "PROFESSIONAL";
    }

    Caregiver cg = Caregiver.builder()
            .firstName(reg.getFirstName())
            .lastName(reg.getLastName())
            .dob(reg.getDob())
            .email(reg.getCredentials().getEmail())
            .phone(reg.getPhone())
            .professional(prof)
            .address(addr)
            .user(user)
            .caregiverType(caregiverType)
            .build();

    try {
        return caregivers.save(cg);
    } catch (Exception e) {
        throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR,
                "Exception occurred while saving caregiver to the database");
    }
}
        
//        String token = UUID.randomUUID().toString();
//        EmailVerificationToken vt = new EmailVerificationToken(
//                token, user, Instant.now().plus(24, ChronoUnit.HOURS));
//        tokens.save(vt);
//        
//        String frontEndUrl = "";
//        String confirmLink = frontEndUrl + "/verify-email?token=" + token;
//        emailService.sendTextMail(                    // Your existing mail service
//                user.getEmail(),
//                "Confirm your CareConnect account",
//                """
//                Welcome to CareConnect!
//                
//                Please click the link below to activate your account:
//                
//                %s
//                
//                This link is valid for 24 hours.
//                """.formatted(confirmLink)
//        );

    /** ───────────────────────  helper  ────────────────────────────── */
    private Address toAddress(AddressDto dto) {

        return Address.builder()
                .line1(dto.line1())
                .line2(dto.line2())
                .city(dto.city())
                .state(dto.state())
                .zip(dto.zip())
                .build();
    }

    public void logout(String token) {
        // In a stateless JWT-based system, logout is typically handled on the client side.
        // However, if we want to implement token invalidation, we can maintain a blacklist or use a cache.
        // This is a placeholder for future implementation if needed.
    }
}