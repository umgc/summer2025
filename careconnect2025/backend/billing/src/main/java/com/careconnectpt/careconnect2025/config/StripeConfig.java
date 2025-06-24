package com.careconnectpt.careconnect2025.config;

import com.stripe.Stripe;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;

@Configuration
public class StripeConfig {

    /** Empty string is the default if the property is missing */
//    @Value("${stripe.secret-key}")
    private String secretKey = "agshdfgajsd";

    @PostConstruct
    void init() {
        if (secretKey == null || secretKey.isBlank()) {
            System.out.println("Stripe secret key not set – payments disabled");
            return;                             // Skip Stripe bootstrap
        }
        Stripe.apiKey = secretKey;
        System.out.println("Stripe key loaded.");
    }
}