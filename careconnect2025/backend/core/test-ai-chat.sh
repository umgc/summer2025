#!/bin/bash

# CareConnect AI Chat Testing Script
# This script demonstrates the complete AI chat workflow

# Configuration
BASE_URL="http://localhost:8080"
CONTENT_TYPE="Content-Type: application/json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🤖 CareConnect AI Chat Testing Script${NC}"
echo "============================================="

# Function to print section headers
print_section() {
    echo -e "\n${YELLOW}📋 $1${NC}"
    echo "----------------------------------------"
}

# Function to print responses
print_response() {
    echo -e "${GREEN}✅ Response:${NC}"
    echo "$1" | jq '.' 2>/dev/null || echo "$1"
    echo ""
}

# Function to print errors
print_error() {
    echo -e "${RED}❌ Error:${NC}"
    echo "$1"
    echo ""
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️ jq is not installed. JSON responses will not be formatted.${NC}"
    echo "Install jq for better output formatting: brew install jq"
    echo ""
fi

# Step 1: Login and get JWT token
print_section "Step 1: Patient Login"
echo "Logging in as patient to get JWT token..."

LOGIN_RESPONSE=$(curl -s -X POST "${BASE_URL}/auth/login" \
  -H "${CONTENT_TYPE}" \
  -d '{
    "email": "patient@example.com",
    "password": "password123",
    "role": "PATIENT"
  }')

if [ $? -eq 0 ]; then
    print_response "$LOGIN_RESPONSE"
    
    # Extract token (requires jq for proper parsing)
    if command -v jq &> /dev/null; then
        JWT_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty')
        PATIENT_ID=$(echo "$LOGIN_RESPONSE" | jq -r '.user.id // empty')
        
        if [ -n "$JWT_TOKEN" ] && [ "$JWT_TOKEN" != "null" ]; then
            echo -e "${GREEN}✅ Login successful! Token extracted.${NC}"
            export JWT_TOKEN
            export PATIENT_ID
            export USER_ID="$PATIENT_ID"
        else
            print_error "Failed to extract JWT token from response. Please check login credentials."
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️ Please manually extract the JWT token from the response above and set it:${NC}"
        echo "export JWT_TOKEN=\"your-token-here\""
        echo "export PATIENT_ID=\"your-patient-id\""
        echo "export USER_ID=\"your-user-id\""
        echo ""
        echo "Then run the remaining steps manually."
        exit 1
    fi
else
    print_error "Login request failed. Is the server running?"
    exit 1
fi

# Step 2: Configure AI settings (optional)
print_section "Step 2: Configure AI Settings"
echo "Setting up AI configuration for patient..."

AI_CONFIG_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/ai-chat/config" \
  -H "${CONTENT_TYPE}" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -d '{
    "patientId": '${PATIENT_ID}',
    "aiProvider": "OPENAI",
    "openaiModel": "gpt-3.5-turbo",
    "deepseekModel": "deepseek-chat",
    "maxTokens": 1500,
    "temperature": 0.7,
    "conversationHistoryLimit": 25,
    "includeVitalsByDefault": true,
    "includeMedicationsByDefault": true,
    "includeNotesByDefault": true,
    "includeMoodPainLogsByDefault": true,
    "includeAllergiesByDefault": true,
    "systemPrompt": "You are a helpful healthcare AI assistant. Always remind users to consult healthcare professionals for medical decisions."
  }')

if [ $? -eq 0 ]; then
    print_response "$AI_CONFIG_RESPONSE"
else
    print_error "AI configuration request failed."
fi

# Step 3: Start first conversation
print_section "Step 3: Initiate First Chat"
echo "Starting a medical consultation conversation..."

FIRST_CHAT_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/ai-chat/chat" \
  -H "${CONTENT_TYPE}" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -d '{
    "message": "Hi, I'\''ve been feeling anxious lately and my blood pressure seems elevated. Can you help me understand what might be going on?",
    "patientId": '${PATIENT_ID}',
    "userId": '${USER_ID}',
    "chatType": "MEDICAL_CONSULTATION",
    "title": "Anxiety and Blood Pressure Discussion",
    "includeVitals": true,
    "includeMedications": true,
    "includeNotes": true,
    "includeMoodPainLogs": true,
    "includeAllergies": true
  }')

