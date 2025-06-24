package com.careconnectpt.careconnect2025.config;

import org.springframework.context.annotation.Configuration;



import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
class OpenApiConfig {
    @Bean
    OpenAPI apiInfo() {
        return new OpenAPI()
            .info(new Info()
                .title("CareConnect API")
                .version("1.0")
                .description("Patient & Care-giver platform"));
    }
}