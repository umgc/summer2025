package com.careconnect.config;

import com.careconnect.websocket.CallNotificationHandler;
import com.careconnect.websocket.CareConnectWebSocketHandler;
import com.careconnect.websocket.NotificationWebSocketHandler;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    @Autowired
    private CallNotificationHandler callNotificationHandler;

    @Autowired
    private CareConnectWebSocketHandler careConnectWebSocketHandler;

    @Autowired
    private NotificationWebSocketHandler notificationWebSocketHandler;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // Call/SMS notification WebSocket endpoint
        registry.addHandler(callNotificationHandler, "/ws/calls")
                .setAllowedOrigins("*")
                .withSockJS();

        // General CareConnect WebSocket endpoint for real-time updates
        registry.addHandler(careConnectWebSocketHandler, "/ws/careconnect")
                .setAllowedOrigins("*")
                .withSockJS();

        // Notification WebSocket endpoint (no SockJS fallback)
        registry.addHandler(notificationWebSocketHandler, "/ws/notifications")
                .setAllowedOrigins("*");
    }
}
