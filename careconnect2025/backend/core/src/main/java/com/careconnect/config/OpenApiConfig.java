package com.careconnect.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeIn;
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType;
import io.swagger.v3.oas.annotations.info.Contact;
import io.swagger.v3.oas.annotations.info.Info;
import io.swagger.v3.oas.annotations.info.License;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.security.SecurityScheme;
import io.swagger.v3.oas.annotations.servers.Server;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * OpenAPI configuration for CareConnect Backend API
 * 
 * This configuration provides comprehensive API documentation using OpenAPI 3.0.
 * It includes JWT authentication setup, server configuration, and API metadata.
 * 
 * Access the documentation at:
 * - Swagger UI: http://localhost:8080/swagger-ui.html
 * - OpenAPI JSON: http://localhost:8080/api-docs
 * 
 * @author CareConnect Team
 * @version 1.0
 * @since 2025
 */
@Configuration
@OpenAPIDefinition(
    info = @Info(
        title = "CareConnect Backend API",
        version = "1.0.0",
        description = """
            CareConnect Backend API provides comprehensive healthcare management services including:
            
            ## Features
            - **Authentication & Authorization**: JWT-based authentication with Google OAuth integration
            - **User Management**: Patient and caregiver registration, profile management
            - **Feed Management**: Social feed for patients and caregivers
            - **Comments System**: Interactive commenting on posts
            - **Gamification**: Points and achievements system
            - **Payment Integration**: Stripe-based payment processing
            - **Email Services**: Multi-provider email support (SendGrid, Mailgun, Mailtrap, etc.)
            - **File Upload**: Image and document upload capabilities
            
            ## Authentication
            Most endpoints require JWT authentication. Use the `/api/auth/login` endpoint to obtain a token.
            For Google OAuth, use the `/api/auth/google` endpoint.
            
            ## Rate Limiting
            API endpoints are rate-limited to ensure fair usage and system stability.
            
            ## Error Handling
            All API responses follow a consistent error format with appropriate HTTP status codes.
            """,
        contact = @Contact(
            name = "CareConnect Development Team",
            email = "support@careconnect.com",
            url = "https://careconnect.com"
        ),
        license = @License(
            name = "MIT License",
            url = "https://opensource.org/licenses/MIT"
        )
    ),
    servers = {
        @Server(
            url = "http://localhost:8080",
            description = "Development Server"
        ),
        @Server(
            url = "https://api.careconnect.com",
            description = "Production Server"
        )
    },
    security = {
        @SecurityRequirement(name = "JWT Authentication"),
        @SecurityRequirement(name = "Cookie Authentication"),
        @SecurityRequirement(name = "Basic Authentication")
    }
)
@SecurityScheme(
    name = "JWT Authentication",
    description = """
        JWT token authentication. 
        
        **How to authenticate:**
        1. Use the `/v1/api/auth/login` endpoint to obtain a JWT token
        2. Include the token in the Authorization header as: `Bearer {your-jwt-token}`
        3. The token is valid for 3 hours
        
        **Example:**
        ```
        Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
        ```
        """,
    scheme = "bearer",
    type = SecuritySchemeType.HTTP,
    bearerFormat = "JWT",
    in = SecuritySchemeIn.HEADER
)
@SecurityScheme(
    name = "Basic Authentication",
    description = """
        Basic HTTP authentication for testing purposes.
        
        **How to authenticate:**
        1. Use username (email) and password
        2. Format: `username:password` encoded in Base64
        3. Include in Authorization header as: `Basic {base64-encoded-credentials}`
        
        **Example:**
        ```
        Authorization: Basic dXNlckBleGFtcGxlLmNvbTpwYXNzd29yZA==
        ```
        """,
    type = SecuritySchemeType.HTTP,
    scheme = "basic"
)
@SecurityScheme(
    name = "Cookie Authentication",
    description = """
        Cookie-based authentication using HttpOnly cookies.
        
        **How it works:**
        1. Login through `/v1/api/auth/login` - sets an HttpOnly cookie automatically
        2. Browser automatically includes the cookie in subsequent requests
        3. Useful for web applications and testing in browser
        """,
    type = SecuritySchemeType.APIKEY,
    in = SecuritySchemeIn.COOKIE,
    paramName = "AUTH"
)
public class OpenApiConfig {
    // Configuration is handled through annotations
    // Bean configuration commented out temporarily to avoid conflicts
    
    /*
    @Bean
    public io.swagger.v3.oas.models.OpenAPI customOpenAPI() {
        return new io.swagger.v3.oas.models.OpenAPI()
            .info(new io.swagger.v3.oas.models.info.Info()
                .title("CareConnect Backend API")
                .version("1.0.0")
                .description("Enhanced API documentation with authentication guide"))
            .addServersItem(new io.swagger.v3.oas.models.servers.Server()
                .url("http://localhost:8080")
                .description("Development Server"));
    }
    */
}