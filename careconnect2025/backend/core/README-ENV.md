# Environment Configuration Guide

## Overview
This guide explains how to set up environment variables for the CareConnect backend application.

## Files

### `.env.example`
Template file containing all required environment variables with placeholder values.

### `.env`
Your actual environment file with real credentials (should be in `.gitignore`).

### `load-env.sh` (Linux/macOS)
Script to load environment variables and start the application on Unix-like systems.

### `load-env.bat` (Windows)
Script to load environment variables and start the application on Windows.

### `env-entry.sh`
Docker entry point script that loads environment variables in containerized environments.

## Setup Instructions

### 1. Create your environment file
```bash
# Copy the template
cp .env.example .env

# Edit with your actual values
nano .env  # or use your preferred editor
```

### 2. Required Variables
These environment variables are **required** for the application to start:

- `JDBC_URI` - Database connection string
- `DB_USER` - Database username  
- `DB_PASSWORD` - Database password
- `SECURITY_JWT_SECRET` - Secret key for JWT tokens (minimum 256 bits)

### 3. Firebase Configuration (Required for Notifications)
For Firebase push notifications to work, you must set:

- `FIREBASE_PROJECT_ID=careconnectcapstone`
- `FIREBASE_SENDER_ID=663999888931` 
- `FIREBASE_SERVICE_ACCOUNT_KEY=firebase-service-account.json`

**Important**: Download the Firebase service account JSON file from your Firebase Console and place it at:
```
src/main/resources/firebase-service-account.json
```

### 4. Optional Services
Configure these based on which services you plan to use:

#### Email Services (Choose one)
- **Resend**: Set `RESEND_API_KEY`
- **SendGrid**: Set `SENDGRID_API_KEY`  
- **Mailgun**: Set `MAILGUN_API_KEY` and `MAILGUN_DOMAIN`

#### Payment Processing
- `STRIPE_SECRET_KEY`
- `STRIPE_WEBHOOK_SIGNING_SECRET`

#### AI Integration
- `OPENAI_API_KEY`

#### OAuth Providers
- **Google**: `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET`
- **Fitbit**: `FITBIT_CLIENT_ID`, `FITBIT_CLIENT_SECRET`

#### File Storage
- **Local**: `UPLOAD_DIR`
- **AWS S3**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_S3_BUCKET`

## Usage

### Development (Local)

#### Linux/macOS
```bash
# Make script executable
chmod +x load-env.sh

# Load environment and start application
./load-env.sh mvn spring-boot:run

# Or load environment and run JAR
./load-env.sh java -jar target/careconnect-backend.jar
```

#### Windows
```cmd
# Load environment and start application
load-env.bat mvn spring-boot:run

# Or load environment and run JAR  
load-env.bat java -jar target/careconnect-backend.jar
```

### Docker/Production
The `env-entry.sh` script is used as the Docker entry point and automatically loads the `.env` file if present in the container.

## Security Best Practices

### 1. Keep credentials secure
- Never commit `.env` files to version control
- Use strong, unique passwords and API keys
- Rotate secrets regularly

### 2. Environment-specific files
Consider using different environment files for different stages:
- `.env.development`
- `.env.staging`  
- `.env.production`

### 3. Production deployment
For production, use secure secrets management instead of `.env` files:
- AWS Secrets Manager
- Azure Key Vault
- HashiCorp Vault
- Kubernetes Secrets

## Troubleshooting

### Missing environment variables
The loader scripts will check for critical variables and display warnings for missing ones.

### Firebase setup issues
1. Ensure `firebase-service-account.json` is in `src/main/resources/`
2. Verify the JSON file contains valid service account credentials
3. Check that your Firebase project ID matches `FIREBASE_PROJECT_ID`

### Database connection issues
1. Verify database is running and accessible
2. Check `JDBC_URI` format matches your database setup
3. Ensure `DB_USER` has necessary permissions

### JWT token issues
1. `SECURITY_JWT_SECRET` must be at least 256 bits (32+ characters)
2. Use a cryptographically secure random string
3. Keep the secret consistent across application restarts

## Example Production Setup

```bash
# Production environment with external secrets
export JDBC_URI=$(aws ssm get-parameter --name "/careconnect/prod/db/uri" --with-decryption --query 'Parameter.Value' --output text)
export DB_PASSWORD=$(aws ssm get-parameter --name "/careconnect/prod/db/password" --with-decryption --query 'Parameter.Value' --output text)
export SECURITY_JWT_SECRET=$(aws ssm get-parameter --name "/careconnect/prod/jwt/secret" --with-decryption --query 'Parameter.Value' --output text)

# Start application
java -jar careconnect-backend.jar
```
