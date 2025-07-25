package com.careconnect.websocket;

import com.careconnect.model.User;
import com.careconnect.repository.UserRepository;
import com.careconnect.security.JwtTokenProvider;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Component
@Slf4j
@RequiredArgsConstructor
public class CareConnectWebSocketHandler extends TextWebSocketHandler {

    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // Store active connections: userId -> WebSocketSession
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    
    // Store user info for sessions: sessionId -> User
    private final Map<String, User> sessionUsers = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("CareConnect WebSocket connection established: {}", session.getId());
        
        Map<String, Object> response = Map.of(
            "type", "connection-established",
            "message", "Connected to CareConnect real-time service",
            "sessionId", session.getId()
        );
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            Map<String, Object> payload = objectMapper.readValue(message.getPayload(), Map.class);
            String type = (String) payload.get("type");
            
            log.info("Received CareConnect WebSocket message: {} from session: {}", type, session.getId());
            
            switch (type) {
                case "authenticate":
                    handleAuthentication(session, payload);
                    break;
                case "subscribe-to-updates":
                    handleSubscribeToUpdates(session, payload);
                    break;
                case "ai-chat-notification":
                    handleAIChatNotification(session, payload);
                    break;
                case "mood-pain-log-update":
                    handleMoodPainLogUpdate(session, payload);
                    break;
                case "medication-reminder":
                    handleMedicationReminder(session, payload);
                    break;
                case "vital-signs-alert":
                    handleVitalSignsAlert(session, payload);
                    break;
                case "family-member-request":
                    handleFamilyMemberRequest(session, payload);
                    break;
                case "heartbeat":
                    handleHeartbeat(session, payload);
                    break;
                default:
                    log.warn("Unknown CareConnect message type: {}", type);
            }
        } catch (Exception e) {
            log.error("Error handling CareConnect WebSocket message from session {}", session.getId(), e);
        }
    }

    private void handleAuthentication(WebSocketSession session, Map<String, Object> payload) throws Exception {
        String token = (String) payload.get("token");
        
        if (token == null || !jwtTokenProvider.validateToken(token)) {
            Map<String, Object> response = Map.of(
                "type", "authentication-failed",
                "message", "Invalid or missing token"
            );
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
            session.close(CloseStatus.NOT_ACCEPTABLE.withReason("Authentication failed"));
            return;
        }
        
        String userEmail = jwtTokenProvider.getEmailFromToken(token);
        User user = userRepository.findByEmail(userEmail).orElse(null);
        
        if (user == null) {
            Map<String, Object> response = Map.of(
                "type", "authentication-failed",
                "message", "User not found"
            );
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
            session.close(CloseStatus.NOT_ACCEPTABLE.withReason("User not found"));
            return;
        }
        
        // Store user session
        userSessions.put(user.getId().toString(), session);
        sessionUsers.put(session.getId(), user);
        
        Map<String, Object> response = Map.of(
            "type", "authentication-success",
            "userId", user.getId(),
            "userEmail", user.getEmail(),
            "userRole", user.getRole().name()
        );
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
        
        log.info("CareConnect user authenticated: {} ({})", user.getEmail(), user.getRole());
    }

    private void handleSubscribeToUpdates(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        @SuppressWarnings("unchecked")
        java.util.List<String> updateTypes = (java.util.List<String>) payload.get("updateTypes");
        
        Map<String, Object> response = Map.of(
            "type", "subscription-confirmed",
            "userId", user.getId(),
            "subscribedTo", updateTypes != null ? updateTypes : java.util.List.of("all"),
            "timestamp", System.currentTimeMillis()
        );
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
        
        log.info("User {} subscribed to updates: {}", user.getEmail(), updateTypes);
    }

    private void handleAIChatNotification(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String targetUserId = (String) payload.get("targetUserId");
        String chatMessage = (String) payload.get("message");
        String conversationId = (String) payload.get("conversationId");
        
        // Send AI chat notification to target user
        WebSocketSession targetSession = userSessions.get(targetUserId);
        if (targetSession != null && targetSession.isOpen()) {
            Map<String, Object> notification = Map.of(
                "type", "ai-chat-response",
                "fromUserId", user.getId(),
                "fromUserName", user.getFirstName() + " " + user.getLastName(),
                "conversationId", conversationId,
                "message", chatMessage,
                "timestamp", System.currentTimeMillis()
            );
            
            targetSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(notification)));
            log.info("AI chat notification sent from {} to {}", user.getEmail(), targetUserId);
        }
    }

    private void handleMoodPainLogUpdate(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        // Notify caregivers and family members about mood/pain log updates
        // This would integrate with your existing family member and caregiver services
        Map<String, Object> notification = Map.of(
            "type", "mood-pain-log-updated",
            "patientId", user.getId(),
            "patientName", user.getFirstName() + " " + user.getLastName(),
            "moodValue", payload.get("moodValue"),
            "painValue", payload.get("painValue"),
            "timestamp", System.currentTimeMillis()
        );
        
        // Here you would get caregivers and family members and notify them
        log.info("Mood/pain log update from patient: {}", user.getEmail());
    }

    private void handleMedicationReminder(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String patientId = (String) payload.get("patientId");
        String medicationName = (String) payload.get("medicationName");
        String reminderTime = (String) payload.get("reminderTime");
        
        // Send medication reminder to patient
        WebSocketSession patientSession = userSessions.get(patientId);
        if (patientSession != null && patientSession.isOpen()) {
            Map<String, Object> reminder = Map.of(
                "type", "medication-reminder",
                "medicationName", medicationName,
                "reminderTime", reminderTime,
                "message", "Time to take your " + medicationName,
                "timestamp", System.currentTimeMillis()
            );
            
            patientSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(reminder)));
            log.info("Medication reminder sent to patient: {}", patientId);
        }
    }

    private void handleVitalSignsAlert(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String alertType = (String) payload.get("alertType");
        String alertMessage = (String) payload.get("message");
        String severity = (String) payload.get("severity");
        
        // This would notify relevant healthcare providers
        Map<String, Object> alert = Map.of(
            "type", "vital-signs-alert",
            "patientId", user.getId(),
            "patientName", user.getFirstName() + " " + user.getLastName(),
            "alertType", alertType,
            "message", alertMessage,
            "severity", severity,
            "timestamp", System.currentTimeMillis()
        );
        
        log.info("Vital signs alert from patient {}: {} - {}", user.getEmail(), alertType, severity);
    }

    private void handleFamilyMemberRequest(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String targetPatientId = (String) payload.get("patientId");
        String requestType = (String) payload.get("requestType");
        
        // Notify patient about family member request
        WebSocketSession patientSession = userSessions.get(targetPatientId);
        if (patientSession != null && patientSession.isOpen()) {
            Map<String, Object> request = Map.of(
                "type", "family-member-request",
                "fromUserId", user.getId(),
                "fromUserName", user.getFirstName() + " " + user.getLastName(),
                "fromUserEmail", user.getEmail(),
                "requestType", requestType,
                "timestamp", System.currentTimeMillis()
            );
            
            patientSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(request)));
            log.info("Family member request sent from {} to patient {}", user.getEmail(), targetPatientId);
        }
    }

    private void handleHeartbeat(WebSocketSession session, Map<String, Object> payload) throws Exception {
        Map<String, Object> response = Map.of(
            "type", "heartbeat-response",
            "timestamp", System.currentTimeMillis()
        );
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    private void sendErrorMessage(WebSocketSession session, String errorMessage) {
        try {
            Map<String, Object> error = Map.of(
                "type", "error",
                "message", errorMessage,
                "timestamp", System.currentTimeMillis()
            );
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(error)));
        } catch (Exception e) {
            log.error("Failed to send error message to session {}", session.getId(), e);
        }
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        User user = sessionUsers.remove(session.getId());
        if (user != null) {
            userSessions.remove(user.getId().toString());
            log.info("CareConnect WebSocket connection closed for user: {} - Status: {}", user.getEmail(), status);
        } else {
            log.info("CareConnect WebSocket connection closed: {} - Status: {}", session.getId(), status);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        User user = sessionUsers.get(session.getId());
        String userInfo = user != null ? user.getEmail() : "Unknown user";
        log.error("CareConnect WebSocket transport error for user: {} - Session: {}", userInfo, session.getId(), exception);
    }

    // Public method to send real-time updates from other services
    public void sendRealTimeUpdate(String userId, Map<String, Object> update) {
        WebSocketSession session = userSessions.get(userId);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(objectMapper.writeValueAsString(update)));
                log.info("Real-time update sent to user {}: {}", userId, update.get("type"));
            } catch (Exception e) {
                log.error("Failed to send real-time update to user {}", userId, e);
            }
        } else {
            log.debug("User {} not connected for real-time update: {}", userId, update.get("type"));
        }
    }

    // Broadcast to all connected users (admin feature)
    public void broadcastToAllUsers(Map<String, Object> message) {
        userSessions.values().forEach(session -> {
            if (session.isOpen()) {
                try {
                    session.sendMessage(new TextMessage(objectMapper.writeValueAsString(message)));
                } catch (Exception e) {
                    log.error("Failed to broadcast message to session {}", session.getId(), e);
                }
            }
        });
        log.info("Broadcast message sent to {} users: {}", userSessions.size(), message.get("type"));
    }

    // Get online users count
    public int getOnlineUsersCount() {
        return userSessions.size();
    }

    // Check if user is online
    public boolean isUserOnline(String userId) {
        return userSessions.containsKey(userId) && userSessions.get(userId).isOpen();
    }
}
