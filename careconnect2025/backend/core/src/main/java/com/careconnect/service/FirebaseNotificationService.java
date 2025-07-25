package com.careconnect.service;

import com.careconnect.dto.FirebaseNotificationRequest;
import com.careconnect.dto.NotificationResponse;
import com.careconnect.model.DeviceToken;
import com.careconnect.model.User;
import com.careconnect.model.CaregiverPatientLink;
import com.careconnect.model.FamilyMemberLink;
import com.careconnect.repository.DeviceTokenRepository;
import com.careconnect.repository.UserRepository;
import com.careconnect.repository.CaregiverPatientLinkRepository;
import com.careconnect.repository.FamilyMemberLinkRepository;
import com.google.firebase.messaging.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

@Service
@ConditionalOnProperty(name = "firebase.enabled", havingValue = "true", matchIfMissing = true)
public class FirebaseNotificationService {
    
    private static final Logger logger = LoggerFactory.getLogger(FirebaseNotificationService.class);
    
    @Autowired(required = false)
    private FirebaseMessaging firebaseMessaging;
    
    @Autowired
    private DeviceTokenRepository deviceTokenRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private CaregiverPatientLinkRepository caregiverPatientLinkRepository;
    
    @Autowired
    private FamilyMemberLinkRepository familyMemberLinkRepository;
    
    /**
     * Send notification to a specific device token
     */
    public NotificationResponse sendNotification(FirebaseNotificationRequest request) {
        if (firebaseMessaging == null) {
            logger.warn("Firebase not initialized, cannot send notification");
            return NotificationResponse.failure("Firebase not available");
        }
        
        try {
            Message message = buildMessage(request);
            String response = firebaseMessaging.send(message);
            
            logger.info("Successfully sent message: {}", response);
            return NotificationResponse.success(response);
            
        } catch (FirebaseMessagingException e) {
            logger.error("Failed to send FCM message: {}", e.getMessage(), e);
            handleFirebaseException(e, request.getTargetToken());
            return NotificationResponse.failure(e.getMessage());
        } catch (Exception e) {
            logger.error("Unexpected error sending notification: {}", e.getMessage(), e);
            return NotificationResponse.failure("Unexpected error: " + e.getMessage());
        }
    }
    
    /**
     * Send notification to multiple device tokens
     */
    public List<NotificationResponse> sendBulkNotifications(List<FirebaseNotificationRequest> requests) {
        if (firebaseMessaging == null) {
            logger.warn("Firebase not initialized, cannot send bulk notifications");
            return requests.stream()
                    .map(req -> NotificationResponse.failure("Firebase not available"))
                    .collect(Collectors.toList());
        }
        
        List<Message> messages = requests.stream()
                .map(this::buildMessage)
                .collect(Collectors.toList());
        
        try {
            BatchResponse response = firebaseMessaging.sendEach(messages);
            logger.info("Successfully sent {} messages out of {}", 
                    response.getSuccessCount(), messages.size());
            
            return processBatchResponse(response, requests);
            
        } catch (FirebaseMessagingException e) {
            logger.error("Failed to send bulk FCM messages: {}", e.getMessage(), e);
            return requests.stream()
                    .map(req -> NotificationResponse.failure(e.getMessage()))
                    .collect(Collectors.toList());
        }
    }
    
    /**
     * Send notification to all devices of a specific user
     */
    public List<NotificationResponse> sendNotificationToUser(Long userId, String title, String body, 
                                                           String notificationType, Map<String, String> data) {
        List<DeviceToken> userTokens = deviceTokenRepository.findByUserIdAndIsActiveTrue(userId);
        
        if (userTokens.isEmpty()) {
            logger.warn("No active device tokens found for user: {}", userId);
            return List.of(NotificationResponse.failure("No active device tokens found"));
        }
        
        List<FirebaseNotificationRequest> requests = userTokens.stream()
                .map(token -> FirebaseNotificationRequest.builder()
                        .title(title)
                        .body(body)
                        .targetToken(token.getFcmToken())
                        .targetUserId(userId)
                        .notificationType(notificationType)
                        .data(data != null ? data : new HashMap<>())
                        .build())
                .collect(Collectors.toList());
        
        return sendBulkNotifications(requests);
    }
    
    /**
     * Send notification to multiple users (e.g., all caregivers of a patient)
     */
    public List<NotificationResponse> sendNotificationToUsers(List<Long> userIds, String title, String body, 
                                                            String notificationType, Map<String, String> data) {
        List<DeviceToken> tokens = deviceTokenRepository.findActiveTokensByUserIds(userIds);
        
        if (tokens.isEmpty()) {
            logger.warn("No active device tokens found for users: {}", userIds);
            return List.of(NotificationResponse.failure("No active device tokens found"));
        }
        
        List<FirebaseNotificationRequest> requests = tokens.stream()
                .map(token -> FirebaseNotificationRequest.builder()
                        .title(title)
                        .body(body)
                        .targetToken(token.getFcmToken())
                        .targetUserId(token.getUser().getId())
                        .notificationType(notificationType)
                        .data(data != null ? data : new HashMap<>())
                        .build())
                .collect(Collectors.toList());
        
        return sendBulkNotifications(requests);
    }
    
