package com.careconnect.service;

import com.careconnect.model.Caregiver;
import com.careconnect.model.Patient;
import com.careconnect.repository.CaregiverRepository;
import com.careconnect.repository.PatientRepository;
import com.careconnect.dto.CaregiverRegistration;
import com.careconnect.dto.PatientRegistration;
import com.careconnect.dto.CaregiverPatientLinkResponse;
import com.careconnect.exception.RegistrationException;
import com.careconnect.exception.AppException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.careconnect.model.User;
import com.careconnect.repository.PatientRepository;
import com.careconnect.model.ProfessionalInfo;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.JwtTokenProvider;
import com.careconnect.security.Role;
import com.careconnect.dto.ProfessionalInfoDto;
import com.careconnect.dto.AddressDto;
import com.careconnect.model.Address;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.http.HttpStatus;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class CaregiverService {

    @Autowired
    private CaregiverRepository caregiverRepository;

    @Autowired
    private PatientRepository patientRepository;

    @Autowired
    private UserRepository users;

    @Autowired
    private PasswordEncoder encoder;

    @Autowired
    private JwtTokenProvider jwt;

    @Autowired
    private EmailService emailService;

    @Autowired
    private CaregiverPatientLinkService caregiverPatientLinkService;

    // 1. List patients under a caregiver, with optional filtering (ACTIVE links only)
    public List<Patient> getPatientsByCaregiver(Long caregiverId, String email, String name) {
        // Get caregiver user
        Caregiver caregiver = getCaregiverById(caregiverId);
        User caregiverUser = caregiver.getUser();
        
        // Get active patient links via CaregiverPatientLinkService
        List<CaregiverPatientLinkResponse> activeLinks = caregiverPatientLinkService.getPatientsByCaregiver(caregiverUser.getId());
        
        // Extract patient user IDs from active links and get Patient objects
        List<Patient> patients = activeLinks.stream()
                .map(link -> users.findById(link.patientUserId()))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .map(user -> patientRepository.findByUser(user))
                .filter(Optional::isPresent)
                .map(Optional::get)
                .collect(Collectors.toList());

        // Apply filters
        if (email != null && !email.isEmpty()) {
            patients = patients.stream()
                    .filter(p -> p.getEmail() != null && p.getEmail().equalsIgnoreCase(email))
                    .collect(Collectors.toList());
        }
        if (name != null && !name.isEmpty()) {
            patients = patients.stream()
                    .filter(p -> (p.getFirstName() + " " + p.getLastName()).toLowerCase().contains(name.toLowerCase()))
                    .collect(Collectors.toList());
        }
        return patients;
    }

    // 2. Get caregiver details
    public Caregiver getCaregiverById(Long caregiverId) {
        return caregiverRepository.findById(caregiverId)
                .orElseThrow(() -> new RuntimeException("Caregiver not found"));
    }

public Caregiver updateCaregiver(Long caregiverId, Caregiver updatedCaregiver) {
    Caregiver existing = caregiverRepository.findById(caregiverId)
        .orElseThrow(() -> new RuntimeException("Caregiver not found"));
    existing.setFirstName(updatedCaregiver.getFirstName());
    existing.setLastName(updatedCaregiver.getLastName());
    existing.setDob(updatedCaregiver.getDob());
    existing.setEmail(updatedCaregiver.getEmail());
    existing.setPhone(updatedCaregiver.getPhone());
    existing.setAddress(updatedCaregiver.getAddress());
    existing.setProfessional(updatedCaregiver.getProfessional());
    existing.setCaregiverType(updatedCaregiver.getCaregiverType()); 
    return caregiverRepository.save(existing);
}

public Patient registerPatient(PatientRegistration reg) {
   if (users.existsByEmail(reg.getEmail()))
        throw new RegistrationException("Email already registered");

    // Generate a temporary token for password setup
    String passwordSetupToken = java.util.UUID.randomUUID().toString();

    User user = User.builder()
            .email(reg.getEmail())
            .passwordHash(null) // No password hash initially
            .role(Role.PATIENT)
            .isVerified(false) // Not verified until password is set
            .verificationToken(passwordSetupToken) // Use this token for password setup
            .build();

    Address addr = toAddress(reg.getAddress());

    Caregiver caregiver = null;
    if (reg.getCaregiverId() != null) {
        caregiver = caregiverRepository.findById(reg.getCaregiverId())
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
            .relationship(reg.getRelationship())
            .build();

    try {
        Patient savedPatient = patientRepository.save(patient);
        
        // Create caregiver-patient link if caregiver is specified
        if (caregiver != null) {
            caregiverPatientLinkService.createPermanentLink(caregiver.getUser().getId(), savedPatient.getUser().getId(), "Patient registered by caregiver");
        }
        
        // Send password setup email to patient
        emailService.sendPasswordSetupEmail(reg.getEmail(), passwordSetupToken, reg.getFirstName());
        
        return savedPatient;
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
    String encodedPassword = encoder.encode(reg.getCredentials().getPassword());
    user.setPassword(encodedPassword);
    user.setPasswordHash(encodedPassword);
    user.setRole(Role.CAREGIVER);

    Address addr = toAddress(reg.getAddress());

    ProfessionalInfoDto profDto = reg.getProfessional();
    ProfessionalInfo prof = new ProfessionalInfo();
    if (profDto != null) {
        prof.setLicenseNumber(profDto.getLicenseNumber());
        prof.setIssuingState(profDto.getIssuingState());
        prof.setYearsExperience(profDto.getYearsExperience());
    }

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
        return caregiverRepository.save(cg);
    } catch (Exception e) {
        throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR,
                "Exception occurred while saving caregiver to the database");
    }
}

    private Address toAddress(AddressDto dto) {

        return Address.builder()
                .line1(dto.line1())
                .line2(dto.line2())
                .city(dto.city())
                .state(dto.state())
                .zip(dto.zip())
                .build();
    }
}