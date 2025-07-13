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
import org.springframework.transaction.annotation.Transactional;

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
import com.careconnect.repository.FamilyMemberLinkRepository;

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

    @Autowired 
    private  FamilyMemberLinkRepository familyMemberLinkRepository;

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

@Transactional 
public Patient registerPatient(PatientRegistration reg) {
    if (users.existsByEmail(reg.getEmail()))
        throw new RegistrationException("Email already registered");

    // Generate a temporary token for password setup
    String passwordSetupToken = java.util.UUID.randomUUID().toString();

    // Always generate a random password for patient registration
    String password = generateRandomPassword(12);
    String encodedPassword = encoder.encode(password);

    // Create and save the user first to ensure we have an ID
    User user = User.builder()
            .email(reg.getEmail())
            .password(encodedPassword)
            .passwordHash(encodedPassword)
            .role(Role.PATIENT)
            .isVerified(false)
            .verificationToken(passwordSetupToken)
            .createdAt(new java.sql.Timestamp(System.currentTimeMillis()))
            .build();
    
    User savedUser = users.save(user); // Save user first to get ID

    Address addr = reg.getAddress() != null ? toAddress(reg.getAddress()) : null;

    // Build the patient object
    Patient patient = Patient.builder()
            .firstName(reg.getFirstName())
            .lastName(reg.getLastName())
            .dob(reg.getDob())
            .email(reg.getEmail())
            .phone(reg.getPhone())
            .address(addr)
            .user(savedUser) // Use the saved user with ID
            .relationship(reg.getRelationship())
            .build();

    try {
        Patient savedPatient = patientRepository.save(patient);
        
        // Create caregiver-patient link if caregiver is specified
        if (reg.getCaregiverId() != null) {
            Caregiver caregiver = caregiverRepository.findById(reg.getCaregiverId())
                    .orElseThrow(() -> new RegistrationException("Caregiver not found"));
            
            try {
                // Create the permanent link between caregiver and patient
                caregiverPatientLinkService.createPermanentLink(
                    caregiver.getUser().getId(), 
                    savedUser.getId(), 
                    "Patient registered by caregiver"
                );
            } catch (Exception e) {
                throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR,
                    "Failed to establish caregiver-patient relationship");
            }
        }
        
        emailService.sendPasswordSetupEmailWithCredentials(
            reg.getEmail(),
            passwordSetupToken,
            reg.getFirstName(),
            reg.getEmail(),
            password
        );
        
        return savedPatient;
    } catch (Exception e) {
        throw new AppException(HttpStatus.INTERNAL_SERVER_ERROR,
                "Exception occurred while saving patient to the database");
    }
}
      /**
     * Generate a secure random password of the given length
     */
    private String generateRandomPassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=";
        java.security.SecureRandom random = new java.security.SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
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

public boolean hasAccessToPatient(Long userId, Long patientId) {
    User user = users.findById(userId)
        .orElse(null);
    
    if (user == null) {
        return false;
    }
    
    // Check role-specific access
    switch (user.getRole()) {
        case PATIENT:
            // Patient can only access their own data
            return patientRepository.existsByIdAndUserId(patientId, userId);
            
        case CAREGIVER:
            // Use the new query method
            return patientRepository.hasAccessByCaregiverId(patientId, userId);
            
        case FAMILY_MEMBER:
            // Similar check for family members
            return familyMemberLinkRepository.existsByFamilyMemberUserIdAndPatientId(userId, patientId);
            
        case ADMIN:
            return true;
            
        default:
            return false;
    }
}
}