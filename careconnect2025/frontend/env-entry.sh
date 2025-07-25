#!/bin/bash
# ================================
# CareConnect Docker Environment Entry Point
# ================================

set -e  # Exit on error

echo "CareConnect Backend starting..."

# Load environment variables from .env file if it exists
if [ -f "/app/.env" ]; then
    echo "Loading environment variables from /app/.env"
    set -a
    source /app/.env
    set +a
    echo "Environment variables loaded successfully!"
else
    echo "No .env file found at /app/.env, using system environment variables"
fi

# Verify critical variables are set
required_vars=(
    "JDBC_URI"
    "DB_USER" 
    "DB_PASSWORD"
    "SECURITY_JWT_SECRET"
)

missing_vars=()
for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "Error: The following critical environment variables are not set:"
    printf '%s\n' "${missing_vars[@]}"
    echo "Please ensure these variables are set in your .env file or system environment"
    exit 1
fi

echo "All critical environment variables are present"
echo "Starting CareConnect Backend with Java..."

# Start the application
exec java -jar app.jar
