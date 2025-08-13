# Password Reset Flow Documentation

## Overview

The CareConnect backend implements a secure password reset flow that allows both caregivers and patients to reset their passwords using a token-based approach. The flow has been cleaned up to use a single, secure endpoint.

## Complete Password Reset Flow

### Step 1: User Requests Password Reset

**Endpoint:** `POST /api/auth/password/forgot`
**Authentication:** None required (public endpoint)

The user (caregiver or patient) requests a password reset by providing their email address.

**Request Body:**
```json
{
    "email": "user@example.com"
}
```

**Response:**
```json
{
    "message": "If an account with this email exists, you will receive a password reset link."
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/auth/password/forgot \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com"
  }'
```

### Step 2: Email Delivery

The backend:
1. Validates the email exists in the system (caregivers or patients)
2. Generates a secure random token
3. Stores the token hash in the `password_reset_token` table with expiration time
4. Sends an email with a reset link containing the raw token

**Email content includes:**
- Reset link: `{FRONTEND_URL}/reset?token={RAW_TOKEN}`
- Token expires in 1 hour

### Step 3: User Clicks Reset Link

The frontend receives the token from the URL parameter and presents a form for the user to:
1. Enter their email/username (for additional security)
2. Enter their new password
3. Confirm the new password

### Step 4: Frontend Submits New Password

**Endpoint:** `POST /api/users/reset-password`
**Authentication:** None required (public endpoint)

The frontend sends the username, reset token, and new password to complete the reset.

**Request Body:**
```json
{
    "username": "user@example.com",
    "resetToken": "abc123-reset-token-xyz789",
    "newPassword": "NewSecurePassword123!"
}
```

**Success Response:**
```json
{
    "message": "Password updated successfully"
}
```

**Error Response:**
```json
{
    "error": "Invalid or expired reset token"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/users/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "username": "user@example.com",
    "resetToken": "abc123-reset-token-xyz789",
    "newPassword": "NewSecurePassword123!"
  }'
```

## Security Features

### Token Security
- **Secure Generation:** Tokens are generated using `SecureRandom` with 32 bytes (256 bits)
- **Hashed Storage:** Only SHA-256 hashes of tokens are stored in the database
- **Time-Based Expiration:** Tokens expire after 1 hour
- **Single Use:** Tokens are marked as used after successful password reset
- **User Validation:** Additional check ensures token belongs to the requesting user

### Email Security
- **No Information Disclosure:** Response is the same whether email exists or not
- **Rate Limiting:** Consider implementing rate limiting on the forgot password endpoint
- **Audit Logging:** All password reset attempts are logged for security monitoring

### Password Requirements
- Passwords are encoded using BCrypt before storage
- Consider implementing password complexity requirements on the frontend

## Database Schema

The `password_reset_token` table structure:
```sql
CREATE TABLE password_reset_token (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expiry_date TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

## API Documentation

Both endpoints are documented in Swagger/OpenAPI and marked as public:
- **Swagger UI:** http://localhost:8080/swagger-ui.html
- **OpenAPI Docs:** http://localhost:8080/v3/api-docs

### Testing in Swagger

1. Navigate to the Swagger UI
2. Look for the "Authentication" or "User Management" sections
3. Both endpoints (`/api/auth/password/forgot` and `/api/users/reset-password`) are marked with 🔓 indicating no authentication required
4. Use the "Try it out" feature to test the endpoints

## Environment Configuration

Ensure these environment variables are set:

```properties
# Frontend URL for reset links
FRONTEND_BASE_URL=http://localhost:3000

# SendGrid configuration for email delivery
SENDGRID_API_KEY=your-sendgrid-api-key
SENDGRID_FROM_EMAIL=your-verified-sender@domain.com

# Database configuration
JDBC_URI=jdbc:mysql://localhost:3306/careconnect
DB_USERNAME=your-db-username
DB_PASSWORD=your-db-password
```

## Frontend Integration Example

Here's how the frontend should handle the complete flow:

### 1. Forgot Password Form
```javascript
// Send forgot password request
const forgotPassword = async (email) => {
  const response = await fetch('/api/auth/password/forgot', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email })
  });
  
  const result = await response.json();
  // Show success message regardless of whether email exists
  alert(result.message);
};
```

### 2. Reset Password Form (after clicking email link)
```javascript
// Extract token from URL
const urlParams = new URLSearchParams(window.location.search);
const resetToken = urlParams.get('token');

// Submit new password
const resetPassword = async (username, newPassword) => {
  const response = await fetch('/api/users/reset-password', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      username,
      resetToken,
      newPassword
    })
  });
  
  const result = await response.json();
  
  if (response.ok) {
    alert('Password reset successful! You can now log in.');
    // Redirect to login page
    window.location.href = '/login';
  } else {
    alert('Error: ' + result.error);
  }
};
```

## Troubleshooting

### Common Issues

1. **Email not received:**
   - Check SendGrid dashboard for activity logs
   - Verify sender email is verified in SendGrid
   - Check spam folder

2. **Token invalid/expired:**
   - Tokens expire after 1 hour
   - Each token can only be used once
   - Ensure exact token from email is used

3. **User not found:**
   - Verify email exists in either caregivers or patients table
   - Check for typos in email address

### Debug Mode

To enable debug logging, check the console output for:
- `🔄 Password reset requested for email: {email}`
- `✅ Password reset process initiated for: {email}`
- `❌ Password reset failed for {email}: {error}`

## Cleanup Summary

The following cleanup was performed:

1. **Removed Duplicate Endpoint:** Eliminated the duplicate `POST /auth/password/reset` endpoint
2. **Kept Secure Implementation:** Retained `/api/users/reset-password` with username validation
3. **Enhanced Documentation:** Added comprehensive Swagger documentation with examples
4. **Removed Unused Code:** Deleted `ResetPasswordDTO` class
5. **Verified Security Config:** Confirmed both endpoints are public in SecurityConfig
6. **Validated Flow:** Ensured complete token-based password reset flow works end-to-end

The password reset functionality is now clean, secure, and well-documented!
