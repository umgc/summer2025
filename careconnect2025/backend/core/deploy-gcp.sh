#!/bin/bash

# =============================================================================
# GCP Deployment Script for CareConnect Backend
# =============================================================================

set -e

# Configuration
PROJECT_ID="careconnectcapstone"
REGION="us-east1"
SERVICE_NAME="careconnect-backend"
SERVICE_ACCOUNT="deployer@careconnectcapstone.iam.gserviceaccount.com"
REPOSITORY_NAME="careconnect"
IMAGE_NAME="backend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}==============================================================================${NC}"
echo -e "${BLUE}CareConnect Backend - GCP Deployment Script${NC}"
echo -e "${BLUE}==============================================================================${NC}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
print_status "Checking required tools..."

if ! command -v gcloud &> /dev/null; then
    print_error "gcloud CLI is not installed. Please install it first."
    exit 1
fi

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install it first."
    exit 1
fi

# Set the project
print_status "Setting GCP project to $PROJECT_ID..."
gcloud config set project $PROJECT_ID

# Authenticate Docker with Artifact Registry
print_status "Configuring Docker authentication for Artifact Registry..."
gcloud auth configure-docker us-east1-docker.pkg.dev

# Step 1: Create Artifact Registry repository (if it doesn't exist)
print_status "Creating Artifact Registry repository..."
gcloud artifacts repositories create $REPOSITORY_NAME \
    --repository-format=docker \
    --location=$REGION \
    --description="CareConnect Backend Container Images" \
    --quiet || print_warning "Repository may already exist"

# Step 2: Create Secret Manager secrets
print_status "Creating secrets in Secret Manager..."

# Check if secrets exist, create if they don't
secrets=(
    "jwt-secret:CareConnect2025SecureJwtKey256BitSecretForProductionUseOnly!"
    "smtp-username:your-email@gmail.com"
    "smtp-password:your-app-password"
    "google-client-id:your-google-client-id.googleusercontent.com"
    "google-client-secret:your-google-client-secret"
    "stripe-secret-key:sk_test_your_stripe_secret_key"
)

for secret_pair in "${secrets[@]}"; do
    IFS=':' read -r secret_name secret_value <<< "$secret_pair"
    
    if gcloud secrets describe $secret_name --quiet &> /dev/null; then
        print_warning "Secret $secret_name already exists, skipping creation"
    else
        print_status "Creating secret: $secret_name"
        echo -n "$secret_value" | gcloud secrets create $secret_name --data-file=-
    fi
done

# Step 3: Build and push the Docker image
print_status "Building Docker image..."
IMAGE_TAG="us-east1-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:$(date +%Y%m%d-%H%M%S)"
IMAGE_LATEST="us-east1-docker.pkg.dev/$PROJECT_ID/$REPOSITORY_NAME/$IMAGE_NAME:latest"

docker build -t $IMAGE_TAG -t $IMAGE_LATEST .

print_status "Pushing Docker image to Artifact Registry..."
docker push $IMAGE_TAG
docker push $IMAGE_LATEST

# Step 4: Deploy to Cloud Run
print_status "Deploying to Cloud Run..."
gcloud run deploy $SERVICE_NAME \
    --image=$IMAGE_LATEST \
    --region=$REGION \
    --platform=managed \
    --service-account=$SERVICE_ACCOUNT \
    --allow-unauthenticated \
    --port=8080 \
    --memory=2Gi \
    --cpu=1 \
    --min-instances=1 \
    --max-instances=10 \
    --concurrency=100 \
    --timeout=300 \
    --set-env-vars="SPRING_PROFILES_ACTIVE=gcp,GCP_PROJECT_ID=$PROJECT_ID,FRONTEND_BASE_URL=https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com,BACKEND_BASE_URL=https://careconnect-backend-663999888931.us-east1.run.app,CORS_ALLOWED_ORIGINS=https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com" \
    --set-secrets="JWT_SECRET=jwt-secret:latest,SMTP_USERNAME=smtp-username:latest,SMTP_PASSWORD=smtp-password:latest,GOOGLE_CLIENT_ID=google-client-id:latest,GOOGLE_CLIENT_SECRET=google-client-secret:latest,STRIPE_SECRET_KEY=stripe-secret-key:latest"

# Step 5: Get the service URL
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)")

print_status "Deployment completed successfully!"
echo -e "${GREEN}==============================================================================${NC}"
echo -e "${GREEN}Service URL: $SERVICE_URL${NC}"
echo -e "${GREEN}Health Check: $SERVICE_URL/actuator/health${NC}"
echo -e "${GREEN}API Documentation: $SERVICE_URL/swagger-ui.html${NC}"
echo -e "${GREEN}==============================================================================${NC}"

# Step 6: Test the deployment
print_status "Testing the deployment..."
sleep 10  # Wait for the service to start

if curl -f "$SERVICE_URL/actuator/health" > /dev/null 2>&1; then
    print_status "Health check passed! Service is running correctly."
else
    print_warning "Health check failed. Service may still be starting up."
    print_status "Check logs with: gcloud run services logs read $SERVICE_NAME --region=$REGION"
fi

print_status "You can now update your frontend to use the backend URL: $SERVICE_URL"
echo -e "${BLUE}==============================================================================${NC}"
