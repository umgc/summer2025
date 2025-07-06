# Family Member Functionality Documentation

## Overview
The family member functionality allows family members to be registered and granted read-only access to patient data. Family members can view patient information, vital signs, and analytics but cannot make any modifications.

## Key Features

### 1. **Family Member Registration**
- Patients or caregivers can register family members
- Family members receive a password setup email
- Registration creates a user account and links them to the patient

### 2. **Read-Only Access**
- Family members can view patient data but cannot modify it
- Access includes basic patient information, vital signs, and analytics
- Family members cannot register other family members or update patient records

### 3. **Access Control**
- Role-based access control ensures proper permissions
- Family members can only access patients they are explicitly linked to
- Access can be revoked by patients or caregivers

## API Endpoints

### Patient Controller (`/v1/api/patients`)

#### Get Family Members for a Patient
```
GET /v1/api/patients/{patientId}/family-members
```
- **Description**: Get all family members linked to a specific patient
- **Access**: Patient, Caregiver, or Admin
- **Response**: List of `FamilyMemberLinkResponse`

#### Register Family Member
```
POST /v1/api/patients/{patientId}/family-members
```
- **Description**: Register a new family member for a patient
- **Access**: Patient or Caregiver only (not Family Members)
- **Request Body**: `FamilyMemberRegistration`
- **Response**: `FamilyMemberLinkResponse`

#### Revoke Family Member Access
```
DELETE /v1/api/patients/family-members/{linkId}
```
- **Description**: Revoke a family member's access to patient data
- **Access**: Patient or Caregiver only
- **Response**: 204 No Content

### Family Member Controller (`/v1/api/family-members`)

#### Get Accessible Patients
```
GET /v1/api/family-members/patients
```
- **Description**: Get all patients the family member has access to
- **Access**: Family Member only
- **Response**: List of `PatientDataResponse`

#### Get Patient Data
```
GET /v1/api/family-members/patients/{patientId}
```
- **Description**: Get detailed read-only data for a specific patient
- **Access**: Family Member only (with access to the patient)
- **Response**: `PatientDataResponse`

#### Check Patient Access
```
GET /v1/api/family-members/patients/{patientId}/access
```
- **Description**: Check if family member has access to a specific patient
- **Access**: Family Member only
- **Response**: Boolean

#### Get Patient Dashboard
```
GET /v1/api/family-members/patients/{patientId}/dashboard?days=30
```
- **Description**: Get patient dashboard analytics (read-only)
- **Access**: Family Member only (with access to the patient)
- **Parameters**: `days` - Number of days to include in analytics (default: 30)
- **Response**: `DashboardDTO`

#### Get Patient Vitals
```
GET /v1/api/family-members/patients/{patientId}/vitals?days=7
```
- **Description**: Get patient vital signs (read-only)
- **Access**: Family Member only (with access to the patient)
- **Parameters**: `days` - Number of days to include (default: 7)
- **Response**: List of `VitalSampleDTO`

## Data Models

### FamilyMemberRegistration
```json
{
  "firstName": "Jane",
  "lastName": "Doe",
  "email": "jane@example.com",
  "phone": "555-1234",
  "address": {
    "line1": "123 Main St",
    "line2": "Apt 4B",
    "city": "City",
    "state": "State",
    "zip": "12345"
  },
  "relationship": "Daughter",
  "patientUserId": 1
}
```

### FamilyMemberLinkResponse
```json
{
  "id": 1,
  "familyUserId": 3,
  "familyMemberName": "Jane Doe",
  "familyMemberEmail": "jane@example.com",
  "patientUserId": 1,
  "patientName": "John Doe",
  "relationship": "Daughter",
  "status": "ACTIVE",
  "createdAt": "2025-01-01T10:00:00",
  "grantedBy": "John Doe"
}
```

### PatientDataResponse
```json
{
  "patientUserId": 1,
  "patientName": "John Doe",
  "email": "john@example.com",
  "phone": "555-5678",
  "relationship": "Daughter",
  "recentVitals": [...],
  "dashboard": {...},
  "accessLevel": "READ_ONLY"
}
```

## Security Features

### Role-Based Access Control
- **PATIENT**: Can view their own data, register family members, revoke access
- **CAREGIVER**: Can view assigned patients, register family members, revoke access
- **FAMILY_MEMBER**: Can view linked patients (read-only), cannot modify anything
- **ADMIN**: Can access all functionality

### Access Validation
- Every request validates the user's role and permissions
- Family members are restricted to read-only operations
- Cross-user access is prevented through proper authorization checks

### Data Protection
- Family member access is explicitly granted and can be revoked
- Audit trail maintained for who granted access and when
- Secure password setup process via email tokens

## Usage Examples

### 1. Patient Registering a Family Member
```bash
# Patient (user ID 1) registers their daughter
curl -X POST /v1/api/patients/1/family-members \
  -H "Authorization: Bearer <patient-jwt-token>" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Doe",
    "email": "jane@example.com",
    "phone": "555-1234",
    "address": {"line1": "123 Main St", "city": "City", "state": "State", "zip": "12345"},
    "relationship": "Daughter",
    "patientUserId": 1
  }'
```

### 2. Family Member Viewing Patient Data
```bash
# Family member views accessible patients
curl -X GET /v1/api/family-members/patients \
  -H "Authorization: Bearer <family-member-jwt-token>"

# Family member views specific patient dashboard
curl -X GET /v1/api/family-members/patients/1/dashboard?days=30 \
  -H "Authorization: Bearer <family-member-jwt-token>"
```

### 3. Revoking Family Member Access
```bash
# Patient or caregiver revokes access
curl -X DELETE /v1/api/patients/family-members/1 \
  -H "Authorization: Bearer <patient-or-caregiver-jwt-token>"
```

## Database Schema

The family member functionality uses these key tables:
- `users` - User accounts with role information
- `family_member_link` - Links between family members and patients
- `patient` - Patient profiles
- `caregiver` - Caregiver profiles

## Error Handling

Common error responses:
- **403 Forbidden**: User lacks permission for the requested action
- **404 Not Found**: Patient or family member not found
- **409 Conflict**: Email already registered
- **400 Bad Request**: Invalid request data

## Implementation Notes

1. **Email Integration**: Family members receive password setup emails when registered
2. **Token-Based Setup**: Secure token system for password setup
3. **Audit Trail**: All family member actions are logged with timestamps
4. **Scalable Design**: Supports multiple family members per patient
5. **Read-Only Enforcement**: Technical enforcement of read-only access at the controller level

This implementation provides a secure, scalable way for family members to access patient data while maintaining appropriate access controls and audit trails.
