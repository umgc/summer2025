package com.careconnect.config.v1;

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
                .allowedOrigins("http://localhost:3000")  // update this ...make it configurable 
                .allowedMethods("GET", "POST", "PUT", "DELETE")
                .allowCredentials(true);  
    }
}
