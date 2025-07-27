@echo off
REM =============================================================================
REM GCP Deployment Script for CareConnect Backend (Windows)
REM =============================================================================

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_ID=careconnectcapstone
set REGION=us-east1
set SERVICE_NAME=careconnect-backend
set SERVICE_ACCOUNT=deployer@careconnectcapstone.iam.gserviceaccount.com
set REPOSITORY_NAME=careconnect
set IMAGE_NAME=backend

echo ==============================================================================
echo CareConnect Backend - GCP Deployment Script (Windows)
echo ==============================================================================

REM Check if required tools are installed
echo [INFO] Checking required tools...

REM Check for gcloud in default locations
set GCLOUD_PATH=%LOCALAPPDATA%\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd
if not exist "%GCLOUD_PATH%" (
    where gcloud >nul 2>nul
    if !errorlevel! neq 0 (
        echo [ERROR] gcloud CLI is not installed. Please install it first.
        exit /b 1
    )
    set GCLOUD_PATH=gcloud
)

REM Check for Docker
docker --version >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker is not installed. Please install it first.
    exit /b 1
)

REM Set the project
echo [INFO] Setting GCP project to %PROJECT_ID%...
"%GCLOUD_PATH%" config set project %PROJECT_ID%

REM Authenticate Docker with Artifact Registry
echo [INFO] Configuring Docker authentication for Artifact Registry...
"%GCLOUD_PATH%" auth configure-docker us-east1-docker.pkg.dev

REM Step 1: Create Artifact Registry repository
echo [INFO] Creating Artifact Registry repository...
"%GCLOUD_PATH%" artifacts repositories create %REPOSITORY_NAME% --repository-format=docker --location=%REGION% --description="CareConnect Backend Container Images" --quiet 2>nul || echo [WARNING] Repository may already exist

REM Step 2: Create Secret Manager secrets
echo [INFO] Creating secrets in Secret Manager...

REM JWT Secret
echo [INFO] Creating JWT secret...
echo CareConnect2025SecureJwtKey256BitSecretForProductionUseOnly! | "%GCLOUD_PATH%" secrets create jwt-secret --data-file=- 2>nul || echo [WARNING] JWT secret may already exist

REM Note: You'll need to manually update these with real values
echo [WARNING] Please update the following secrets with real values:
echo "%GCLOUD_PATH%" secrets versions add smtp-username --data-file=-
echo "%GCLOUD_PATH%" secrets versions add smtp-password --data-file=-
echo "%GCLOUD_PATH%" secrets versions add google-client-id --data-file=-
echo "%GCLOUD_PATH%" secrets versions add google-client-secret --data-file=-
echo "%GCLOUD_PATH%" secrets versions add stripe-secret-key --data-file=-

REM Step 3: Build and push the Docker image
echo [INFO] Building Docker image...
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set IMAGE_TAG=us-east1-docker.pkg.dev/%PROJECT_ID%/%REPOSITORY_NAME%/%IMAGE_NAME%:%datetime:~0,8%-%datetime:~8,6%
set IMAGE_LATEST=us-east1-docker.pkg.dev/%PROJECT_ID%/%REPOSITORY_NAME%/%IMAGE_NAME%:latest

docker build -t %IMAGE_TAG% -t %IMAGE_LATEST% .
if %errorlevel% neq 0 (
    echo [ERROR] Docker build failed
    exit /b 1
)

echo [INFO] Pushing Docker image to Artifact Registry...
docker push %IMAGE_TAG%
docker push %IMAGE_LATEST%

REM Step 4: Deploy to Cloud Run
echo [INFO] Deploying to Cloud Run...
"%GCLOUD_PATH%" run deploy %SERVICE_NAME% ^
    --image=%IMAGE_LATEST% ^
    --region=%REGION% ^
    --platform=managed ^
    --service-account=%SERVICE_ACCOUNT% ^
    --allow-unauthenticated ^
    --port=8080 ^
    --memory=2Gi ^
    --cpu=1 ^
    --min-instances=1 ^
    --max-instances=10 ^
    --concurrency=100 ^
    --timeout=300 ^
    --set-env-vars="SPRING_PROFILES_ACTIVE=gcp,GCP_PROJECT_ID=%PROJECT_ID%,FRONTEND_BASE_URL=https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com,BACKEND_BASE_URL=https://careconnect-backend-663999888931.us-east1.run.app,CORS_ALLOWED_ORIGINS=https://care-connect-develop.d26kqsucj1bwc1.amplifyapp.com" ^
    --set-secrets="JWT_SECRET=jwt-secret:latest,SMTP_USERNAME=smtp-username:latest,SMTP_PASSWORD=smtp-password:latest,GOOGLE_CLIENT_ID=google-client-id:latest,GOOGLE_CLIENT_SECRET=google-client-secret:latest,STRIPE_SECRET_KEY=stripe-secret-key:latest"

if %errorlevel% neq 0 (
    echo [ERROR] Cloud Run deployment failed
    exit /b 1
)

REM Step 5: Get the service URL
echo [INFO] Getting service URL...
for /f "delims=" %%i in ('"%GCLOUD_PATH%" run services describe %SERVICE_NAME% --region=%REGION% --format="value(status.url)"') do set SERVICE_URL=%%i

echo ==============================================================================
echo [SUCCESS] Deployment completed successfully!
echo Service URL: %SERVICE_URL%
echo Health Check: %SERVICE_URL%/actuator/health
echo API Documentation: %SERVICE_URL%/swagger-ui.html
echo ==============================================================================

REM Step 6: Test the deployment
echo [INFO] Testing the deployment...
timeout /t 10 /nobreak >nul
curl -f "%SERVICE_URL%/actuator/health" >nul 2>nul
if %errorlevel% equ 0 (
    echo [SUCCESS] Health check passed! Service is running correctly.
) else (
    echo [WARNING] Health check failed. Service may still be starting up.
    echo Check logs with: "%GCLOUD_PATH%" run services logs read %SERVICE_NAME% --region=%REGION%
)

echo [INFO] You can now update your frontend to use the backend URL: %SERVICE_URL%
echo ==============================================================================
pause
