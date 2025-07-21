#!/bin/bash

# Branch Creation Script for CareConnect
# Creates separate branches for backend/core and frontend directories
# while maintaining git history and mergeability

set -e  # Exit on any error

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to ask for user confirmation
ask_confirmation() {
    local prompt="$1"
    local response
    while true; do
        read -p "$(echo -e "${YELLOW}${prompt}${NC} (y/n): ")" response
        case $response in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

print_status "🚀 CareConnect Branch Creation Script"
echo "======================================="
echo ""

# Get current branch and repository root
current_branch=$(git branch --show-current)
repo_root=$(git rev-parse --show-toplevel)

print_status "Current branch: $current_branch"
print_status "Repository root: $repo_root"

# Check if we're in the right location - account for careconnect2025 subdirectory
careconnect_dir="$repo_root/careconnect2025"
if [[ ! -d "$careconnect_dir/backend/core" ]] || [[ ! -d "$careconnect_dir/frontend" ]]; then
    print_error "Required directories not found. Expected structure:"
    print_error "  - $careconnect_dir/backend/core"
    print_error "  - $careconnect_dir/frontend"
    exit 1
fi

print_status "✅ Directory structure verified"
echo ""

# Branch names
backend_branch="backend-core-only"
frontend_branch="frontend-only"

print_status "📋 Plan Summary:"
echo "Current branch: $current_branch"
echo "Backend branch to create: $backend_branch (contains only backend/core/)"
echo "Frontend branch to create: $frontend_branch (contains only frontend/)"
echo ""

if ! ask_confirmation "Proceed with branch creation?"; then
    print_warning "Branch creation cancelled"
    exit 0
fi

print_status "🔄 Starting branch creation process..."
echo ""

# Save current position
original_dir=$(pwd)
cd "$repo_root"

# Create backend-core-only branch
print_status "🏗️  Creating backend-core-only branch..."

# Create the branch from current branch to maintain history
git checkout -b "$backend_branch" "$current_branch"
print_success "Created branch: $backend_branch"

# Remove everything except backend/core directory and essential files
print_status "🧹 Cleaning up backend branch (keeping only backend/core)..."

# Create a temporary commit to track what we want to keep
git add .
temp_commit=$(git rev-parse HEAD)

# Reset to parent and start fresh
git reset --soft HEAD~1

# Add only the backend/core directory and essential root files
if [ -d "careconnect2025/backend/core" ]; then
    git add careconnect2025/backend/core/
    print_success "Added careconnect2025/backend/core/ directory"
fi

# Add essential root files if they exist
for file in README.md .gitignore careconnect2025/sctructure.yaml; do
    if [ -f "$file" ]; then
        git add "$file"
        print_status "Added root file: $file"
    fi
done

# Commit the backend-only changes
git commit -m "refactor: create backend-core-only branch

- Contains only backend/core directory and essential root files
- Maintains git history for mergeability with parent branch
- Ready for backend-specific development and PRs

Derived from: $current_branch"

print_success "✅ Backend-core-only branch created and committed"

# Switch back to original branch
git checkout "$current_branch"
print_status "↩️  Switched back to $current_branch"

echo ""

# Create frontend-only branch
print_status "🎨 Creating frontend-only branch..."

# Create the branch from current branch to maintain history
git checkout -b "$frontend_branch" "$current_branch"
print_success "Created branch: $frontend_branch"

# Remove everything except frontend directory and essential files
print_status "🧹 Cleaning up frontend branch (keeping only frontend)..."

# Reset to prepare for selective adding
git reset --soft HEAD~1

# Add only the frontend directory and essential root files
if [ -d "careconnect2025/frontend" ]; then
    git add careconnect2025/frontend/
    print_success "Added careconnect2025/frontend/ directory"
fi

# Add essential root files if they exist
for file in README.md .gitignore careconnect2025/sctructure.yaml; do
    if [ -f "$file" ]; then
        git add "$file"
        print_status "Added root file: $file"
    fi
done

# Commit the frontend-only changes
git commit -m "refactor: create frontend-only branch

- Contains only frontend directory and essential root files
- Maintains git history for mergeability with parent branch
- Ready for frontend-specific development and PRs

Derived from: $current_branch"

print_success "✅ Frontend-only branch created and committed"

# Switch back to original branch
git checkout "$current_branch"
print_status "↩️  Switched back to $current_branch"

# Return to original directory
cd "$original_dir"

echo ""
print_success "🎉 Branch creation completed successfully!"
echo ""

print_status "📊 Summary:"
echo "==============="
print_status "Original branch: $current_branch (unchanged)"
print_status "Backend branch: $backend_branch (contains backend/core only)"
print_status "Frontend branch: $frontend_branch (contains frontend only)"
echo ""

print_status "🔍 Verify branches:"
echo "git branch -a"
echo ""

print_status "📋 Next steps:"
echo "1. Switch to backend branch: git checkout $backend_branch"
echo "2. Switch to frontend branch: git checkout $frontend_branch"
echo "3. Both branches can be pushed and used for separate PRs"
echo "4. Both branches maintain history and can merge back to $current_branch"
echo ""

print_status "🚀 Push branches to remote:"
echo "git push origin $backend_branch"
echo "git push origin $frontend_branch"
echo ""

print_warning "⚠️  Important Notes:"
echo "- Both branches maintain full git history"
echo "- Changes can be merged back to $current_branch"
echo "- Each branch is optimized for its specific development focus"
echo "- Use appropriate branch for backend vs frontend PRs"

echo ""
print_success "✅ Ready for specialized development!"
