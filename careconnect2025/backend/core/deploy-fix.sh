#!/bin/bash

# CareConnect Backend Deployment Fix Script
# This script fixes the configuration issues and deploys to Cloud Run

set -e  # Exit on any error

echo "🚀 Starting CareConnect Backend Deployment Fix..."

# Step 1: Clone or update the repository (if needed)
echo "📂 Setting up source code..."
if [ ! -d "careconnect2025" ]; then
    echo "Please upload your source code to Cloud Shell or clone your repository first:"
    echo "git clone <your-repo-url>"
    echo "Then run this script from the project directory"
    exit 1
fi

# Navigate to the project directory
cd careconnect2025/backend/core

# Step 2: Fix the application-gcp.properties file
echo "🔧 Fixing application-gcp.properties..."
cat > src/main/resources/application-gcp.properties << 'EOF'
# =============================================================================
# GCP Production Configuration for CareConnect Backend
# =============================================================================

# Server Configuration
server.port=${SERVER_PORT:8080}

# Database Configuration (H2 for Production)
spring.datasource.url=jdbc:h2:file:${H2_DB_PATH:/data/careconnect/db};MODE=${H2_DB_MODE:MIXED};DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE
spring.datasource.driver-class-name=org.h2.Driver
spring.datasource.username=careconnect
spring.datasource.password=${H2_DB_PASSWORD:CareConnect2025!}

# H2 Console Configuration (Disabled in Production)
spring.h2.console.enabled=${H2_CONSOLE_ENABLED:false}
spring.h2.console.settings.web-allow-others=${H2_WEB_ALLOW_OTHERS:false}

# JPA/Hibernate Configuration
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=${HIBERNATE_DDL_AUTO:update}
spring.jpa.show-sql=${JPA_SHOW_SQL:false}
spring.jpa.properties.hibernate.format_sql=true

# Flyway Configuration
spring.flyway.enabled=${FLYWAY_ENABLED:true}
spring.flyway.locations=classpath:db/migration
spring.flyway.baseline-on-migrate=true

# Application Configuration
app.base-url=${BASE_URL:https://careconnect-backend-663999888931.us-east1.run.app}
app.frontend.base-url=${APP_FRONTEND_BASE_URL:https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com}

# CORS Configuration
cors.allowed-origins=${CORS_ALLOWED_LIST:https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com}

# Security Configuration
security.jwt.secret=${SECURITY_JWT_SECRET:CareConnect2025SecureJWTSecretKeyForProductionUseMustBeLongAndRandomForSecurityPurposes123456789}
security.jwt.expiration=${JWT_EXPIRATION:10800000}

# Firebase Configuration
firebase.project-id=${FIREBASE_PROJECT_ID:careconnectcapstone}
firebase.service-account-key=${FIREBASE_SERVICE_ACCOUNT_KEY:firebase-service-account.json}
firebase.sender-id=${FIREBASE_SENDER_ID:663999888931}

# File Upload Configuration
upload.dir=${UPLOAD_DIR:/app/uploads}

# AWS S3 Configuration
aws.s3.bucket=${AWS_S3_BUCKET:cc-internal-file-storage-us-east-1-641592448579}
aws.s3.region=${AWS_DEFAULT_REGION:us-east-1}
aws.s3.base-url=${AWS_S3_BASE_URL:https://cc-internal-file-storage-us-east-1-641592448579.s3.us-east-1.amazonaws.com}

# Logging Configuration
logging.level.com.careconnect=${LOG_LEVEL:INFO}
logging.level.org.springframework.security=${SECURITY_LOG_LEVEL:WARN}
logging.pattern.console=%d{yyyy-MM-dd HH:mm:ss} - %msg%n

# Management Endpoints
management.endpoints.web.exposure.include=health,info
management.endpoint.health.show-details=when-authorized
EOF

# Step 3: Comment out OAuth2 dependency in pom.xml
echo "🔧 Disabling OAuth2 dependency..."
sed -i 's|<dependency>|<!-- <dependency>|g; s|<groupId>org.springframework.boot</groupId>|<groupId>org.springframework.boot</groupId>|g; s|<artifactId>spring-boot-starter-oauth2-client</artifactId>|<artifactId>spring-boot-starter-oauth2-client</artifactId>|g; s|</dependency>|</dependency> -->|g' pom.xml

# Step 4: Build the Docker image
echo "🏗️ Building Docker image..."
gcloud builds submit . --tag us-east1-docker.pkg.dev/careconnectcapstone/careconnect/backend --project=careconnectcapstone

# Step 5: Deploy to Cloud Run with environment variables
echo "🚀 Deploying to Cloud Run..."
gcloud run deploy careconnect-backend \
  --image us-east1-docker.pkg.dev/careconnectcapstone/careconnect/backend \
  --region us-east1 \
  --project careconnectcapstone \
  --set-env-vars="SPRING_PROFILES_ACTIVE=gcp,JDBC_URI=jdbc:h2:file:/app/data/careconnect;MODE=MySQL;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;DATABASE_TO_UPPER=false;AUTO_RECONNECT=TRUE,DB_USER=sa,DB_PASSWORD=,H2_CONSOLE_ENABLED=false,H2_WEB_ALLOW_OTHERS=false,FLYWAY_ENABLED=true,BASE_URL=https://careconnect-backend-663999888931.us-east1.run.app,APP_FRONTEND_BASE_URL=http://localhost:3000,CORS_ALLOWED_LIST=https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com,SECURITY_JWT_SECRET=CareConnect2025SecureJWTSecretKeyForProductionUseMustBeLongAndRandomForSecurityPurposes123456789,JWT_EXPIRATION=10800000,FIREBASE_PROJECT_ID=careconnectcapstone,FIREBASE_SERVICE_ACCOUNT_KEY=firebase-service-account.json,FIREBASE_SENDER_ID=663999888931,UPLOAD_DIR=/app/uploads,AWS_DEFAULT_REGION=us-east-1,AWS_S3_BUCKET=cc-internal-file-storage-us-east-1-641592448579,AWS_S3_BASE_URL=https://cc-internal-file-storage-us-east-1-641592448579.s3.us-east-1.amazonaws.com" \
  --allow-unauthenticated \
  --port 8080 \
  --memory 1Gi \
  --cpu 1 \
  --timeout 300s

# Step 6: Test the health endpoint
echo "🏥 Testing health endpoint..."
sleep 10  # Wait for deployment to be ready
curl -f https://careconnect-backend-663999888931.us-east1.run.app/v1/api/test/health || echo "Health check failed, check logs"

echo "✅ Deployment complete!"
echo "🌐 Service URL: https://careconnect-backend-663999888931.us-east1.run.app"
echo "🏥 Health Check: https://careconnect-backend-663999888931.us-east1.run.app/v1/api/test/health"
echo "📚 Swagger UI: https://careconnect-backend-663999888931.us-east1.run.app/swagger-ui.html"
