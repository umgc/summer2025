#!/bin/bash

# Interactive Merge Conflict Resolution Script
# This script helps resolve merge conflicts from care-connect-develop into backend branch

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}🔀 CareConnect Backend Merge Conflict Resolution${NC}"
    echo -e "${BLUE}===============================================${NC}"
    echo
}

print_status() {
    echo -e "${CYAN}[INFO]${NC} $1"
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

show_conflict_summary() {
    print_header
    
    print_status "📊 Merge Conflict Summary:"
    echo
    
    # Count conflicts
    local backend_conflicts=$(git status --porcelain | grep "^UU.*backend" | wc -l)
    local frontend_conflicts=$(git status --porcelain | grep "^DU.*frontend" | wc -l)
    
    echo -e "${PURPLE}Backend Content Conflicts:${NC} ${backend_conflicts} files"
    if [ $backend_conflicts -gt 0 ]; then
        echo -e "   ${CYAN}These need manual resolution${NC}"
    fi
    
    echo -e "${PURPLE}Frontend Delete Conflicts:${NC} ${frontend_conflicts} files"
    if [ $frontend_conflicts -gt 0 ]; then
        echo -e "   ${CYAN}These should be removed (we want backend-only)${NC}"
    fi
    
    echo
}

resolve_backend_conflicts() {
    print_status "🔧 Resolving Backend Content Conflicts..."
    
    local backend_files=(
        "careconnect2025/backend/core/README.md"
        "careconnect2025/backend/core/pom.xml"
        "careconnect2025/backend/core/src/main/java/com/careconnect/controller/FileController.java"
        "careconnect2025/backend/core/src/main/java/com/careconnect/repository/UserRepository.java"
        "careconnect2025/backend/core/src/main/resources/application.properties"
    )
    
    for file in "${backend_files[@]}"; do
        if [ -f "$file" ]; then
            print_status "📝 Conflict in: $file"
            
            # Show conflict markers
            echo -e "${YELLOW}Conflict preview:${NC}"
            grep -n -A2 -B2 "<<<<<<< HEAD\\|=======" "$file" | head -10
            echo "..."
            
            if ask_confirmation "Open this file in your editor to resolve conflicts?"; then
                echo "Opening $file..."
                echo "Please resolve conflicts and save the file."
                echo "Look for <<<<<<< HEAD, =======, and >>>>>>> markers"
                read -p "Press Enter when you've resolved conflicts in this file..."
                
                # Mark as resolved
                git add "$file"
                print_success "✅ Marked $file as resolved"
            else
                print_warning "⚠️  Skipping $file - you'll need to resolve it manually"
            fi
            echo
        fi
    done
}

resolve_frontend_deletions() {
    print_status "🗑️  Resolving Frontend File Deletions..."
    
    print_status "Since this is a backend-only branch, we should remove frontend files."
    
    if ask_confirmation "Remove all frontend files that were modified in care-connect-develop?"; then
        # Get list of frontend deletion conflicts
        local frontend_files=$(git status --porcelain | grep "^DU.*frontend" | cut -c4-)
        
        for file in $frontend_files; do
            if [ -f "$file" ]; then
                print_status "🗑️  Removing: $file"
                rm "$file"
                git rm "$file" 2>/dev/null || true
            fi
        done
        
        print_success "✅ Removed frontend files"
    else
        print_warning "⚠️  Frontend files kept - you may need to resolve manually"
    fi
}

show_merge_status() {
    print_status "📋 Current Merge Status:"
    
    local unmerged=$(git status --porcelain | grep "^U" | wc -l)
    local deleted=$(git status --porcelain | grep "^D" | wc -l)
    
    if [ $unmerged -eq 0 ]; then
        print_success "✅ All conflicts resolved!"
        echo
        print_status "📦 Ready to commit merge..."
        
        if ask_confirmation "Commit the merge now?"; then
            git commit -m "Merge remote care-connect-develop into backend-only branch

Resolved conflicts:
- Backend content conflicts: manually resolved
- Frontend deletion conflicts: removed frontend files (backend-only branch)
- Maintained backend-core-only structure

This merge brings in latest changes from care-connect-develop while
preserving the backend-only nature of this branch."
            
            print_success "🎉 Merge completed successfully!"
            
            # Show summary
            echo
            print_status "📊 Merge Summary:"
            git log -1 --stat
        fi
    else
        print_warning "⚠️  Still have ${unmerged} unresolved conflicts"
        print_status "Run this script again after resolving more conflicts"
    fi
}

# Main execution
show_conflict_summary

if ask_confirmation "Start resolving backend content conflicts?"; then
    resolve_backend_conflicts
fi

echo

if ask_confirmation "Remove frontend files (recommended for backend-only branch)?"; then
    resolve_frontend_deletions
fi

echo
show_merge_status

print_status "💡 Next steps if conflicts remain:"
echo "1. Manually edit conflicted files to resolve <<<<<<< HEAD markers"
echo "2. Use 'git add <file>' to mark resolved files"
echo "3. Run this script again to check status"
echo "4. When all conflicts are resolved, commit the merge"
echo
print_status "🔧 Useful commands:"
echo "git status                    # See remaining conflicts"
echo "git diff                      # See current changes"
echo "git add <file>               # Mark file as resolved"
echo "git commit                   # Complete the merge"
echo
