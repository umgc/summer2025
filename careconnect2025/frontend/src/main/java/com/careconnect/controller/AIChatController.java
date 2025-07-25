package com.careconnect.controller;

import com.careconnect.dto.*;
import com.careconnect.model.ChatConversation;
import com.careconnect.service.AIChatService;
import com.careconnect.service.PatientAIConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/ai-chat")
@RequiredArgsConstructor
@Tag(name = "AI Chat", description = "AI-powered chat functionality with medical context")
public class AIChatController {
    
    private final AIChatService aiChatService;
    private final PatientAIConfigService patientAIConfigService;
    
    @PostMapping("/chat")
    @Operation(
        summary = "Send chat message to AI",
        description = "Send a message to AI with optional medical context. Creates new conversation if conversationId not provided."
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Chat response received successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid request data"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "403", description = "Access denied"),
        @ApiResponse(responseCode = "500", description = "Internal server error")
    })
    @PreAuthorize("hasRole('PATIENT') or hasRole('CAREGIVER') or hasRole('FAMILY_MEMBER')")
    public Mono<ResponseEntity<ChatResponse>> sendMessage(
            @Valid @RequestBody ChatRequest request) {
        
        log.info("Processing chat request for patient: {}, user: {}", request.getPatientId(), request.getUserId());
        
        return aiChatService.processChat(request)
                .map(response -> {
                    if (response.getSuccess()) {
                        return ResponseEntity.ok(response);
                    } else {
                        return ResponseEntity.badRequest().body(response);
                    }
                })
                .onErrorReturn(ResponseEntity.status(500).body(
                    ChatResponse.builder()
                            .success(false)
                            .errorMessage("An unexpected error occurred")
                            .errorCode("INTERNAL_ERROR")
                            .build()
                ));
    }
    
    @GetMapping("/conversations/{patientId}")
    @Operation(
        summary = "Get patient's chat conversations",
        description = "Retrieve all active chat conversations for a specific patient"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Conversations retrieved successfully"),
        @ApiResponse(responseCode = "403", description = "Access denied"),
        @ApiResponse(responseCode = "404", description = "Patient not found")
    })
    @PreAuthorize("hasRole('PATIENT') or hasRole('CAREGIVER') or hasRole('FAMILY_MEMBER')")
    public ResponseEntity<List<ChatConversationSummary>> getPatientConversations(
            @Parameter(description = "Patient ID") @PathVariable Long patientId) {
        
        log.info("Retrieving conversations for patient: {}", patientId);
        
        try {
            List<ChatConversationSummary> conversations = aiChatService.getPatientConversations(patientId);
            return ResponseEntity.ok(conversations);
        } catch (Exception e) {
            log.error("Error retrieving conversations for patient {}: ", patientId, e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/conversation/{conversationId}/messages")
    @Operation(
        summary = "Get conversation messages",
        description = "Retrieve all messages from a specific conversation"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Messages retrieved successfully"),
        @ApiResponse(responseCode = "403", description = "Access denied"),
        @ApiResponse(responseCode = "404", description = "Conversation not found")
    })
    @PreAuthorize("hasRole('PATIENT') or hasRole('CAREGIVER') or hasRole('FAMILY_MEMBER')")
    public ResponseEntity<List<ChatMessageSummary>> getConversationMessages(
            @Parameter(description = "Conversation ID") @PathVariable String conversationId) {
        
        log.info("Retrieving messages for conversation: {}", conversationId);
        
        try {
            List<ChatMessageSummary> messages = aiChatService.getConversationMessages(conversationId);
            return ResponseEntity.ok(messages);
        } catch (Exception e) {
            log.error("Error retrieving messages for conversation {}: ", conversationId, e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/conversation/{conversationId}/deactivate")
    @Operation(
        summary = "Deactivate conversation",
        description = "Mark a conversation as inactive (soft delete)"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Conversation deactivated successfully"),
        @ApiResponse(responseCode = "403", description = "Access denied"),
        @ApiResponse(responseCode = "404", description = "Conversation not found")
    })
    @PreAuthorize("hasRole('PATIENT') or hasRole('CAREGIVER')")
    public ResponseEntity<Void> deactivateConversation(
            @Parameter(description = "Conversation ID") @PathVariable String conversationId) {
        
        log.info("Deactivating conversation: {}", conversationId);
        
        try {
            aiChatService.deactivateConversation(conversationId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Error deactivating conversation {}: ", conversationId, e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    // AI Configuration endpoints
    @GetMapping("/config/{patientId}")
    @Operation(
        summary = "Get patient AI configuration",
        description = "Retrieve AI configuration settings for a specific patient"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Configuration retrieved successfully"),
        @ApiResponse(responseCode = "403", description = "Access denied"),
        @ApiResponse(responseCode = "404", description = "Patient not found")
    })
    @PreAuthorize("hasRole('PATIENT') or hasRole('CAREGIVER')")
    public ResponseEntity<PatientAIConfigDTO> getPatientAIConfig(
            @Parameter(description = "Patient ID") @PathVariable Long patientId) {
        
        log.info("Retrieving AI config for patient: {}", patientId);
        
        try {
            PatientAIConfigDTO config = patientAIConfigService.getPatientAIConfig(patientId);
            return ResponseEntity.ok(config);
        } catch (Exception e) {
            log.error("Error retrieving AI config for patient {}: ", patientId, e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/config")
    @Operation(
        summary = "Create or update patient AI configuration",
        description = "Create or update AI configuration settings for a patient"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Configuration updated successfully"),
        @ApiResponse(responseCode = "201", description = "Configuration created successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid configuration data"),
        @ApiResponse(responseCode = "403", description = "Access denied")
    })
    @PreAuthorize("hasRole('PATIENT') or hasRole('CAREGIVER')")
    public ResponseEntity<PatientAIConfigDTO> savePatientAIConfig(
            @Valid @RequestBody PatientAIConfigDTO configDTO) {
        
        log.info("Saving AI config for patient: {}", configDTO.getPatientId());
        
        try {
            PatientAIConfigDTO savedConfig = patientAIConfigService.savePatientAIConfig(configDTO);
            boolean isNew = configDTO.getId() == null;
            return isNew ? ResponseEntity.status(201).body(savedConfig) : ResponseEntity.ok(savedConfig);
        } catch (Exception e) {
            log.error("Error saving AI config for patient {}: ", configDTO.getPatientId(), e);
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/config/{patientId}")
    @Operation(
        summary = "Deactivate patient AI configuration",
        description = "Deactivate AI configuration for a patient (soft delete)"
    )
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Configuration deactivated successfully"),
        @ApiResponse(responseCode = "403", description = "Access denied"),
        @ApiResponse(responseCode = "404", description = "Configuration not found")
    })
    @PreAuthorize("hasRole('PATIENT') or hasRole('CAREGIVER')")
    public ResponseEntity<Void> deactivatePatientAIConfig(
            @Parameter(description = "Patient ID") @PathVariable Long patientId) {
        
        log.info("Deactivating AI config for patient: {}", patientId);
        
        try {
            patientAIConfigService.deactivatePatientAIConfig(patientId);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            log.error("Error deactivating AI config for patient {}: ", patientId, e);
            return ResponseEntity.badRequest().build();
        }
    }
}
