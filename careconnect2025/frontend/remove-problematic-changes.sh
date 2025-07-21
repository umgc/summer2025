#!/bin/bash

# Script to remove problematic incoming changes and keep local changes
# This will create a clean version by reverting specific commits

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_status "🔧 Removing problematic incoming changes..."

# Create a new clean branch
print_status "Creating clean branch: care-connect-fixed-ag-be"
git checkout -b care-connect-fixed-ag-be

# Reset to a stable point before the problematic commits
print_status "Resetting to stable commit before issues..."
git reset --hard c7991d3  # This is the merge commit before the problematic changes

print_success "✅ Clean branch created and reset to stable state"

# Now we'll manually add back only the good changes from your work
print_status "📋 Ready to manually restore good changes while excluding problematic ones"

echo ""
print_status "Current branch status:"
git log --oneline -5

echo ""
print_warning "Next steps:"
echo "1. Review and manually add back any good changes you want to keep"
echo "2. Exclude any changes from these problematic commits:"
echo "   - 600e079 (merge with issues)"
echo "   - 042450d (password reset issues)"  
echo "   - d5c7759 (import issues)"
echo "   - 864f4f7 (import issues)"
echo "   - fc08eb9 (S3 creds issues)"
echo ""
echo "3. Test the application to ensure it works properly"
echo "4. Push the clean branch when ready"

print_success "🎉 Clean branch setup complete!"
