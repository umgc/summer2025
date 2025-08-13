# Email Testing Guide

This guide helps you test and debug email functionality in the CareConnect backend.

## Email Provider Options

### Development/Testing Providers

1. **console** - Log emails to console (basic development)
2. **mailtrap** - Use Mailtrap for email testing (recommended for development)

### Production Providers

3. **smtp** - Generic SMTP server
4. **resend** - Resend API (production)
5. **mailgun** - Mailgun API (production)
6. **sendgrid** - SendGrid API (production)
7. **gmail** - Gmail SMTP (production)

## SendGrid Setup (Recommended for Production)

SendGrid is a cloud-based email service that provides reliable email delivery for production applications.

### How to Use SendGrid

1. **Sign up for SendGrid** at [sendgrid.com](https://sendgrid.com)
2. **Create an API key** in your SendGrid dashboard:
   - Go to Settings → API Keys
   - Click "Create API Key"
   - Choose "Full Access" or "Restricted Access" with Mail Send permissions
   - Copy the generated API key
3. **Configure environment variables:**
   ```bash
   export EMAIL_PROVIDER=sendgrid
   export SENDGRID_API_KEY=your-sendgrid-api-key
   export FROM_EMAIL=noreply@yourdomain.com
   ```

#### SendGrid Advantages
- ✅ **High deliverability** - Trusted by major companies
- ✅ **Real-time analytics** - Track email opens, clicks, bounces
- ✅ **Scalable** - Handle high volumes of emails
- ✅ **Template support** - Use dynamic templates
- ✅ **Compliance** - GDPR, CAN-SPAM compliant

## Mailtrap Setup (Recommended for Development)

Mailtrap is a professional email testing service that captures all emails sent from your application for safe testing.

### How to Use Mailtrap

1. **Sign up for Mailtrap:**
   - Go to [mailtrap.io](https://mailtrap.io)
   - Create a free account
   - Create a new inbox

2. **Get your Mailtrap credentials:**
   - Go to your inbox settings
   - Copy the SMTP credentials

3. **Configure environment variables:**
   ```bash
   export EMAIL_PROVIDER=mailtrap
   export MAIL_HOST=live.smtp.mailtrap.io
   export MAIL_PORT=587
   export MAIL_USERNAME=api
   export MAIL_PASSWORD=your-mailtrap-token
   export FROM_EMAIL=noreply@careconnect.com
   ```

## Available Email Test Endpoints

### 1. Health Check
**GET** `/v1/api/email-test/health`

Quick check to see if email service is configured correctly.

```bash
curl -X GET http://localhost:8080/v1/api/email-test/health
```

### 2. Configuration Details
**GET** `/v1/api/email-test/config`

Get detailed information about current email configuration.

```bash
curl -X GET http://localhost:8080/v1/api/email-test/config
```

### 3. Send Test Email
**POST** `/v1/api/email-test/send`

Send a single test email to verify configuration.

```bash
curl -X POST http://localhost:8080/v1/api/email-test/send \
  -H "Content-Type: application/json" \
  -d '{"email": "your-email@example.com"}'
```

## Environment Variables

```bash
# Email provider selection
EMAIL_PROVIDER=console|mailtrap|sendgrid|mailgun|resend|gmail

# SMTP configuration (for mailtrap, gmail)
MAIL_HOST=smtp.example.com
MAIL_PORT=587
MAIL_USERNAME=your-username
MAIL_PASSWORD=your-password

# API-based providers
SENDGRID_API_KEY=your-sendgrid-api-key
RESEND_API_KEY=your-resend-api-key
MAILGUN_API_KEY=your-mailgun-api-key
MAILGUN_DOMAIN=your-mailgun-domain

# From email address
FROM_EMAIL=noreply@careconnect.com
```

## Switching Between Environments

### Development
```bash
export EMAIL_PROVIDER=console
# or
export EMAIL_PROVIDER=mailtrap
```

### Production
```bash
export EMAIL_PROVIDER=sendgrid
export SENDGRID_API_KEY=your-sendgrid-api-key
```

This allows you to easily switch between development and production email providers without changing your code.