    /**
     * Send vital alert to patient's caregivers
     */
    public CompletableFuture<List<NotificationResponse>> sendVitalAlert(Long patientId, String vitalType, 
                                                                       String vitalValue, String alertLevel) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                // Get patient's caregivers
                List<Long> caregiverIds = getCaregiverIds(patientId);
                
                if (caregiverIds.isEmpty()) {
                    logger.warn("No caregivers found for patient: {}", patientId);
                    return List.of(NotificationResponse.failure("No caregivers found"));
                }
                
                String title = "⚠️ Vital Alert";
                String body = String.format("Patient's %s is %s (%s level)", vitalType, vitalValue, alertLevel);
                
                Map<String, String> data = Map.of(
                        "type", "VITAL_ALERT",
                        "patientId", patientId.toString(),
                        "vitalType", vitalType,
                        "vitalValue", vitalValue,
                        "alertLevel", alertLevel,
                        "timestamp", Instant.now().toString()
                );
                
                return sendNotificationToUsers(caregiverIds, title, body, "VITAL_ALERT", data);
                
            } catch (Exception e) {
                logger.error("Error sending vital alert: {}", e.getMessage(), e);
                return List.of(NotificationResponse.failure("Error: " + e.getMessage()));
            }
        });
    }
    
    /**
     * Send medication reminder
     */
    public CompletableFuture<List<NotificationResponse>> sendMedicationReminder(Long patientId, String medicationName, 
                                                                              String dosage, String scheduledTime) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                String title = "💊 Medication Reminder";
                String body = String.format("Time to take %s (%s) at %s", medicationName, dosage, scheduledTime);
                
                Map<String, String> data = Map.of(
                        "type", "MEDICATION_REMINDER",
                        "patientId", patientId.toString(),
                        "medicationName", medicationName,
                        "dosage", dosage,
                        "scheduledTime", scheduledTime,
                        "timestamp", Instant.now().toString()
                );
                
                return sendNotificationToUser(patientId, title, body, "MEDICATION_REMINDER", data);
                
            } catch (Exception e) {
                logger.error("Error sending medication reminder: {}", e.getMessage(), e);
                return List.of(NotificationResponse.failure("Error: " + e.getMessage()));
            }
        });
    }
    
    /**
     * Send emergency alert
     */
    public CompletableFuture<List<NotificationResponse>> sendEmergencyAlert(Long patientId, String emergencyType, 
                                                                          String location) {
        return CompletableFuture.supplyAsync(() -> {
            try {
                // Get all caregivers and family members
                List<Long> caregiverIds = getCaregiverIds(patientId);
                List<Long> familyMemberIds = getFamilyMemberIds(patientId);
                
                List<Long> allRecipients = new ArrayList<>();
                allRecipients.addAll(caregiverIds);
                allRecipients.addAll(familyMemberIds);
                
                if (allRecipients.isEmpty()) {
                    logger.warn("No recipients found for emergency alert for patient: {}", patientId);
                    return List.of(NotificationResponse.failure("No recipients found"));
                }
                
                String title = "🚨 EMERGENCY ALERT";
                String body = String.format("Emergency: %s at %s", emergencyType, location);
                
                Map<String, String> data = Map.of(
                        "type", "EMERGENCY_ALERT",
                        "patientId", patientId.toString(),
                        "emergencyType", emergencyType,
                        "location", location,
                        "priority", "HIGH",
                        "timestamp", Instant.now().toString()
                );
                
                return sendNotificationToUsers(allRecipients, title, body, "EMERGENCY_ALERT", data);
                
            } catch (Exception e) {
                logger.error("Error sending emergency alert: {}", e.getMessage(), e);
                return List.of(NotificationResponse.failure("Error: " + e.getMessage()));
            }
        });
    }
    
    /**
     * Register or update device token for a user
     */
    public void registerDeviceToken(Long userId, String fcmToken, String deviceId, DeviceToken.DeviceType deviceType) {
        try {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));
            
            // Deactivate existing token for this device
            deviceTokenRepository.deactivateByUserAndDeviceId(user, deviceId);
            
            // Create new token
            DeviceToken deviceToken = DeviceToken.builder()
                    .user(user)
                    .fcmToken(fcmToken)
                    .deviceId(deviceId)
                    .deviceType(deviceType)
                    .isActive(true)
                    .createdAt(Instant.now())
                    .lastUsedAt(Instant.now())
                    .build();
            
            deviceTokenRepository.save(deviceToken);
            logger.info("Registered device token for user: {} device: {}", userId, deviceId);
            
        } catch (Exception e) {
            logger.error("Error registering device token: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to register device token", e);
        }
    }
    
    /**
     * Unregister device token
     */
    public void unregisterDeviceToken(String fcmToken) {
        try {
            deviceTokenRepository.deactivateByFcmToken(fcmToken);
            logger.info("Unregistered device token: {}", fcmToken);
        } catch (Exception e) {
            logger.error("Error unregistering device token: {}", e.getMessage(), e);
        }
    }
    
    // Private helper methods
    
    private Message buildMessage(FirebaseNotificationRequest request) {
        Notification.Builder notificationBuilder = Notification.builder()
                .setTitle(request.getTitle())
                .setBody(request.getBody());
        
        if (request.getImageUrl() != null) {
            notificationBuilder.setImage(request.getImageUrl());
        }
        
        Message.Builder messageBuilder = Message.builder()
                .setToken(request.getTargetToken())
                .setNotification(notificationBuilder.build());
        
        // Add custom data
        if (request.getData() != null && !request.getData().isEmpty()) {
            messageBuilder.putAllData(request.getData());
        }
        
        // Set Android-specific configuration
        AndroidConfig androidConfig = AndroidConfig.builder()
                .setTtl(3600 * 1000) // 1 hour
                .setPriority(AndroidConfig.Priority.HIGH)
                .setNotification(AndroidNotification.builder()
                        .setIcon("ic_notification")
                        .setColor("#0066CC")
                        .setSound("default")
                        .build())
                .build();
        messageBuilder.setAndroidConfig(androidConfig);
        
        // Set iOS-specific configuration
        ApnsConfig apnsConfig = ApnsConfig.builder()
                .setAps(Aps.builder()
                        .setAlert(ApsAlert.builder()
                                .setTitle(request.getTitle())
                                .setBody(request.getBody())
                                .build())
                        .setBadge(1)
                        .setSound("default")
                        .build())
                .build();
        messageBuilder.setApnsConfig(apnsConfig);
        
        return messageBuilder.build();
    }
    
    private List<NotificationResponse> processBatchResponse(BatchResponse response, 
                                                          List<FirebaseNotificationRequest> requests) {
        List<NotificationResponse> results = new ArrayList<>();
        List<SendResponse> responses = response.getResponses();
        
        for (int i = 0; i < responses.size(); i++) {
            SendResponse sendResponse = responses.get(i);
            FirebaseNotificationRequest request = requests.get(i);
            
            if (sendResponse.isSuccessful()) {
                results.add(NotificationResponse.success(sendResponse.getMessageId()));
            } else {
                FirebaseMessagingException exception = sendResponse.getException();
                handleFirebaseException(exception, request.getTargetToken());
                results.add(NotificationResponse.failure(exception.getMessage()));
            }
        }
        
        return results;
    }
    
    private void handleFirebaseException(FirebaseMessagingException exception, String token) {
        String errorCode = exception.getErrorCode().name();
        
        if ("UNREGISTERED".equals(errorCode) || "INVALID_ARGUMENT".equals(errorCode)) {
            // Token is invalid, remove it from database
            logger.warn("Invalid FCM token detected, deactivating: {}", token);
            deviceTokenRepository.deactivateByFcmToken(token);
        }
    }
    
    private List<Long> getCaregiverIds(Long patientId) {
        try {
            User patientUser = userRepository.findById(patientId)
                    .orElseThrow(() -> new IllegalArgumentException("Patient not found"));
            
            return caregiverPatientLinkRepository
                    .findByPatientUserAndStatus(patientUser, CaregiverPatientLink.LinkStatus.ACTIVE)
                    .stream()
                    .map(link -> link.getCaregiverUser().getId())
                    .collect(Collectors.toList());
        } catch (Exception e) {
            logger.error("Error getting caregiver IDs for patient {}: {}", patientId, e.getMessage());
            return new ArrayList<>();
        }
    }
    
    private List<Long> getFamilyMemberIds(Long patientId) {
        try {
            User patientUser = userRepository.findById(patientId)
                    .orElseThrow(() -> new IllegalArgumentException("Patient not found"));
            
            return familyMemberLinkRepository
                    .findByPatientUserAndStatus(patientUser, FamilyMemberLink.LinkStatus.ACTIVE)
                    .stream()
                    .map(link -> link.getFamilyUser().getId())
                    .collect(Collectors.toList());
        } catch (Exception e) {
            logger.error("Error getting family member IDs for patient {}: {}", patientId, e.getMessage());
            return new ArrayList<>();
        }
    }
}
