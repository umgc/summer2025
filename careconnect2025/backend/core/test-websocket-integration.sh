#!/bin/bash

# WebSocket SMS/Call Integration Testing Script
# Usage: ./test-websocket-integration.sh [JWT_TOKEN]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://localhost:8080"
JWT_TOKEN="${1:-}"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to make API calls
make_api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    local description="$4"
    
    print_status "Testing: $description"
    
    if [ -z "$JWT_TOKEN" ]; then
        print_error "JWT token required. Usage: $0 [JWT_TOKEN]"
        exit 1
    fi
    
    local response
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" \
            -X "$method" \
            -H "Authorization: Bearer $JWT_TOKEN" \
            "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" \
            -X "$method" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $JWT_TOKEN" \
            -d "$data" \
            "$BASE_URL$endpoint")
    fi
    
    local http_code=$(echo "$response" | tail -n1)
    local body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" -eq 200 ]; then
        print_success "$description - HTTP $http_code"
        echo "Response: $body" | jq '.' 2>/dev/null || echo "$body"
    else
        print_error "$description - HTTP $http_code"
        echo "Response: $body"
    fi
    
    echo "----------------------------------------"
}

# Main testing function
main() {
    echo "================================================"
    echo "WebSocket SMS/Call Integration Testing"
    echo "================================================"
    
    if [ -z "$JWT_TOKEN" ]; then
        print_error "JWT token required!"
        echo "Usage: $0 [JWT_TOKEN]"
        echo ""
        echo "To get a JWT token, first authenticate:"
        echo "curl -X POST http://localhost:8080/api/auth/login \\"
        echo "  -H 'Content-Type: application/json' \\"
        echo "  -d '{\"email\":\"your-email@example.com\",\"password\":\"your-password\"}'"
        exit 1
    fi
    
    print_status "Using JWT Token: ${JWT_TOKEN:0:20}..."
    echo ""
    
    # Test 1: Send Call Invitation
    make_api_call "POST" "/api/websocket/call-invitation" '{
        "recipientId": "test-recipient-123",
        "senderId": "test-sender-456",
        "senderName": "Dr. Test Smith",
        "callId": "call-test-789",
        "isVideoCall": true,
        "callType": "emergency"
    }' "Send Call Invitation"
    
    # Test 2: Send SMS Notification
    make_api_call "POST" "/api/websocket/sms-notification" '{
        "recipientId": "test-recipient-123",
        "senderId": "test-sender-456",
        "senderName": "Nurse Test Jane",
        "message": "Your medication reminder: Take 2 tablets of Lisinopril",
        "messageType": "medication"
    }' "Send SMS Notification"
    
    # Test 3: Send Medication Reminder
    make_api_call "POST" "/api/websocket/medication-reminder" '{
        "patientId": "test-patient-123",
        "medicationName": "Lisinopril",
        "reminderTime": "10:30 AM",
        "dosage": "2 tablets"
    }' "Send Medication Reminder"
    
    # Test 4: Send Vital Signs Alert
    make_api_call "POST" "/api/websocket/vital-signs-alert" '{
        "patientId": "test-patient-123",
        "patientName": "John Test Doe",
        "alertType": "blood_pressure",
        "alertMessage": "Blood pressure reading is critically high: 180/110",
        "severity": "high",
        "recipientIds": ["caregiver-123", "caregiver-456"]
    }' "Send Vital Signs Alert"
    
    # Test 5: Send Emergency Alert
    make_api_call "POST" "/api/websocket/emergency-alert" '{
        "patientId": "test-patient-123",
        "patientName": "John Test Doe",
        "alertMessage": "Patient has triggered an emergency alert",
        "emergencyContactIds": ["family-123", "family-456", "caregiver-789"]
    }' "Send Emergency Alert"
    
    # Test 6: Send Appointment Reminder
    make_api_call "POST" "/api/websocket/appointment-reminder" '{
        "patientId": "test-patient-123",
        "appointmentDetails": "Cardiology consultation with Dr. Smith",
        "appointmentTime": "2024-01-20T14:00:00Z",
        "providerName": "Dr. Smith"
    }' "Send Appointment Reminder"
    
    # Test 7: Check Online Users (Admin only)
    make_api_call "GET" "/api/websocket/online-users" "" "Check Online Users"
    
    # Test 8: Check User Status
    make_api_call "GET" "/api/websocket/user-status/test-user-123" "" "Check User Online Status"
    
    # Test 9: Broadcast System Announcement (Admin only)
    make_api_call "POST" "/api/websocket/system-announcement" '{
        "title": "System Maintenance",
        "message": "The system will undergo maintenance from 2:00 AM to 4:00 AM EST",
        "type": "maintenance"
    }' "Broadcast System Announcement"
    
    echo ""
    print_success "WebSocket integration testing completed!"
    echo ""
    print_warning "Note: To fully test WebSocket functionality, you need to:"
    echo "1. Start the Spring Boot application"
    echo "2. Connect to WebSocket endpoints using a WebSocket client"
    echo "3. Test real-time message delivery"
    echo ""
    echo "WebSocket endpoints:"
    echo "- ws://localhost:8080/ws/calls?token=YOUR_JWT_TOKEN"
    echo "- ws://localhost:8080/ws/careconnect?token=YOUR_JWT_TOKEN"
    echo ""
    echo "Use wscat to test WebSocket connections:"
    echo "npm install -g wscat"
    echo "wscat -c \"ws://localhost:8080/ws/calls?token=$JWT_TOKEN\""
}

# Run the main function
main "$@"
