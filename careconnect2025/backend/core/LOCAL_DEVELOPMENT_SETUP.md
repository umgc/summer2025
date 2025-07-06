# Local Development Environment Setup

## 🚀 Quick Start

### 1. Create Environment File
```bash
# Copy the example environment file
cp .env.example .env

# Edit with your actual values
nano .env  # or use your preferred editor
```

### 2. Load Environment Variables

**Option A: Using the load script (Recommended)**
```bash
# On macOS/Linux:
source load-env.sh
# or
. load-env.sh

# On Windows:
load-env.bat
```

**Option B: Manual export (macOS/Linux)**
```bash
export SECURITY_JWT_SECRET="your-secret-here"
export JDBC_URI="jdbc:mysql://localhost:3306/careconnect_db"
export DB_USER="your_username"
export DB_PASSWORD="your_password"
# ... continue for all required variables
```

**Option C: Using your shell's built-in support**
```bash
# If your shell supports it (bash, zsh)
set -a; source .env; set +a
```

### 3. Start the Application
```bash
# After loading environment variables
./mvnw spring-boot:run

# Or with a specific profile
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

## 🔧 Environment Variables Setup

### Required Variables
Create a `.env` file in the project root with these variables:

```bash
# Database Configuration
JDBC_URI=jdbc:mysql://localhost:3306/careconnect_db
DB_USER=your_db_username
DB_PASSWORD=your_db_password

# Security
SECURITY_JWT_SECRET=your-super-secure-jwt-secret-key-here-at-least-32-characters
JWT_EXPIRATION=10800000

# Email Configuration
EMAIL_PROVIDER=mailtrap
MAIL_PASSWORD=your_mailtrap_password_here

# API Keys
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
STRIPE_WEBHOOK_SIGNING_SECRET=whsec_your_stripe_webhook_secret_here
OPENAI_API_KEY=sk-your_openai_api_key_here

# OAuth Configuration
GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
FITBIT_CLIENT_ID=your_fitbit_client_id_here
FITBIT_CLIENT_SECRET=your_fitbit_client_secret_here

# Optional (have defaults)
UPLOAD_DIR=/path/to/your/uploads
BASE_URL=http://localhost:8080
APP_FRONTEND_BASE_URL=http://localhost:3000
```

### Generating Secure JWT Secret
```bash
# Generate a secure JWT secret
openssl rand -base64 32

# Or use this online generator (for development only):
# https://www.allkeysgenerator.com/Random/Security-Encryption-Key-Generator.aspx
```

## 📋 Development Workflow

### 1. Start Development Session
```bash
# Navigate to project directory
cd /path/to/careconnect2025/backend/core

# Load environment variables
source load-env.sh

# Start the application
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

### 2. Running Tests
```bash
# Load environment variables first
source load-env.sh

# Run all tests
./mvnw test

# Run specific test
./mvnw test -Dtest=CareconnectBackendApplicationTests
```

### 3. Database Operations
```bash
# Load environment variables first
source load-env.sh

# Run Flyway migrations
./mvnw flyway:migrate

# Flyway info
./mvnw flyway:info

# Flyway repair (if needed)
./mvnw flyway:repair
```

## 🔒 Security Notes

### ⚠️ Important Security Practices

1. **Never commit the `.env` file** - It's in .gitignore for a reason
2. **Never commit `load-env.sh`** - It's also in .gitignore
3. **Use different secrets for different environments** (dev, staging, prod)
4. **Rotate secrets regularly** in production
5. **Use a secure secret manager** in production (AWS Secrets Manager, HashiCorp Vault, etc.)

### 🔐 Environment-Specific Configurations

**Development:**
```bash
EMAIL_PROVIDER=console  # Logs emails to console
SECURITY_JWT_SECRET=dev-secret-32-chars-minimum-length
```

**Production:**
```bash
EMAIL_PROVIDER=sendgrid  # Or your production email provider
SECURITY_JWT_SECRET=super-secure-production-secret-from-secret-manager
```

## 🛠️ Troubleshooting

### Common Issues

1. **"Required environment variable not set"**
   - Check that all required variables are in your `.env` file
   - Verify you've loaded the environment variables: `source load-env.sh`

2. **"Application failed to start"**
   - Verify database is running and accessible
   - Check JWT secret is at least 32 characters
   - Ensure all required API keys are valid

3. **"Flyway migration failed"**
   - Check database connection
   - Verify database user has proper permissions
   - Run `./mvnw flyway:repair` if needed

### Verification Commands

```bash
# Check if environment variables are loaded
echo $SECURITY_JWT_SECRET
echo $JDBC_URI

# Test database connection
./mvnw flyway:info

# Verify application can start
./mvnw spring-boot:run --dry-run
```

## 📞 Support

If you encounter issues:
1. Check this guide first
2. Verify all environment variables are set correctly
3. Check application logs for specific error messages
4. Ensure all required services (database, etc.) are running

---

**Note**: The `load-env.sh` and `load-env.bat` scripts are automatically excluded from Git commits for security.