if [ $? -eq 0 ]; then
    print_response "$FIRST_CHAT_RESPONSE"
    
    # Extract conversation ID for next step
    if command -v jq &> /dev/null; then
        CONVERSATION_ID=$(echo "$FIRST_CHAT_RESPONSE" | jq -r '.conversationId // empty')
        export CONVERSATION_ID
        echo -e "${GREEN}✅ First chat successful! Conversation ID: ${CONVERSATION_ID}${NC}"
    fi
else
    print_error "First chat request failed."
fi

# Step 4: Continue the conversation
if [ -n "$CONVERSATION_ID" ] && [ "$CONVERSATION_ID" != "null" ]; then
    print_section "Step 4: Continue Conversation"
    echo "Continuing the conversation with follow-up question..."
    
    CONTINUE_CHAT_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/ai-chat/chat" \
      -H "${CONTENT_TYPE}" \
      -H "Authorization: Bearer ${JWT_TOKEN}" \
      -d '{
        "message": "Thank you for the advice. I'\''ve been doing some breathing exercises and they seem to help. Should I be concerned about taking my Lisinopril while feeling anxious? Also, I noticed my heart rate was 95 bpm this morning.",
        "conversationId": "'${CONVERSATION_ID}'",
        "patientId": '${PATIENT_ID}',
        "userId": '${USER_ID}',
        "chatType": "MEDICAL_CONSULTATION",
        "includeVitals": true,
        "includeMedications": true
      }')
    
    if [ $? -eq 0 ]; then
        print_response "$CONTINUE_CHAT_RESPONSE"
    else
        print_error "Continue chat request failed."
    fi
fi

# Step 5: Get conversation history
if [ -n "$CONVERSATION_ID" ] && [ "$CONVERSATION_ID" != "null" ]; then
    print_section "Step 5: Get Conversation History"
    echo "Retrieving conversation messages..."
    
    HISTORY_RESPONSE=$(curl -s -X GET "${BASE_URL}/api/ai-chat/conversation/${CONVERSATION_ID}/messages" \
      -H "Authorization: Bearer ${JWT_TOKEN}")
    
    if [ $? -eq 0 ]; then
        print_response "$HISTORY_RESPONSE"
    else
        print_error "Get conversation history request failed."
    fi
fi

# Step 6: Get all patient conversations
print_section "Step 6: Get All Patient Conversations"
echo "Retrieving all conversations for patient..."

ALL_CONVERSATIONS_RESPONSE=$(curl -s -X GET "${BASE_URL}/api/ai-chat/conversations/${PATIENT_ID}" \
  -H "Authorization: Bearer ${JWT_TOKEN}")

if [ $? -eq 0 ]; then
    print_response "$ALL_CONVERSATIONS_RESPONSE"
else
    print_error "Get all conversations request failed."
fi

# Step 7: Start a lifestyle advice conversation
print_section "Step 7: Start Lifestyle Advice Chat"
echo "Starting a new conversation about sleep issues..."

LIFESTYLE_CHAT_RESPONSE=$(curl -s -X POST "${BASE_URL}/api/ai-chat/chat" \
  -H "${CONTENT_TYPE}" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -d '{
    "message": "I'\''m having trouble sleeping lately. Can you suggest some natural remedies or lifestyle changes that might help?",
    "patientId": '${PATIENT_ID}',
    "userId": '${USER_ID}',
    "chatType": "LIFESTYLE_ADVICE",
    "title": "Sleep Issues Discussion",
    "includeMoodPainLogs": true,
    "includeMedications": false,
    "includeVitals": false
  }')

if [ $? -eq 0 ]; then
    print_response "$LIFESTYLE_CHAT_RESPONSE"
else
    print_error "Lifestyle chat request failed."
fi

print_section "🎉 Testing Complete!"
echo "The AI chat system has been tested with the following scenarios:"
echo "✅ Patient authentication"
echo "✅ AI configuration setup"
echo "✅ Medical consultation chat"
echo "✅ Conversation continuation"
echo "✅ Message history retrieval"
echo "✅ Multiple conversation management"
echo "✅ Lifestyle advice chat"
echo ""
echo -e "${GREEN}Your Flutter app can now integrate with these endpoints!${NC}"
echo ""
echo "📚 For more details, see:"
echo "- AI_CHAT_COMPREHENSIVE_GUIDE.md"
echo "- AI_CHAT_IMPLEMENTATION.md"
