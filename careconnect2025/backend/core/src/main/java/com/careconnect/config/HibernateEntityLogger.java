package com.careconnect.config;

import jakarta.persistence.EntityManagerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class HibernateEntityLogger {

    @Bean
    public CommandLineRunner inspectEntities(EntityManagerFactory emf) {
        return args -> {
            System.out.println("✅ Entities detected by Hibernate:");
            emf.getMetamodel().getEntities().forEach(e ->
                    System.out.println("   • " + e.getName())
            );
        };
    }
}
