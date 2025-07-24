# Firebase Notification Service Documentation

## Overview

The Firebase Notification Service provides comprehensive push notification functionality for the CareConnect application. It supports sending notifications to patients, caregivers, and family members through Firebase Cloud Messaging (FCM).

## Features

- **Device Token Management**: Register and manage FCM tokens for multiple devices per user
- **Targeted Notifications**: Send notifications to specific users, groups, or all devices of a user
- **Medical Alerts**: Specialized notifications for vital signs alerts, medication reminders, and emergencies
- **Connection Notifications**: Automatic notifications for caregiver-patient connections
- **Multi-platform Support**: Android, iOS, and Web push notifications

## Configuration

### Firebase Setup

1. **Firebase Project**: `careconnectcapstone`
2. **Project ID**: `663999888931`
3. **Sender ID**: `663999888931`
4. **Service Account**: `firebase-adminsdk-fbsvc@careconnectcapstone.iam.gserviceaccount.com`

### Application Properties

```properties
# Firebase Configuration
firebase.project-id=careconnectcapstone
firebase.service-account-key=firebase-service-account.json
firebase.sender-id=663999888931
```

## API Endpoints

### Device Token Management

#### Register Device Token
```http
POST /v1/api/notifications/register-token
```
**Parameters:**
- `userId`: User ID
- `fcmToken`: Firebase Cloud Messaging token
- `deviceId`: Unique device identifier
- `deviceType`: ANDROID, IOS, or WEB

**Example:**
```bash
curl -X POST "/v1/api/notifications/register-token" \
  -H "Authorization: Bearer {jwt-token}" \
  -d "userId=123&fcmToken=fGw...xyz&deviceId=device123&deviceType=ANDROID"
```

#### Unregister Device Token
```http
DELETE /v1/api/notifications/unregister-token?fcmToken={token}
```

### Send Notifications

#### Send Individual Notification
```http
POST /v1/api/notifications/send
```
**Body:**
```json
{
  "title": "Test Notification",
  "body": "This is a test message",
  "targetToken": "fGw...xyz",
  "targetUserId": 123,
  "notificationType": "GENERAL",
  "data": {
    "customKey": "customValue"
  }
}
```

#### Send to User (All Devices)
```http
POST /v1/api/notifications/send-to-user/{userId}
```
**Parameters:**
- `title`: Notification title
- `body`: Notification message
- `notificationType`: Type of notification (optional)
- `data`: Additional custom data (optional)

### Medical Alerts

#### Vital Signs Alert
```http
POST /v1/api/notifications/vital-alert/{patientId}
```
**Parameters:**
- `vitalType`: Type of vital sign (e.g., "Heart Rate", "Blood Pressure")
- `vitalValue`: The measured value
- `alertLevel`: LOW, HIGH, or CRITICAL

**Example:**
```bash
curl -X POST "/v1/api/notifications/vital-alert/123" \
  -H "Authorization: Bearer {jwt-token}" \
  -d "vitalType=Heart Rate&vitalValue=120 bpm&alertLevel=HIGH"
```

#### Medication Reminder
```http
POST /v1/api/notifications/medication-reminder/{patientId}
```
**Parameters:**
- `medicationName`: Name of the medication
- `dosage`: Dosage information
- `scheduledTime`: When to take the medication

#### Emergency Alert
```http
POST /v1/api/notifications/emergency-alert/{patientId}
```
**Parameters:**
- `emergencyType`: Type of emergency
- `location`: Location of the emergency

## Automatic Notifications

### Patient Registration
When a caregiver registers a patient, the system automatically sends:
- **Email**: Password setup instructions
- **Push Notification**: Welcome message to patient

### Connection Requests
When a caregiver sends a connection request:
- **Email**: Connection request with approve/reject links
- **Push Notification**: New connection request notification

When a patient accepts a connection:
- **Email**: Confirmation to caregiver
- **Push Notification**: Connection accepted notification

### Vital Signs Monitoring
Automatic alerts are sent when vital signs exceed normal ranges:

- **Heart Rate**: 
  - Low: < 60 bpm
  - High: > 100 bpm
  - Critical: > 120 bpm

- **Blood Oxygen (SpO2)**:
  - High: < 95%
  - Critical: < 90%

- **Blood Pressure**:
  - Low: Systolic < 90 or Diastolic < 60
  - High: Systolic > 140 or Diastolic > 90
  - Critical: Systolic > 180 or Diastolic > 110

