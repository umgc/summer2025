package com.careconnect.config;

import com.careconnect.websocket.CallNotificationHandler;
import com.careconnect.websocket.CareConnectWebSocketHandler;
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

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // Call/SMS notification WebSocket endpoint
        registry.addHandler(callNotificationHandler, "/ws/calls")
                .setAllowedOrigins("*") // Configure for your frontend domain in production
                .withSockJS(); // Optional: fallback for older browsers
        
        // General CareConnect WebSocket endpoint for real-time updates
        registry.addHandler(careConnectWebSocketHandler, "/ws/careconnect")
                .setAllowedOrigins("*")
                .withSockJS();
    }
}
