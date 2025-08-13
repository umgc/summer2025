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
@RequiredArgsConstructor
public class CallNotificationHandler extends TextWebSocketHandler {
    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(CallNotificationHandler.class);
    // Helper to get display name for a user
    private String getUserDisplayName(User user) {
        if (user.getName() != null && !user.getName().isEmpty()) {
            return user.getName();
        }
        return user.getEmail();
    }

    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // Store active connections: userId -> WebSocketSession
    private final Map<String, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    
    // Store user info for sessions: sessionId -> User
    private final Map<String, User> sessionUsers = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("WebSocket connection established: {}", session.getId());
        
        // Send connection confirmation
        Map<String, Object> response = Map.of(
            "type", "connection-established",
            "message", "Connected to CareConnect call service",
            "sessionId", session.getId()
        );
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        try {
            Map<String, Object> payload = objectMapper.readValue(
                message.getPayload(),
                new com.fasterxml.jackson.core.type.TypeReference<Map<String, Object>>() {}
            );
            String type = (String) payload.get("type");

            log.info("Received WebSocket message: {} from session: {}", type, session.getId());

            switch (type) {
                case "authenticate":
                    handleAuthentication(session, payload);
                    break;
                case "join-user-room":
                    handleUserJoin(session, payload);
                    break;
                case "send-video-call-invitation":
                    handleCallInvitation(session, payload);
                    break;
                case "send-sms-notification":
                    handleSMSNotification(session, payload);
                    break;
                case "accept-call":
                    handleCallAccept(session, payload);
                    break;
                case "decline-call":
                    handleCallDecline(session, payload);
                    break;
                case "end-call":
                    handleCallEnd(session, payload);
                    break;
                case "heartbeat":
                    handleHeartbeat(session, payload);
                    break;
                default:
                    log.warn("Unknown message type: {}", type);
                    sendErrorMessage(session, "Unknown message type: " + type);
            }
        } catch (Exception e) {
            log.error("Error handling WebSocket message from session {}", session.getId(), e);
            sendErrorMessage(session, "Error processing message: " + e.getMessage());
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
        
        log.info("User authenticated: {} ({})", user.getEmail(), user.getRole());
    }

    private void handleUserJoin(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String userId = user.getId().toString();
        String userRole = user.getRole().name();
        
        // Update user session (in case of reconnection)
        userSessions.put(userId, session);
        
        log.info("User joined room: {} ({})", user.getEmail(), userRole);
        
        // Confirm join
        Map<String, Object> response = Map.of(
            "type", "user-joined",
            "userId", userId,
            "userEmail", user.getEmail(),
            "userRole", userRole,
            "joinedAt", System.currentTimeMillis()
        );
        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    private void handleCallInvitation(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User sender = sessionUsers.get(session.getId());
        if (sender == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String recipientId = (String) payload.get("recipientId");
        String callId = (String) payload.get("callId");
        Boolean isVideoCall = (Boolean) payload.getOrDefault("isVideoCall", true);
        String callType = (String) payload.getOrDefault("callType", "general");
        
        // Validate recipient exists
        User recipient = userRepository.findById(Long.parseLong(recipientId)).orElse(null);
        if (recipient == null) {
            sendErrorMessage(session, "Recipient not found");
            return;
        }
        
        // Find recipient session
        WebSocketSession recipientSession = userSessions.get(recipientId);
        
        if (recipientSession != null && recipientSession.isOpen()) {
            // Send call invitation to recipient
            Map<String, Object> callNotification = Map.of(
                "type", "incoming-video-call",
                "senderId", sender.getId(),
                "senderName", getUserDisplayName(sender),
                "senderEmail", sender.getEmail(),
                "senderRole", sender.getRole().name(),
                "callId", callId,
                "isVideoCall", isVideoCall,
                "callType", callType,
                "timestamp", System.currentTimeMillis()
            );
            
            recipientSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(callNotification)));
            
            // Confirm to sender
            Map<String, Object> senderResponse = Map.of(
                "type", "call-invitation-sent",
                "callId", callId,
                "recipientId", recipientId,
                "recipientName", getUserDisplayName(recipient),
                "status", "delivered"
            );
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(senderResponse)));
            
