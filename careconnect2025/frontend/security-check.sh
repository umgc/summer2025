#!/bin/bash

# 🔐 Security Check Script for CareConnect
# This script checks for exposed secrets and security issues

echo "🔍 Running security check for CareConnect..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ISSUES_FOUND=0

echo ""
echo "📋 Checking for exposed API keys..."

# Check for potential API keys in files (excluding safe directories)
if grep -r --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=build --exclude-dir=test --exclude="*.md" -E "sk-[a-zA-Z0-9_-]{20,}" . 2>/dev/null | grep -v "your_.*_key_here" | grep -v "test_key" | grep -v "SECURITY.md"; then
    echo -e "${RED}❌ Found potential exposed API keys!${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ No exposed API keys found${NC}"
fi

echo ""
echo "📋 Checking .env file security..."

# Check if .env contains real secrets
if [ -f ".env" ]; then
    if grep -E "sk-[a-zA-Z0-9_-]{20,}" .env | grep -v "your_.*_key_here"; then
        echo -e "${RED}❌ .env file contains real API keys!${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    else
        echo -e "${GREEN}✅ .env file is safe${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ No .env file found${NC}"
fi

echo ""
echo "📋 Checking .gitignore configuration..."

# Check if sensitive files are properly ignored
if [ -f ".gitignore" ]; then
    if grep -q ".env.local" .gitignore && grep -q "*.secret" .gitignore; then
        echo -e "${GREEN}✅ .gitignore properly configured${NC}"
    else
        echo -e "${RED}❌ .gitignore missing security entries${NC}"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
else
    echo -e "${RED}❌ No .gitignore file found!${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

echo ""
echo "📋 Checking for .env.local setup..."

if [ -f ".env.local" ]; then
    if grep -q "your_.*_key_here" .env; then
        echo -e "${YELLOW}⚠️ .env.local needs configuration${NC}"
    else
        echo -e "${GREEN}✅ .env.local is configured${NC}"
    fi
else
    echo -e "${YELLOW}⚠️ .env.local not found - create from template${NC}"
fi

echo ""
echo "📋 Checking git status for untracked sensitive files..."

# Check if any sensitive files are untracked
if git status --porcelain 2>/dev/null | grep -E "\.(env|secret|key|pem)$"; then
    echo -e "${RED}❌ Sensitive files are not properly ignored!${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo -e "${GREEN}✅ No sensitive files in git status${NC}"
fi

echo ""
echo "========================"

if [ $ISSUES_FOUND -eq 0 ]; then
    echo -e "${GREEN}🎉 Security check passed! No issues found.${NC}"
    exit 0
else
    echo -e "${RED}🚨 Security check failed! Found $ISSUES_FOUND issue(s).${NC}"
    echo ""
    echo "📚 Please refer to SECURITY.md for remediation steps."
    echo "🔗 Quick actions:"
    echo "   1. Revoke any exposed API keys immediately"
    echo "   2. Move secrets to .env.local"
    echo "   3. Update .gitignore if needed"
    echo "   4. Run this script again to verify fixes"
    exit 1
fi
