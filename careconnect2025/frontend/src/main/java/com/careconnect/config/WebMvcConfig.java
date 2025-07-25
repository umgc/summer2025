package com.careconnect.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:C:/Users/bompl/Documents/uploads/");
    }

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        // CORS Configuration
        registry.addMapping("/**")
                 .allowedOrigins(
                    "http://localhost:3000",
                    "https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com"
                ) 
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowCredentials(true);  // Allow credentials (cookies)
    }
}
