package com.careconnect.controller;

import com.careconnect.dto.FamilyMemberLinkResponse;
import com.careconnect.dto.FamilyMemberRegistration;
import com.careconnect.dto.MoodPainAnalyticsDTO;
import com.careconnect.dto.MoodPainLogRequest;
import com.careconnect.dto.MoodPainLogResponse;
import com.careconnect.exception.AppException;
import com.careconnect.model.Caregiver;
import com.careconnect.model.Patient;
import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.Role;
import com.careconnect.service.CaregiverPatientLinkService;
import com.careconnect.service.FamilyMemberService;
import com.careconnect.service.MoodPainLogService;
import com.careconnect.service.PatientService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.format.annotation.DateTimeFormat;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/v1/api/patients")
@Tag(name = "Patient Management", description = "Patient management endpoints including mood & pain logging")
@SecurityRequirement(name = "Bearer Authentication")
public class PatientController {

    private static final Logger log = LoggerFactory.getLogger(PatientController.class);

    @Autowired
    private PatientService patientService;

    @Autowired
    private FamilyMemberService familyMemberService;

    @Autowired
    private CaregiverPatientLinkService caregiverPatientLinkService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private MoodPainLogService moodPainLogService;

    // Helper method to get current user
    private User getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String userEmail = authentication.getName(); // JWT contains email as subject
        return userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new AppException(HttpStatus.UNAUTHORIZED, "User not authenticated"));
    }

    // Helper method to check if user has access to patient
    private void validatePatientAccess(Long patientUserId, User currentUser) {
        log.debug("validatePatientAccess - patientUserId={}, currentUser: id={}, role={}", 
                  patientUserId, currentUser.getId(), currentUser.getRole());
        
        switch (currentUser.getRole()) {
            case PATIENT:
                // Patients can only access their own data
                log.debug("PATIENT role validation - checking if currentUser.id {} equals patientUserId {}", 
                          currentUser.getId(), patientUserId);
                if (!currentUser.getId().equals(patientUserId)) {
                    log.warn("Access denied - Patient {} tried to access patient {}", 
                             currentUser.getId(), patientUserId);
                    throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
                }
                log.debug("Access granted - Patient accessing their own data");
                break;
            case CAREGIVER:
                // Caregivers can access patients they're linked to (ACTIVE and not expired)
                boolean caregiverHasAccess = caregiverPatientLinkService.hasAccessToPatient(currentUser.getId(), patientUserId);
                log.debug("CAREGIVER role validation - hasAccess={}", caregiverHasAccess);
                if (!caregiverHasAccess) {
                    log.warn("Access denied - Caregiver {} has no active link to patient {}", 
                             currentUser.getId(), patientUserId);
                    throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
                }
                log.debug("Access granted - Caregiver has active link to patient");
                break;
            case FAMILY_MEMBER:
                // Family members can access patients they're linked to (ACTIVE and not expired)
                boolean familyMemberHasAccess = familyMemberService.hasAccessToPatient(currentUser.getId(), patientUserId);
                log.debug("FAMILY_MEMBER role validation - hasAccess={}", familyMemberHasAccess);
                if (!familyMemberHasAccess) {
                    log.warn("Access denied - Family member {} has no active link to patient {}", 
                             currentUser.getId(), patientUserId);
                    throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
                }
                log.debug("Access granted - Family member has active link to patient");
                break;
            case ADMIN:
                // Admins can access all patients
                log.debug("ADMIN role - access granted");
                break;
            default:
                log.warn("Access denied - Invalid role: {}", currentUser.getRole());
                throw new AppException(HttpStatus.FORBIDDEN, "Access denied");
        }
    }

    // 1. List caregivers associated with a patient
    @GetMapping("/{patientId}/caregivers")
    public ResponseEntity<List<Caregiver>> getCaregiversByPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        
        // Convert patientId to userId for validation
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        List<Caregiver> caregivers = patientService.getCaregiversByPatient(patientId);
        return ResponseEntity.ok(caregivers);
    }

    // 2. Get patient details
    @GetMapping("/{patientId}")
    public ResponseEntity<Patient> getPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        
        // Get patient and validate access
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        return ResponseEntity.ok(patient);
    }

    @PutMapping("/{patientId}")
    public ResponseEntity<Patient> updatePatient(@PathVariable Long patientId, @RequestBody Patient updatedPatient) {
        User currentUser = getCurrentUser();
        
        // Family members have read-only access, cannot update
        if (currentUser.getRole() == Role.FAMILY_MEMBER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Family members have read-only access");
        }
        
        // Validate access
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        Patient updatedResult = patientService.updatePatient(patientId, updatedPatient);
        return ResponseEntity.ok(updatedResult);
    }

    // 3. Get all family members for a patient
    @GetMapping("/{patientId}/family-members")
    public ResponseEntity<List<FamilyMemberLinkResponse>> getFamilyMembersByPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        log.debug("GET /patients/{}/family-members - Current user: id={}, email={}, role={}", 
                  patientId, currentUser.getId(), currentUser.getEmail(), currentUser.getRole());
        
        // Get patient by patientId to ensure it exists
        Patient patient = patientService.getPatientById(patientId);
        log.debug("Found patient: id={}, userId={}, email={}", 
                  patient.getId(), patient.getUser().getId(), patient.getUser().getEmail());
        
        // Use optimized query with patient_id (no joins needed)
        List<FamilyMemberLinkResponse> familyMembers = familyMemberService.getFamilyMembersByPatientId(patientId);
        log.debug("Retrieved {} family members for patientId={}", familyMembers.size(), patientId);
        return ResponseEntity.ok(familyMembers);
    }

    // 4. Register a new family member for a patient
    @PostMapping("/{patientId}/family-members")
    public ResponseEntity<FamilyMemberLinkResponse> registerFamilyMember(
            @PathVariable Long patientId,
            @RequestBody FamilyMemberRegistration registration) {
        
        User currentUser = getCurrentUser();
        log.debug("POST /patients/{}/family-members - Current user: id={}, email={}, role={}", 
                  patientId, currentUser.getId(), currentUser.getEmail(), currentUser.getRole());
        
        // Only patients and caregivers can register family members, not family members themselves
        if (currentUser.getRole() == Role.FAMILY_MEMBER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Family members cannot register other family members");
        }
        
        // Get patient by patientId and extract user_id
        Patient patient = patientService.getPatientById(patientId);
        log.debug("Found patient: id={}, userId={}, email={}", 
                  patient.getId(), patient.getUser().getId(), patient.getUser().getEmail());
        
        // Create new registration with correct patient user ID
        FamilyMemberRegistration updatedRegistration = new FamilyMemberRegistration(
                registration.firstName(),
                registration.lastName(),
                registration.email(),
                registration.phone(),
                registration.address(),
                registration.relationship(),
                patient.getUser().getId()  // Use patient's user ID, not patient ID
        );
        
        FamilyMemberLinkResponse response = familyMemberService.registerFamilyMember(updatedRegistration, currentUser.getId());
        return ResponseEntity.ok(response);
    }

    // 5. Revoke family member access to a patient
    @DeleteMapping("/family-members/{linkId}")
    public ResponseEntity<Void> revokeFamilyMemberAccess(@PathVariable Long linkId) {
        User currentUser = getCurrentUser();
        
        // Only patients and caregivers can revoke family member access
        if (currentUser.getRole() == Role.FAMILY_MEMBER) {
            throw new AppException(HttpStatus.FORBIDDEN, "Family members cannot revoke access");
        }
        
        familyMemberService.revokeFamilyMemberAccess(linkId, currentUser.getId());
        return ResponseEntity.noContent().build();
    }

    // 6. Get family members for the current patient (convenience endpoint)
    @GetMapping("/family-members")
    @Operation(
        summary = "👨‍👩‍👧‍👦 Get my family members",
        description = "Retrieve all family members linked to the current patient",
        tags = {"Patient Management", "👨‍👩‍👧‍👦 Family Members"}
    )
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Family members retrieved successfully"),
        @ApiResponse(responseCode = "401", description = "Authentication required"),
        @ApiResponse(responseCode = "403", description = "Only patients can view their family members")
    })
    public ResponseEntity<List<FamilyMemberLinkResponse>> getMyFamilyMembers() {
        User currentUser = getCurrentUser();
        log.debug("GET /patients/family-members - Current user: id={}, email={}, role={}", 
                  currentUser.getId(), currentUser.getEmail(), currentUser.getRole());
        
        // Only patients can use this endpoint
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can access this endpoint");
        }
        
        List<FamilyMemberLinkResponse> familyMembers = familyMemberService.getFamilyMembersByPatient(currentUser.getId());
        log.debug("Retrieved {} family members for patient userId={}", familyMembers.size(), currentUser.getId());
        return ResponseEntity.ok(familyMembers);
    }

    // 7. Get current patient's profile
    @GetMapping("/me")
    @Operation(
        summary = "👤 Get my patient profile",
        description = "Retrieve the current patient's profile information",
        tags = {"Patient Management"}
    )
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Patient profile retrieved successfully"),
        @ApiResponse(responseCode = "401", description = "Authentication required"),
        @ApiResponse(responseCode = "403", description = "Only patients can view their profile"),
        @ApiResponse(responseCode = "404", description = "Patient profile not found")
    })
    public ResponseEntity<Patient> getMyProfile() {
        User currentUser = getCurrentUser();
        log.debug("GET /patients/me - Current user: id={}, email={}, role={}", 
                  currentUser.getId(), currentUser.getEmail(), currentUser.getRole());
        
        // Only patients can use this endpoint
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can access this endpoint");
        }
        
        Patient patient = patientService.getPatientById(currentUser.getId());
        log.debug("Retrieved patient profile: id={}, userId={}", patient.getId(), patient.getUser().getId());
        return ResponseEntity.ok(patient);
    }

    // === MOOD & PAIN LOG ENDPOINTS ===

    // 6. Create a new mood pain log entry
    @PostMapping("/mood-pain-log")
    @Operation(
        summary = "📊 Create mood & pain log entry",
        description = """
            Create a new mood and pain log entry for the current patient.
            
            **Requirements:**
            - Must be authenticated as a PATIENT
            - Mood value: 1-10 scale (1 = worst, 10 = best)
            - Pain value: 1-10 scale (1 = no pain, 10 = severe pain)
            - Timestamp cannot be in the future
            
            **Usage:**
            This endpoint allows patients to track their daily mood and pain levels,
            providing valuable data for caregivers and healthcare providers.
            """,
        tags = {"Patient Management", "📊 Mood & Pain Tracking"}
    )
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Mood pain log created successfully",
            content = @Content(mediaType = "application/json", schema = @Schema(implementation = MoodPainLogResponse.class))),
        @ApiResponse(responseCode = "400", description = "Invalid request data"),
        @ApiResponse(responseCode = "401", description = "Authentication required"),
        @ApiResponse(responseCode = "403", description = "Only patients can create mood pain logs")
    })
    public ResponseEntity<MoodPainLogResponse> createMoodPainLog(
            @Parameter(description = "Mood and pain log data", required = true)
            @Valid @RequestBody MoodPainLogRequest request) {
        User currentUser = getCurrentUser();
        
        // Only patients can create mood pain logs
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can create mood pain logs");
        }
        
        MoodPainLogResponse response = moodPainLogService.createMoodPainLog(currentUser, request);
        return ResponseEntity.ok(response);
    }

    // 7. Get all mood pain logs for the current patient
    @GetMapping("/mood-pain-log")
    @Operation(
        summary = "📋 Get all mood & pain logs",
        description = "Retrieve all mood and pain log entries for the current patient, ordered by timestamp (newest first)",
        tags = {"Patient Management", "📊 Mood & Pain Tracking"}
    )
    @ApiResponses({
        @ApiResponse(responseCode = "200", description = "Mood pain logs retrieved successfully"),
        @ApiResponse(responseCode = "401", description = "Authentication required"),
        @ApiResponse(responseCode = "403", description = "Only patients can view their mood pain logs")
    })
    public ResponseEntity<List<MoodPainLogResponse>> getMoodPainLogs() {
        User currentUser = getCurrentUser();
        
        // Only patients can view their own mood pain logs
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can view their mood pain logs");
        }
        
        List<MoodPainLogResponse> logs = moodPainLogService.getMoodPainLogs(currentUser);
        return ResponseEntity.ok(logs);
    }

    // 8. Get mood pain logs with pagination
    @GetMapping("/mood-pain-log/paginated")
    public ResponseEntity<Page<MoodPainLogResponse>> getMoodPainLogsWithPagination(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        User currentUser = getCurrentUser();
        
        // Only patients can view their own mood pain logs
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can view their mood pain logs");
        }
        
        Page<MoodPainLogResponse> logs = moodPainLogService.getMoodPainLogsWithPagination(currentUser, page, size);
        return ResponseEntity.ok(logs);
    }

    // 9. Get mood pain logs within a date range
    @GetMapping("/mood-pain-log/range")
    public ResponseEntity<List<MoodPainLogResponse>> getMoodPainLogsByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        User currentUser = getCurrentUser();
        
        // Only patients can view their own mood pain logs
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can view their mood pain logs");
        }
        
        List<MoodPainLogResponse> logs = moodPainLogService.getMoodPainLogsByDateRange(currentUser, startDate, endDate);
        return ResponseEntity.ok(logs);
    }

    // 10. Get the latest mood pain log
    @GetMapping("/mood-pain-log/latest")
    public ResponseEntity<MoodPainLogResponse> getLatestMoodPainLog() {
        User currentUser = getCurrentUser();
        
        // Only patients can view their own mood pain logs
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can view their mood pain logs");
        }
        
        MoodPainLogResponse latestLog = moodPainLogService.getLatestMoodPainLog(currentUser);
        return ResponseEntity.ok(latestLog);
    }

    // 11. Update an existing mood pain log
    @PutMapping("/mood-pain-log/{logId}")
    public ResponseEntity<MoodPainLogResponse> updateMoodPainLog(
            @PathVariable Long logId,
            @Valid @RequestBody MoodPainLogRequest request) {
        User currentUser = getCurrentUser();
        
        // Only patients can update their mood pain logs
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can update their mood pain logs");
        }
        
        MoodPainLogResponse response = moodPainLogService.updateMoodPainLog(currentUser, logId, request);
        return ResponseEntity.ok(response);
    }

    // 12. Delete a mood pain log
    @DeleteMapping("/mood-pain-log/{logId}")
    public ResponseEntity<Void> deleteMoodPainLog(@PathVariable Long logId) {
        User currentUser = getCurrentUser();
        
        // Only patients can delete their mood pain logs
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can delete their mood pain logs");
        }
        
        moodPainLogService.deleteMoodPainLog(currentUser, logId);
        return ResponseEntity.noContent().build();
    }

    // 13. Get mood pain logs for a specific patient (for caregivers to view)
    @GetMapping("/{patientId}/mood-pain-log")
    public ResponseEntity<List<MoodPainLogResponse>> getMoodPainLogsForPatient(@PathVariable Long patientId) {
        User currentUser = getCurrentUser();
        
        // Convert patientId to userId for validation
        Patient patient = patientService.getPatientById(patientId);
        validatePatientAccess(patient.getUser().getId(), currentUser);
        
        List<MoodPainLogResponse> logs = moodPainLogService.getMoodPainLogsForPatient(patientId);
        return ResponseEntity.ok(logs);
    }

    // 14. Get advanced mood and pain analytics
    @GetMapping("/mood-pain-log/analytics")
    @Operation(
        summary = "📈 Get mood & pain analytics",
        description = """
            Get detailed analytics for mood and pain data including trends, averages, and time series data.
            
            **Features:**
            - Average mood and pain levels over the period
            - Trend analysis (improving/declining)
            - Min/max values
            - Entry counts
            - Time series data for charts
            """,
        tags = {"Patient Management", "📊 Mood & Pain Tracking"}
    )
    public ResponseEntity<MoodPainAnalyticsDTO> getMoodPainAnalytics(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate) {
        User currentUser = getCurrentUser();
        
        // Only patients can view their own analytics
        if (currentUser.getRole() != Role.PATIENT) {
            throw new AppException(HttpStatus.FORBIDDEN, "Only patients can view their mood pain analytics");
        }
        
        MoodPainAnalyticsDTO analytics = moodPainLogService.getMoodPainAnalytics(currentUser, startDate, endDate);
        return ResponseEntity.ok(analytics);
    }
}