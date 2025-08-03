package com.careconnect.config;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;

import com.careconnect.security.JwtTokenProvider;
import com.careconnect.websocket.CallNotificationHandler;

import static org.mockito.Mockito.mock;

@TestConfiguration
@Profile("test")
public class CareconnectTestConfig {

    @Bean
    @Primary
    public JwtTokenProvider mockJwtTokenProvider() {
        return mock(JwtTokenProvider.class);
    }

    @Bean
    @Primary
    public CallNotificationHandler mockCallNotificationHandler() {
        return mock(CallNotificationHandler.class);
    }
}
