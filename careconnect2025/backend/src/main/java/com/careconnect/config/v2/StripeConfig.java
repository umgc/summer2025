package com.careconnect.config.v2;

import com.stripe.Stripe;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Bean;

import javax.annotation.PostConstruct;

@Configuration
public class StripeConfig {

    @Value("${v2.stripe.secret-key:}")   
    private String secretKey;

    @PostConstruct
    public void init() {
        if (secretKey.isBlank()) {
            System.out.println("⚠️  Stripe secret key not set – payments disabled");
        } else {
            Stripe.apiKey = secretKey;
            System.out.println("✅ Stripe key loaded");
        }
    }
}