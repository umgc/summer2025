#!/bin/bash

# Fix Backend Branch - Remove Frontend Files Properly
# This script ensures the backend branch only contains backend/core files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}🔧 Fixing Backend Branch - Remove Frontend Files${NC}"
echo -e "${BLUE}=================================================${NC}"

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}📍 Current branch: ${CURRENT_BRANCH}${NC}"

if [[ "$CURRENT_BRANCH" != *"backend"* ]]; then
    echo -e "${RED}❌ This doesn't look like a backend branch. Exiting for safety.${NC}"
    exit 1
fi

echo -e "${BLUE}🗑️  Removing frontend files and directories...${NC}"

# Remove Flutter/frontend directories
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

# Remove Flutter configuration files
rm -f pubspec.yaml
rm -f pubspec.lock
rm -f analysis_options.yaml
rm -f devtools_options.yaml
rm -f .flutter-plugins-dependencies
rm -f .metadata

# Remove Flutter/Dart specific files
rm -f *.dart

# Remove frontend-specific scripts and files
rm -f flutter_integration_template.dart
rm -f welcome_page_temp.dart
rm -f speech_text.txt

# Keep only backend-related files and our current directory structure
echo -e "${GREEN}✅ Removed frontend files${NC}"

# Verify the structure is now backend-focused
echo -e "${BLUE}📂 Current directory contents:${NC}"
ls -la

# Commit the cleanup
echo -e "${BLUE}💾 Committing frontend file removal...${NC}"
git add -A
git commit -m "Clean backend branch: Remove all frontend files

- Removed Flutter/Dart directories (android/, ios/, lib/, test/, web/, etc.)
- Removed Flutter configuration files (pubspec.yaml, analysis_options.yaml, etc.)
- Removed Dart source files
- Kept only backend/core Java files and related configuration
- Branch now properly backend-only for clean merging

This prepares the branch for merging with care-connect-develop backend changes."

echo -e "${GREEN}🎉 Backend branch cleaned successfully!${NC}"
echo -e "${YELLOW}📋 Next step: Retry merging with care-connect-develop${NC}"
