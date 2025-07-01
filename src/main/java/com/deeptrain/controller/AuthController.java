package com.deeptrain.controller;

import lombok.RequiredArgsConstructor;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.deeptrain.dto.ConfirmRequest;
import com.deeptrain.dto.LoginRequest;
import com.deeptrain.dto.LoginResponse;
import com.deeptrain.dto.SignInRequest;
import com.deeptrain.dto.SignupRequest;
import com.deeptrain.service.AuthService;

import software.amazon.awssdk.services.cognitoidentityprovider.CognitoIdentityProviderClient;
import software.amazon.awssdk.services.cognitoidentityprovider.model.*;


@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

  
    private final String clientId = "6fa6tmfsbpb0r8rkjlm1tfgtj0"; // same as your Flutter app
    private final CognitoIdentityProviderClient cognitoClient;
    private final AuthService authService;

  
    @PostMapping("/signup")
    public ResponseEntity<String> signUp(@RequestBody SignupRequest request) {
        SignUpRequest signUpRequest = SignUpRequest.builder()
                .clientId(clientId)
                .username(request.getEmail())
                .password(request.getPassword())
                .userAttributes(
                        AttributeType.builder().name("email").value(request.getEmail()).build(),
                        AttributeType.builder().name("given_name").value(request.getFirstName()).build(),
                        AttributeType.builder().name("family_name").value(request.getLastName()).build()
                )
                .build();

        cognitoClient.signUp(signUpRequest);
        return ResponseEntity.ok("Sign-up successful");
    }

    @PostMapping("/confirm")
    public ResponseEntity<String> confirmSignUp(@RequestBody ConfirmRequest request) {
        ConfirmSignUpRequest confirmRequest = ConfirmSignUpRequest.builder()
                .clientId(clientId)
                .username(request.getEmail())
                .confirmationCode(request.getCode())
                .build();

        cognitoClient.confirmSignUp(confirmRequest);
        return ResponseEntity.ok("User confirmed");
    }

    @PostMapping("/signin")
    public ResponseEntity<String> signIn(@RequestBody SignInRequest request) {
        AdminInitiateAuthRequest authRequest = AdminInitiateAuthRequest.builder()
                .userPoolId("us-east-1_XXXXX") // <- replace with actual User Pool ID
                .clientId(clientId)
                .authFlow(AuthFlowType.ADMIN_USER_PASSWORD_AUTH)
                .authParameters(Map.of(
                        "USERNAME", request.getEmail(),
                        "PASSWORD", request.getPassword()
                ))
                .build();

        AdminInitiateAuthResponse authResponse = cognitoClient.adminInitiateAuth(authRequest);

        String idToken = authResponse.authenticationResult().idToken();
        return ResponseEntity.ok(idToken);
    }
  

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(@RequestBody LoginRequest loginRequest) {
        String token = authService.authenticate(loginRequest.getEmail(), loginRequest.getPassword());
        return ResponseEntity.ok(new LoginResponse(token));
    }
}
