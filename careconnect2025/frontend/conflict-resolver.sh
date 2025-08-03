#!/bin/bash

# Conflict Resolution Script for CareConnect
# Strategy: Non-core directory conflicts -> take incoming (theirs)
#          Core directory conflicts -> handle file by file

set -e

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

# Check if we're in a conflict state
check_conflicts() {
    if git ls-files -u | grep -q .; then
        print_warning "Git conflicts detected!"
        return 0
    else
        print_status "No current git conflicts detected"
        return 1
    fi
}

# Resolve conflicts based on directory strategy
resolve_conflicts() {
    local conflicted_files=$(git ls-files -u | cut -f2 | sort -u)
    
    if [ -z "$conflicted_files" ]; then
        print_status "No conflicted files to resolve"
        return 0
    fi
    
    print_status "🔧 Resolving conflicts using directory-based strategy..."
    
    for file in $conflicted_files; do
        print_status "Processing conflict in: $file"
        
        # Check if file is in core directory
        if [[ "$file" =~ ^careconnect2025/backend/core/ ]]; then
            print_warning "⚠️  CORE DIRECTORY FILE: $file"
            print_warning "This requires manual review. Options:"
            echo "  1. Keep ours (current branch): git checkout --ours '$file'"
            echo "  2. Keep theirs (incoming): git checkout --theirs '$file'"
            echo "  3. Manual merge required"
            
            # Ask user what to do
            while true; do
                read -p "Choose action for $file (1=ours, 2=theirs, 3=manual, s=skip): " choice
                case $choice in
                    1)
                        git checkout --ours "$file"
                        git add "$file"
                        print_success "✅ Resolved $file using OURS (current branch)"
                        break
                        ;;
                    2)
                        git checkout --theirs "$file"
                        git add "$file"
                        print_success "✅ Resolved $file using THEIRS (incoming)"
                        break
                        ;;
                    3)
                        print_warning "Please manually edit $file to resolve conflicts, then run 'git add $file'"
                        read -p "Press Enter when manual resolution is complete..."
                        if git diff --quiet --cached "$file" 2>/dev/null; then
                            print_error "File $file is not staged. Please resolve and stage it."
                        else
                            print_success "✅ Manual resolution completed for $file"
                            break
                        fi
                        ;;
                    s)
                        print_warning "Skipping $file - you'll need to resolve it later"
                        break
                        ;;
                    *)
                        echo "Please answer 1, 2, 3, or s"
                        ;;
                esac
            done
        else
            # Non-core directory - take incoming (theirs)
            print_success "📁 NON-CORE DIRECTORY: $file - Taking incoming changes (theirs)"
            git checkout --theirs "$file"
            git add "$file"
            print_success "✅ Resolved $file using THEIRS (incoming)"
        fi
    done
}

# Main execution
print_status "🚀 CareConnect Conflict Resolution Script"
echo "=========================================="
print_status "Strategy: Core directory conflicts → manual review"
print_status "         Non-core directory conflicts → take incoming (theirs)"
echo ""

# Change to repo root if not there
if [ ! -d ".git" ]; then
    if [ -d "../.git" ]; then
        cd ..
        print_status "Changed to repository root: $(pwd)"
    else
        print_error "Not in a git repository!"
        exit 1
    fi
fi

# Check current git status
print_status "📋 Current git status:"
git status --porcelain

# Check and resolve conflicts
if check_conflicts; then
    resolve_conflicts
    
    print_status "📊 Final status after conflict resolution:"
    git status --porcelain
    
    # Check if all conflicts are resolved
    if ! git ls-files -u | grep -q .; then
        print_success "🎉 All conflicts resolved!"
        echo ""
        print_status "Next steps:"
        echo "  1. Review changes: git diff --cached"
        echo "  2. Continue rebase: git rebase --continue"
        echo "  3. Or commit changes: git commit"
    else
        print_warning "⚠️  Some conflicts still need resolution"
        git ls-files -u | cut -f2 | sort -u | while read file; do
            print_warning "  - $file"
        done
    fi
else
    print_status "No conflicts to resolve. Checking if rebase is in progress..."
    
    if [ -d ".git/rebase-merge" ] || [ -d ".git/rebase-apply" ]; then
        print_status "Rebase in progress. You can continue with: git rebase --continue"
    else
        print_status "No active rebase. Repository is clean."
    fi
fi

print_success "✅ Conflict resolution script completed!"
