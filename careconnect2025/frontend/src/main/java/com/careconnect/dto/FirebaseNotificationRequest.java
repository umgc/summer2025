package com.careconnect.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FirebaseNotificationRequest {
    private String title;
    private String body;
    private String imageUrl;
    private String targetToken; // FCM token of the recipient
    private Long targetUserId; // User ID of the recipient
    private String userType; // PATIENT, CAREGIVER, FAMILY_MEMBER
    private String notificationType; // VITAL_ALERT, MEDICATION_REMINDER, EMERGENCY, etc.
    private String deepLink; // Optional deep link for the notification
    private java.util.Map<String, String> data; // Additional custom data
}
