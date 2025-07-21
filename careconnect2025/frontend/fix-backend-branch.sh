#!/bin/bash

# Fix Backend Branch Creation Script
# This script creates the backend-core-only branch correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 CareConnect Backend Branch Fix${NC}"
echo -e "${BLUE}=================================${NC}"

# Ensure we're in the frontend directory (our current working git repo)
cd /Users/ashenafigebreeziabhere/Documents/VPProjects/summer2025/careconnect2025/frontend

# Verify we're on the correct branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}📍 Current branch: ${CURRENT_BRANCH}${NC}"

if [ "$CURRENT_BRANCH" != "care-connect-develop-ag2" ]; then
    echo -e "${RED}❌ Not on care-connect-develop-ag2 branch. Switching...${NC}"
    git checkout care-connect-develop-ag2
fi

echo -e "${BLUE}🌿 Creating backend-core-only branch...${NC}"
git checkout -b care-connect-backend-core-only

# Remove all frontend-specific files and directories
echo -e "${YELLOW}🗑️  Removing frontend files...${NC}"

# Remove Flutter/Dart specific files
rm -rf android/
rm -rf ios/   
rm -rf lib/
rm -rf test/
rm -rf web/
rm -rf linux/
rm -rf macos/
rm -rf windows/
rm -rf build/
rm -rf assets/
rm -rf coverage/

# Remove Flutter config files
rm -f pubspec.yaml
rm -f pubspec.lock
rm -f analysis_options.yaml
rm -f devtools_options.yaml

# Remove Flutter/Dart scripts and files
rm -f *.dart
rm -f *.sh
rm -f *.py
rm -f *.png
rm -f *.md

# Copy backend/core files from parent directory
echo -e "${BLUE}📦 Copying backend/core files...${NC}"

# Copy the entire backend/core directory structure to root
cp -r ../backend/core/* .

# Create a backend-specific README
echo -e "${GREEN}📝 Creating backend README...${NC}"
cat > README.md << EOF
# CareConnect Backend Core

This is the backend core service for the CareConnect application, containing the Spring Boot Java backend implementation.

## Directory Structure

This branch contains only the backend/core service files from the main CareConnect project.

## Getting Started

1. Ensure you have Java 17+ installed
2. Install Maven or use the included Maven wrapper
3. Configure your database settings
4. Run the application

## Original Repository

This branch was created from the main CareConnect repository to isolate the backend development.
Parent branch: care-connect-develop-ag2

## Development

This branch focuses exclusively on backend/core development and can be used for:
- Backend-specific pull requests  
- Independent backend testing
- Backend deployment pipelines
- Java/Spring Boot development workflow

EOF

# Stage all changes
echo -e "${BLUE}📦 Staging changes...${NC}"
git add .

# Commit the changes
echo -e "${GREEN}💾 Committing backend-only structure...${NC}"
git commit -m "Create backend-core-only branch

- Removed all frontend (Flutter) files and directories
- Added complete backend/core Java Spring Boot implementation
- Created backend-specific README
- Branch isolated for backend development workflow

Files removed:
- Flutter app directories (android/, ios/, lib/, etc.)
- Dart configuration files
- Frontend build artifacts and assets

Files added:
- Complete backend/core Java implementation
- Spring Boot configuration
- Backend-specific documentation"

echo -e "${GREEN}✅ Backend branch fixed successfully!${NC}"
echo -e "${YELLOW}📋 Summary:${NC}"
echo -e "   • Branch: care-connect-backend-core-only"
echo -e "   • Contains: Java Spring Boot backend/core files only"
echo -e "   • Ready for: Backend development and PRs"

# Show current directory contents
echo -e "${BLUE}📂 Current backend branch contents:${NC}"
ls -la

echo -e "${GREEN}🎉 Backend branch creation complete!${NC}"
