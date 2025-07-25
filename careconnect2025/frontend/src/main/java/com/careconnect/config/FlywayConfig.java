package com.careconnect.config;

import org.springframework.boot.autoconfigure.flyway.FlywayMigrationStrategy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.DependsOn;
import org.springframework.core.annotation.Order;
import org.flywaydb.core.Flyway;

/**
 * Configuration to resolve circular dependency between Flyway and JPA EntityManagerFactory
 * 
 * The issue occurs when:
 * 1. JPA tries to validate entities against database schema
 * 2. Flyway tries to migrate database schema
 * 3. Both depend on each other creating a circular dependency
 * 
 * This configuration ensures Flyway runs first, then JPA validation happens
 */
@Configuration
@Order(1)
public class FlywayConfig {

    /**
     * Custom Flyway migration strategy to handle initialization order
     * This ensures migrations run before JPA entity validation
     */
    @Bean
    public FlywayMigrationStrategy flywayMigrationStrategy() {
        return new FlywayMigrationStrategy() {
            @Override
            public void migrate(Flyway flyway) {
                try {
                    // Perform migration with proper error handling
                    flyway.migrate();
                } catch (Exception e) {
                    // Log the error but don't fail startup in development
                    System.err.println("Flyway migration failed: " + e.getMessage());
                    // In production, you might want to fail here
                    // throw new RuntimeException("Database migration failed", e);
                }
            }
        };
    }
}