            log.info("Call invitation sent from {} to {}", sender.getEmail(), recipient.getEmail());
        } else {
            // Recipient not online - could integrate with push notifications here
            Map<String, Object> errorResponse = Map.of(
                "type", "call-invitation-failed",
                "callId", callId,
                "reason", "Recipient not online",
                "recipientId", recipientId
            );
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(errorResponse)));
            
            log.warn("Call invitation failed - recipient {} not online", recipient.getEmail());
        }
    }

    private void handleSMSNotification(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User sender = sessionUsers.get(session.getId());
        if (sender == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String recipientId = (String) payload.get("recipientId");
        String message = (String) payload.get("message");
        String messageType = (String) payload.getOrDefault("messageType", "general");
        
        // Validate recipient exists
        User recipient = userRepository.findById(Long.parseLong(recipientId)).orElse(null);
        if (recipient == null) {
            sendErrorMessage(session, "Recipient not found");
            return;
        }
        
        // Find recipient session
        WebSocketSession recipientSession = userSessions.get(recipientId);
        
        if (recipientSession != null && recipientSession.isOpen()) {
            // Send SMS notification to recipient
            Map<String, Object> smsNotification = Map.of(
                "type", "incoming-sms",
                "senderId", sender.getId(),
                "senderName", getUserDisplayName(sender),
                "senderEmail", sender.getEmail(),
                "senderRole", sender.getRole().name(),
                "message", message,
                "messageType", messageType,
                "timestamp", System.currentTimeMillis()
            );
            
            recipientSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(smsNotification)));
            
            // Confirm to sender
            Map<String, Object> senderResponse = Map.of(
                "type", "sms-sent",
                "recipientId", recipientId,
                "recipientName", getUserDisplayName(recipient),
                "status", "delivered"
            );
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(senderResponse)));
            
            log.info("SMS notification sent from {} to {}", sender.getEmail(), recipient.getEmail());
        } else {
            // Recipient not online
            Map<String, Object> errorResponse = Map.of(
                "type", "sms-failed",
                "reason", "Recipient not online",
                "recipientId", recipientId
            );
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(errorResponse)));
            
            log.warn("SMS notification failed - recipient {} not online", recipient.getEmail());
        }
    }

    private void handleCallAccept(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String callId = (String) payload.get("callId");
        String senderId = (String) payload.get("senderId");
        
        // Notify sender that call was accepted
        WebSocketSession senderSession = userSessions.get(senderId);
        if (senderSession != null && senderSession.isOpen()) {
            Map<String, Object> response = Map.of(
                "type", "call-answered",
                "callId", callId,
                "answeredBy", user.getId(),
                "answeredByName", getUserDisplayName(user),
                "timestamp", System.currentTimeMillis()
            );
            senderSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
            
            log.info("Call {} accepted by {}", callId, user.getEmail());
        }
    }

    private void handleCallDecline(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String callId = (String) payload.get("callId");
        String senderId = (String) payload.get("senderId");
        String reason = (String) payload.getOrDefault("reason", "declined");
        
        // Notify sender that call was declined
        WebSocketSession senderSession = userSessions.get(senderId);
        if (senderSession != null && senderSession.isOpen()) {
            Map<String, Object> response = Map.of(
                "type", "call-declined",
                "callId", callId,
                "declinedBy", user.getId(),
                "declinedByName", getUserDisplayName(user),
                "reason", reason,
                "timestamp", System.currentTimeMillis()
            );
            senderSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
            
            log.info("Call {} declined by {} - reason: {}", callId, user.getEmail(), reason);
        }
    }

    private void handleCallEnd(WebSocketSession session, Map<String, Object> payload) throws Exception {
        User user = sessionUsers.get(session.getId());
        if (user == null) {
            sendErrorMessage(session, "User not authenticated");
            return;
        }
        
        String callId = (String) payload.get("callId");
        String otherPartyId = (String) payload.get("otherPartyId");
        
        // Notify other party that call ended
        WebSocketSession otherSession = userSessions.get(otherPartyId);
        if (otherSession != null && otherSession.isOpen()) {
            Map<String, Object> response = Map.of(
                "type", "call-ended",
                "callId", callId,
                "endedBy", user.getId(),
                "endedByName", getUserDisplayName(user),
                "timestamp", System.currentTimeMillis()
            );
            otherSession.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
            
            log.info("Call {} ended by {}", callId, user.getEmail());
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
            log.info("WebSocket connection closed for user: {} - Status: {}", user.getEmail(), status);
        } else {
            log.info("WebSocket connection closed: {} - Status: {}", session.getId(), status);
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        User user = sessionUsers.get(session.getId());
        String userInfo = user != null ? user.getEmail() : "Unknown user";
        log.error("WebSocket transport error for user: {} - Session: {}", userInfo, session.getId(), exception);
    }

    // Public method to send notifications from other services
    public void sendNotificationToUser(String userId, Map<String, Object> notification) {
        WebSocketSession session = userSessions.get(userId);
        if (session != null && session.isOpen()) {
            try {
                session.sendMessage(new TextMessage(objectMapper.writeValueAsString(notification)));
                log.info("Notification sent to user {}: {}", userId, notification.get("type"));
            } catch (Exception e) {
                log.error("Failed to send notification to user {}", userId, e);
            }
        } else {
            log.warn("User {} not connected for notification: {}", userId, notification.get("type"));
        }
    }

    // Get online users (for admin/monitoring purposes)
    public Map<String, String> getOnlineUsers() {
        Map<String, String> onlineUsers = new ConcurrentHashMap<>();
        sessionUsers.values().forEach(user -> 
            onlineUsers.put(user.getId().toString(), user.getEmail())
        );
        return onlineUsers;
    }
    
    // Additional methods for external service integration
    
    /**
     * Send call invitation from external service
     */
    public void sendCallInvitation(String recipientId, Map<String, Object> invitationData) {
        sendNotificationToUser(recipientId, invitationData);
    }
    
    /**
     * Send SMS notification from external service
     */
    public void sendSMSNotification(String recipientId, Map<String, Object> smsData) {
        sendNotificationToUser(recipientId, smsData);
    }
}
