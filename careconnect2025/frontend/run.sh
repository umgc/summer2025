#!/bin/bash

# Database configuration
export JDBC_URI="jdbc:mysql://localhost:3306/careconnect?createDatabaseIfNotExist=true&useSSL=false&allowPublicKeyRetrieval=true"
export DB_USER="root"
export DB_PASSWORD="password"
export HIBERNATE_DDL_AUTO="update"

# Subscription price ID mappings
# Override the application properties with environment variables if needed
export SUBSCRIPTION_PREMIUM_PRICE_IDS="price_1RmqWxELoozGI1YxQql5rsvN"
export SUBSCRIPTION_STANDARD_PRICE_IDS="price_standard"

# Run the application
./mvnw spring-boot:run