- **Mood**: Alert when score ≤ 2 (severe depression/anxiety)
- **Pain**: Alert when score ≥ 8 (severe pain)

## Integration Examples

### Frontend Integration

#### JavaScript (Web)
```javascript
// Initialize Firebase
import { initializeApp } from 'firebase/app';
import { getMessaging, getToken } from 'firebase/messaging';

const firebaseConfig = {
  messagingSenderId: "663999888931"
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

// Get FCM token
async function getFCMToken() {
  const token = await getToken(messaging, {
    vapidKey: 'your-vapid-key'
  });
  
  // Register token with backend
  await fetch('/v1/api/notifications/register-token', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${jwtToken}` },
    body: new URLSearchParams({
      userId: currentUserId,
      fcmToken: token,
      deviceId: 'web-' + Date.now(),
      deviceType: 'WEB'
    })
  });
}
```

#### Android (Kotlin)
```kotlin
FirebaseMessaging.getInstance().token.addOnCompleteListener { task ->
    if (!task.isSuccessful) {
        Log.w(TAG, "Fetching FCM registration token failed", task.exception)
        return@addOnCompleteListener
    }

    // Register token with backend
    val token = task.result
    registerTokenWithBackend(token)
}

private fun registerTokenWithBackend(token: String) {
    val request = RegisterTokenRequest(
        userId = currentUserId,
        fcmToken = token,
        deviceId = Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID),
        deviceType = "ANDROID"
    )
    
    apiService.registerDeviceToken(request)
}
```

#### iOS (Swift)
```swift
Messaging.messaging().token { token, error in
    if let error = error {
        print("Error fetching FCM registration token: \\(error)")
    } else if let token = token {
        print("FCM registration token: \\(token)")
        registerTokenWithBackend(token: token)
    }
}

func registerTokenWithBackend(token: String) {
    let parameters = [
        "userId": currentUserId,
        "fcmToken": token,
        "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? "",
        "deviceType": "IOS"
    ]
    
    // Make API call to register token
}
```

### Backend Service Integration

#### Custom Notification Service
```java
@Service
@RequiredArgsConstructor
public class MedicalAlertService {
    
    private final FirebaseNotificationService notificationService;
    
    public void sendCriticalVitalAlert(Long patientId, String vitalType, Double value) {
        // Send immediate notification
        notificationService.sendVitalAlert(
            patientId, 
            vitalType, 
            value.toString(), 
            "CRITICAL"
        ).thenAccept(responses -> {
            log.info("Critical vital alert sent to {} recipients", responses.size());
        });
        
        // Also send emergency alert if critical
        if (isCriticalLevel(vitalType, value)) {
            notificationService.sendEmergencyAlert(
                patientId,
                "Critical Vital Signs",
                "Patient location unknown"
            );
        }
    }
}
```

## Database Schema

### Device Tokens Table
```sql
CREATE TABLE device_tokens (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    fcm_token VARCHAR(500) NOT NULL,
    device_type ENUM('ANDROID', 'IOS', 'WEB') NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL,
    last_used_at TIMESTAMP NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_active (user_id, is_active),
    INDEX idx_fcm_token (fcm_token),
    UNIQUE KEY uk_user_device (user_id, device_id)
);
```

## Error Handling

The service includes comprehensive error handling:

- **Invalid Tokens**: Automatically removes invalid/expired FCM tokens
- **Network Errors**: Retries failed requests with exponential backoff
- **Rate Limiting**: Handles FCM rate limits gracefully
- **Logging**: Detailed logging for debugging and monitoring

## Security Considerations

1. **JWT Authentication**: All endpoints require valid JWT tokens
2. **Role-Based Access**: Notifications respect user roles and permissions
3. **Token Validation**: FCM tokens are validated before sending
4. **Data Privacy**: Sensitive medical data is not included in notification payloads

## Monitoring and Analytics

- **Success/Failure Rates**: Track notification delivery success
- **Token Management**: Monitor active/inactive tokens
- **User Engagement**: Track notification open rates
- **Error Rates**: Monitor and alert on high error rates

## Testing

### Postman Collection
Import the provided Postman collection for testing all notification endpoints.

### Test Scenarios
1. Register device tokens for different platforms
2. Send notifications to single users and groups
3. Test vital sign alerts with different severity levels
4. Verify automatic notifications for patient registration
5. Test connection request notifications

## Support

For issues or questions regarding Firebase notifications:
1. Check application logs for detailed error messages
2. Verify Firebase project configuration
3. Ensure FCM tokens are properly registered
4. Contact the development team for assistance
