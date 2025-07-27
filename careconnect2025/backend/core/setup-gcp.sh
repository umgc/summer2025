#!/bin/bash

# =============================================================================
# CareConnect GCP Setup Script
# =============================================================================

set -e

PROJECT_ID="careconnectcapstone"
REGION="us-east1"

echo "🚀 Setting up CareConnect Backend for GCP deployment..."

# 1. Enable required APIs
echo "📡 Enabling required GCP APIs..."
gcloud services enable run.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
gcloud services enable secretmanager.googleapis.com

# 2. Set up authentication
echo "🔐 Setting up authentication..."
gcloud auth activate-service-account deployer@careconnectcapstone.iam.gserviceaccount.com --key-file=gcp-service-account-key.json
gcloud config set project $PROJECT_ID
gcloud auth configure-docker us-east1-docker.pkg.dev

# 3. Create Artifact Registry repository
echo "📦 Creating Artifact Registry repository..."
gcloud artifacts repositories create careconnect \
    --repository-format=docker \
    --location=$REGION \
    --description="CareConnect Backend Container Images" \
    --quiet || echo "Repository may already exist"

# 4. Create initial secrets
echo "🔑 Creating initial secrets..."
echo "CareConnect2025SecureJwtKey256BitSecretForProductionUseOnly!" | gcloud secrets create jwt-secret --data-file=- 2>/dev/null || echo "JWT secret already exists"

echo "✅ Setup complete!"
echo ""
echo "⚠️  NEXT STEPS:"
echo "1. Update secrets with real values:"
echo "   gcloud secrets versions add smtp-username --data-file=-"
echo "   gcloud secrets versions add smtp-password --data-file=-"
echo ""
echo "2. Deploy the application:"
echo "   ./deploy-gcp.sh"
echo ""
echo "3. Your backend will be available at:"
echo "   https://careconnect-backend-663999888931.us-east1.run.app"
