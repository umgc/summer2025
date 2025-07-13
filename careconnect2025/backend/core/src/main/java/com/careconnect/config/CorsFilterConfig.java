package com.careconnect.config;

import jakarta.servlet.Filter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.List;

@Configuration
public class CorsFilterConfig {

    @Bean
    public Filter corsFilter() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(List.of(
                "http://localhost",
                "http://localhost:*",           // ✅ Allow any localhost port
                "http://127.0.0.1",
                "http://127.0.0.1:*",          // ✅ Allow any 127.0.0.1 port
                "http://10.0.2.2:8080",
                "http://localhost:50030",       // ✅ Specific Flutter web port
                "http://localhost:3000"         // ✅ Common dev port
        ));
        config.setAllowCredentials(true);
        config.setAllowedHeaders(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        // System.out.println("Custom CorsFilter applied.");
        return new CorsFilter(source);
    }
}
