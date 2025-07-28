package com.careconnect.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.DefaultCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.regions.providers.DefaultAwsRegionProviderChain;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.ssm.SsmClient;

@Configuration
public class AwsAccessConfig {


    @Bean
    public Region defaultAwsRegion() {
        return new DefaultAwsRegionProviderChain().getRegion();
    }


    @Bean
    public DefaultCredentialsProvider awsCredentialsProvider() {
        return DefaultCredentialsProvider.builder().asyncCredentialUpdateEnabled(true).build();
    }

    @Bean
    public S3Client s3Client() {
        return S3Client.builder()
                .region(defaultAwsRegion())
                .credentialsProvider(awsCredentialsProvider())
                .build();
    }

    @Bean
    public SsmClient ssmClient(DefaultCredentialsProvider credentialsProvider) {
        return SsmClient.builder()
                .credentialsProvider(credentialsProvider)
                .region(defaultAwsRegion())
                .build();
    }
}
