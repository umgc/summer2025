package com.deeptrain.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class WebClientConfig {

    @Bean
    public WebClient deepSeekClient() {
        return WebClient.builder()
                .baseUrl("https://api.deepseek.com") // Replace with real DeepSeek API base URL
                .build();
    }
}
