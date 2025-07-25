package com.careconnect.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.ClassPathResource;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.io.InputStream;

@Configuration
@Profile("!test")  // Don't load this configuration during tests
@ConditionalOnProperty(name = "firebase.enabled", havingValue = "true", matchIfMissing = true)
public class FirebaseConfig {
    
    private static final Logger logger = LoggerFactory.getLogger(FirebaseConfig.class);
    
    @Value("${firebase.project-id:careconnectcapstone}")
    private String projectId;
    
    @Value("${firebase.service-account-key:firebase-service-account.json}")
    private String serviceAccountKey;
    
    @PostConstruct
    public void initializeFirebase() throws IOException {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                ClassPathResource resource = new ClassPathResource(serviceAccountKey);
                
                if (!resource.exists()) {
                    logger.warn("Firebase service account key file not found: {}. Firebase will be disabled.", serviceAccountKey);
                    logger.info("To enable Firebase, please add the {} file to your classpath", serviceAccountKey);
                    return; // Exit gracefully instead of throwing exception
                }
                
                try (InputStream serviceAccount = resource.getInputStream()) {
                    FirebaseOptions options = FirebaseOptions.builder()
                            .setCredentials(GoogleCredentials.fromStream(serviceAccount))
                            .setProjectId(projectId)
                            .build();
                    
                    FirebaseApp.initializeApp(options);
                    logger.info("Firebase initialized successfully for project: {}", projectId);
                }
            } else {
                logger.info("Firebase app already initialized");
            }
        } catch (Exception e) {
            logger.warn("Failed to initialize Firebase: {}. Firebase will be disabled.", e.getMessage());
            logger.debug("Firebase initialization error details", e);
            // Don't throw exception - allow application to start without Firebase
        }
    }
    
    @Bean
    public FirebaseMessaging firebaseMessaging() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                logger.warn("Firebase not initialized, FirebaseMessaging bean will not be available");
                return null;
            }
            return FirebaseMessaging.getInstance();
        } catch (Exception e) {
            logger.warn("Failed to create FirebaseMessaging bean: {}", e.getMessage());
            return null;
        }
    }
}
