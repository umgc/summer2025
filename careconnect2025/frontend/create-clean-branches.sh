#!/bin/bash

# Improved Branch Creation Script for CareConnect
# Creates clean, specialized branches using git subtree filtering

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

print_status "🚀 CareConnect Specialized Branch Creation Script"
echo "=================================================="
echo ""

# Get current branch and repository root
current_branch=$(git branch --show-current)
repo_root=$(git rev-parse --show-toplevel)

print_status "Current branch: $current_branch"
print_status "Repository root: $repo_root"

# Branch names
backend_branch="backend-core-only"
frontend_branch="frontend-only"

print_status "📋 Plan Summary:"
echo "Current branch: $current_branch (will remain unchanged)"
echo "Backend branch: $backend_branch (will contain only careconnect2025/backend/core/)"
echo "Frontend branch: $frontend_branch (will contain only careconnect2025/frontend/)"
echo ""

if ! ask_confirmation "Proceed with specialized branch creation?"; then
    print_warning "Branch creation cancelled"
    exit 0
fi

print_status "🔄 Starting specialized branch creation..."
echo ""

# Save current position
original_dir=$(pwd)
cd "$repo_root"

# Delete branches if they already exist (for cleanup)
for branch in "$backend_branch" "$frontend_branch"; do
    if git branch | grep -q "^  $branch$" || git branch | grep -q "^\* $branch$"; then
        print_warning "Branch $branch already exists"
        if ask_confirmation "Delete existing $branch branch?"; then
            git branch -D "$branch" 2>/dev/null || true
            print_success "Deleted existing $branch branch"
        else
            print_error "Cannot proceed with existing branches. Please handle them manually."
            exit 1
        fi
    fi
done

# Create backend-core-only branch with subtree filtering
print_status "🏗️  Creating backend-core-only branch with git subtree..."

# Create a new orphan branch for backend
git checkout --orphan "$backend_branch"

# Clear the index
git reset --hard

# Add only the backend/core directory from the original branch
git checkout "$current_branch" -- careconnect2025/backend/core/

# Add essential root files
for file in README.md .gitignore; do
    if git cat-file -e "$current_branch:$file" 2>/dev/null; then
        git checkout "$current_branch" -- "$file"
        print_status "Added root file: $file"
    fi
done

# Add the structure file if it exists
if git cat-file -e "$current_branch:careconnect2025/sctructure.yaml" 2>/dev/null; then
    git checkout "$current_branch" -- careconnect2025/sctructure.yaml
    print_status "Added structure file: careconnect2025/sctructure.yaml"
fi

# Commit the backend-only branch
git add .
git commit -m "feat: create backend-core-only specialized branch

This branch contains only:
- careconnect2025/backend/core/ directory
- Essential root configuration files

Purpose:
- Dedicated backend development
- Clean PRs for backend changes
- Optimized for Java/Spring Boot development

Derived from: $current_branch
Created on: $(date)"

print_success "✅ Backend-core-only branch created successfully"

# Create frontend-only branch with subtree filtering
print_status "🎨 Creating frontend-only branch with git subtree..."

# Create a new orphan branch for frontend
git checkout --orphan "$frontend_branch"

# Clear the index
git reset --hard

# Add only the frontend directory from the original branch
git checkout "$current_branch" -- careconnect2025/frontend/

# Add essential root files
for file in README.md .gitignore; do
    if git cat-file -e "$current_branch:$file" 2>/dev/null; then
        git checkout "$current_branch" -- "$file"
        print_status "Added root file: $file"
    fi
done

# Add the structure file if it exists
if git cat-file -e "$current_branch:careconnect2025/sctructure.yaml" 2>/dev/null; then
    git checkout "$current_branch" -- careconnect2025/sctructure.yaml
    print_status "Added structure file: careconnect2025/sctructure.yaml"
fi

# Commit the frontend-only branch
git add .
git commit -m "feat: create frontend-only specialized branch

This branch contains only:
- careconnect2025/frontend/ directory
- Essential root configuration files

Purpose:
- Dedicated frontend development
- Clean PRs for frontend changes
- Optimized for Flutter/Dart development

Derived from: $current_branch
Created on: $(date)"

print_success "✅ Frontend-only branch created successfully"

# Switch back to original branch
git checkout "$current_branch"
print_status "↩️  Switched back to $current_branch"

# Return to original directory
cd "$original_dir"

echo ""
print_success "🎉 Specialized branch creation completed successfully!"
echo ""

# Verify the branches
print_status "🔍 Branch verification:"
echo "Available branches:"
git branch -l | grep -E "(backend-core-only|frontend-only|$current_branch)"

echo ""
print_status "📊 Directory contents verification:"

# Check backend branch contents
print_status "Backend branch contents:"
git ls-tree --name-only -r "$backend_branch" | head -10
echo "  ... (showing first 10 files)"

echo ""
# Check frontend branch contents  
print_status "Frontend branch contents:"
git ls-tree --name-only -r "$frontend_branch" | head -10
echo "  ... (showing first 10 files)"

echo ""
print_status "📋 Next Steps:"
echo "==============="
echo ""
print_status "🔀 Switch between branches:"
echo "  Backend work:  git checkout $backend_branch"
echo "  Frontend work: git checkout $frontend_branch"
echo "  Original:      git checkout $current_branch"
echo ""

print_status "🚀 Push to remote for PR creation:"
echo "  git push origin $backend_branch"
echo "  git push origin $frontend_branch"
echo ""

print_status "🔄 Create Pull Requests:"
echo "  1. Backend PR: $backend_branch → $current_branch"
echo "  2. Frontend PR: $frontend_branch → $current_branch"
echo ""

print_status "💡 Development Workflow:"
echo "  1. Switch to specialized branch"
echo "  2. Make your changes"
echo "  3. Commit and push changes"
echo "  4. Create PR back to $current_branch"
echo "  5. Merge PR to integrate changes"
echo ""

print_warning "⚠️  Important Notes:"
echo "• These are orphan branches with clean history"
echo "• Changes can be merged back to $current_branch via PRs"
echo "• Each branch is optimized for its development focus"
echo "• Original branch ($current_branch) remains unchanged"
echo "• Use git merge or PR process to integrate changes"

echo ""
print_success "✅ Ready for specialized development workflows!"
