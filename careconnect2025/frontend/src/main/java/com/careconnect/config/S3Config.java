package com.careconnect.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import com.careconnect.dto.S3Props;

@Configuration
public class S3Config {

    @Autowired
    private S3Props s3Props;

    @Bean
    public S3Client s3Client() {
        return S3Client.builder()
                .region(Region.of(s3Props.getRegion()))
                .credentialsProvider(DefaultCredentialsProvider.builder().asyncCredentialUpdateEnabled(true).build())
                .build();
    }
}