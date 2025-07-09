package com.careconnect.controller;

import com.careconnect.dto.*;
import com.careconnect.exception.OAuthException;
import com.careconnect.model.User;
import com.careconnect.service.AuthService;
import com.careconnect.service.PasswordResetService;
import com.careconnect.security.JwtTokenProvider;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;

import java.io.IOException;
import java.net.URLEncoder;
import java.util.Collections;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/v1/api/auth")
@Tag(name = "Authentication", description = "Authentication and authorization endpoints including login, registration, email verification, and OAuth")
public class AuthController {

    @Autowired
    private AuthService authService;

    @Autowired
    private PasswordResetService reset;

    @Autowired
    private JwtTokenProvider jwt;

    @Autowired
    private ObjectMapper objectMapper;

    @Value("${frontend.base-url}")
    private String frontendBaseUrl;    // --- Register new user ---
    @PostMapping("/register")
    @Operation(
        summary = "📝 Register a new user",
        description = """
            Register a new patient or caregiver account. 
            
            **For Swagger UI Testing:**
            1. Use this endpoint to create a test account
            2. Check your email for verification (if email is configured)
            3. Use the `/login` endpoint to get a JWT token
            4. Click "Authorize" and enter the token for testing protected endpoints
            
            **Registration Flow:**
            1. Submit registration with email, password, and role
            2. Account is created (may require email verification)
            3. Use the email/password to login and get JWT token
            4. Use JWT token to access protected endpoints
            
            **Test Example:**
            ```json
            {
                "email": "test@example.com",
                "password": "password123",
                "name": "Test User",
                "role": "PATIENT"
            }
            ```
            """,
        tags = {"🔑 Authentication"},
        security = {} // No authentication required for registration
    )
    @ApiResponses({
        @ApiResponse(
            responseCode = "200",
            description = "Registration successful, verification email sent",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(value = """
                    {
                        "message": "Registration successful. Please check your email to verify your account.",
                        "userId": 123
                    }
                    """)
            )
        ),
        @ApiResponse(
            responseCode = "400",
            description = "Invalid request data",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(value = """
                    {
                        "error": "Email already exists"
                    }
                    """)
            )
        )
    })
    public ResponseEntity<?> register(
        @Parameter(description = "User registration details", required = true)
        @RequestBody RegisterRequest request
    ) {
        // Delegate to AuthService for registration & verification logic
        return authService.register(request);
    }

    @PostMapping("/login")
    @Operation(
        summary = "Login user",
        description = """
            Authenticate user with email and password. Returns JWT token for API access.
            
            **For Swagger UI Testing:**
            1. Use this endpoint to login and get a JWT token
            2. Copy the `token` from the response
            3. Click the "Authorize" button (🔒) at the top of this page
            4. Enter: `Bearer {your-token-here}`
            5. Now you can test all protected endpoints!
            
            **Response includes:**
            - `token`: JWT token for API authentication (valid for 3 hours)
            - `user`: User profile information
            - `patientId`/`caregiverId`: Role-specific ID (if applicable)
            
            **Test Credentials:**
            If you need test credentials, use the registration endpoint first.
            """,
        tags = {"Authentication"},
        security = {} // No authentication required for login
    )
    @ApiResponses({
        @ApiResponse(
            responseCode = "200",
            description = "Login successful",
            content = @Content(
                mediaType = "application/json",
                schema = @Schema(implementation = LoginResponse.class),
                examples = @ExampleObject(value = """
                    {
                        "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                        "user": {
                            "id": 123,
                            "name": "John Doe",
                            "email": "john@example.com",
                            "role": "PATIENT"
                        },
                        "patientId": 456,
                        "caregiverId": null
                    }
                    """)
            )
        ),
        @ApiResponse(
            responseCode = "401",
            description = "Invalid credentials",
            content = @Content(
                mediaType = "application/json",
                examples = @ExampleObject(value = """
                    {
                        "error": "Invalid credentials"
                    }
                    """)
            )
        )
    })
    public ResponseEntity<LoginResponse> loginV2(
        @Parameter(description = "Login credentials", required = true)
        @RequestBody LoginRequest req, 
        HttpServletResponse response
    ) {
        return ResponseEntity.ok(authService.loginV2(req, response));
    }

    // --- Email verification ---
    @GetMapping("/verify/{token}")
    @Operation(
        summary = "✉️ Verify email address",
        description = "Verify user email address using verification token",
        tags = {"🔑 Authentication"},
        security = {} // No authentication required for email verification
    )
    public ResponseEntity<?> verify(@PathVariable String token) {
        return authService.verifyToken(token);
    }

    @PostMapping("/password/forgot")
    @Operation(
        summary = "🔐 Request password reset",
        description = "Request a password reset link to be sent via email",
        tags = {"🔑 Authentication"},
        security = {} // No authentication required for password reset request
    )
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request,
                       HttpServletRequest req) {
        String email = request.get("email");
        if (email == null || email.isEmpty()) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("error", "Email is required"));
        }
        
        // Log password reset request
        // System.out.println("🔄 Password reset requested for email: " + email);
        
        // Use frontend URL for password reset link instead of backend URL
        String appUrl = frontendBaseUrl;
        try {
            reset.startReset(email, appUrl);
            // System.out.println("✅ Password reset process initiated for: " + email);
            return ResponseEntity.ok(Collections.singletonMap("message", 
                "If an account with this email exists, you will receive a password reset link."));
        } catch (Exception e) {
            System.err.println("❌ Password reset failed for " + email + ": " + e.getMessage());
            e.printStackTrace();
            // Don't reveal if email exists or not for security
            return ResponseEntity.ok(Collections.singletonMap("message", 
                "If an account with this email exists, you will receive a password reset link."));
        }
    }



    @PostMapping("/password/change")
    public ResponseEntity<?> changePassword(@RequestBody ChangePasswordRequest request,
                                          HttpServletRequest httpRequest) {
        try {
            String token = extractTokenFromRequest(httpRequest);
            if (token == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Collections.singletonMap("error", "Authentication required"));
            }
            
            String email = jwt.getEmailFromToken(token);
            return authService.changePassword(email, request.currentPassword(), request.newPassword());
            
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("error", e.getMessage()));
        }
    }

    @GetMapping("/password/reset")
    public ResponseEntity<?> validateResetToken(@RequestParam String token) {
        try {
            boolean isValid = reset.isTokenValid(token);
            if (isValid) {
                return ResponseEntity.ok(Collections.singletonMap("message", "Token is valid"));
            } else {
                return ResponseEntity.badRequest().body(Collections.singletonMap("error", "Invalid or expired token"));
            }
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(Collections.singletonMap("error", "Invalid or expired token"));
        }
    }

    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("AUTH".equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }

    /**
     * Determine specific OAuth error type based on exception
     */
    private String determineOAuthErrorType(Exception e) {
        if (e == null || e.getMessage() == null) {
            return "oauth_failed";
        }
        
        String errorMessage = e.getMessage().toLowerCase();
        String exceptionType = e.getClass().getSimpleName().toLowerCase();
        
        // Check for specific OAuth error patterns
        if (errorMessage.contains("access_denied") || errorMessage.contains("denied")) {
            return "access_denied";
        }
        
        if (errorMessage.contains("invalid_grant") || errorMessage.contains("invalid_code")) {
            return "invalid_grant";
        }
        
        if (errorMessage.contains("invalid_client") || errorMessage.contains("unauthorized")) {
            return "invalid_client";
        }
        
        if (errorMessage.contains("invalid_request") || errorMessage.contains("bad request")) {
            return "invalid_request";
        }
        
        if (errorMessage.contains("temporarily_unavailable") || errorMessage.contains("server error") || 
            errorMessage.contains("503") || errorMessage.contains("502") || errorMessage.contains("500")) {
            return "temporarily_unavailable";
        }
        
        if (errorMessage.contains("invalid_scope") || errorMessage.contains("insufficient_scope") ||
            errorMessage.contains("insufficient permissions")) {
            return "invalid_scope";
        }
        
        if (errorMessage.contains("token") && (errorMessage.contains("invalid") || errorMessage.contains("expired"))) {
            return "invalid_token";
        }
        
        if (errorMessage.contains("timeout") || errorMessage.contains("connect") || 
            errorMessage.contains("network") || errorMessage.contains("socket")) {
            return "network_error";
        }
        
        if (errorMessage.contains("email") && errorMessage.contains("retrieve")) {
            return "invalid_response";
        }
        
        // Check exception types
        if (exceptionType.contains("httpclient") || exceptionType.contains("restclient")) {
            return "api_error";
        }
        
        if (exceptionType.contains("timeout") || exceptionType.contains("socket")) {
            return "network_error";
        }
        
        if (exceptionType.contains("json") || exceptionType.contains("parse")) {
            return "invalid_response";
        }
        
        if (exceptionType.contains("authentication")) {
            return "authentication_failed";
        }
        
        if (exceptionType.contains("oauth")) {
            return "oauth_failed";
        }
        
        // Default fallback
        return "oauth_failed";
    }


    @GetMapping("/sso/google")
    public void googleLogin(HttpServletResponse response) throws IOException {
        String googleAuthUrl = authService.buildGoogleOAuthUrl();
        response.sendRedirect(googleAuthUrl);
    }

    @GetMapping("/sso/google/callback")
    public void googleCallback(
            @RequestParam("code") String code,
            @RequestParam(value = "state", required = false) String state,
            @RequestParam(value = "error", required = false) String error,
            HttpServletResponse response) throws IOException {

        if (error != null) {
            // Handle error - redirect to frontend with error
            response.sendRedirect(frontendBaseUrl + "/oauth/callback?error=" + error);
            return;
        }

        try {
            // Delegate OAuth processing to AuthService
            LoginResponse loginResponse = authService.processGoogleOAuth(code, response);

            String jwt = loginResponse.token();
            String userData = objectMapper.writeValueAsString(loginResponse);

            response.sendRedirect(frontendBaseUrl + "/oauth/callback?token=" + jwt +
                    "&user=" + URLEncoder.encode(userData, "UTF-8"));

        } catch (OAuthException e) {
            // Handle specific OAuth errors
            System.err.println("Google OAuth error: " + e.getMessage());
            e.printStackTrace();
            
            response.sendRedirect(frontendBaseUrl + "/oauth/callback?error=" + e.getErrorType());
        } catch (Exception e) {
            // Log the error for debugging
            System.err.println("Google OAuth callback error: " + e.getMessage());
            e.printStackTrace();
            
            // Determine specific error type and redirect with appropriate error
            String errorType = determineOAuthErrorType(e);
            response.sendRedirect(frontendBaseUrl + "/oauth/callback?error=" + errorType);
        }
    }
}
