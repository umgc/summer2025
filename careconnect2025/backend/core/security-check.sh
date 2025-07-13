#!/bin/bash
# Quick test script to verify environment variables are properly required

echo "🔐 Testing CareConnect Backend Security Configuration..."
echo ""

# Check if .env.example exists
if [ -f ".env.example" ]; then
    echo "✅ .env.example file exists"
else
    echo "❌ .env.example file missing"
    exit 1
fi

# Check if .gitignore includes .env
if grep -q "\.env" .gitignore; then
    echo "✅ .gitignore includes .env files"
else
    echo "❌ .gitignore missing .env exclusions"
    exit 1
fi

# Check if application.properties has no hardcoded secrets
if grep -q "dc5d33d2b9eb02f71f171297f7a8e7f7" src/main/resources/application.properties; then
    echo "❌ Hardcoded secrets found in application.properties"
    exit 1
else
    echo "✅ No hardcoded secrets in application.properties"
fi

# Check if critical environment variables are referenced
REQUIRED_VARS=(
    "SECURITY_JWT_SECRET"
    "JDBC_URI"
    "DB_USER"
    "DB_PASSWORD"
    "MAIL_PASSWORD"
    "STRIPE_SECRET_KEY"
    "OPENAI_API_KEY"
)

for var in "${REQUIRED_VARS[@]}"; do
    if grep -q "\${$var}" src/main/resources/application.properties; then
        echo "✅ $var is properly referenced"
    else
        echo "❌ $var is missing or not properly referenced"
        exit 1
    fi
done

echo ""
echo "🎉 All security checks passed!"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env"
echo "2. Fill in all required environment variables"
echo "3. Generate JWT secret with: openssl rand -base64 32"
echo "4. Start the application"
echo ""
echo "For detailed setup instructions, see SECURITY_CONFIG.md"
