# Test Credential Bypass Guide

## Changes Made

1. **User Entity**: Kept `unique = true` constraint on email field (normal authentication)
2. **AuthService**: 
   - Added test credential bypass for specific email/password
   - Test credentials: `kancyvaaan@gmail.com` / `vaan@test123`
   - Normal authentication flow remains intact for all other users
3. **UserRepository**: Standard repository methods (no changes needed)

## Test Credentials

**Email**: `kancyvaaan@gmail.com`  
**Password**: `vaan@test123`

These credentials will always pass authentication regardless of whether the user exists in the database.

## Testing the Bypass

### 1. Test Login (Always Works)

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "kancyvaaan@gmail.com",
    "password": "vaan@test123"
  }'
```

**Expected Response:**
```json
{
  "message": "Test login successful",
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

### 2. Test Password Reset (Always Works)

```bash
curl -X POST http://localhost:8080/api/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "kancyvaaan@gmail.com"
  }'
```

**Expected Response:**
```
Test password reset successful - Token: test-reset-token-12345
```

### 3. Normal Authentication Still Works

```bash
# Signup a normal user
curl -X POST http://localhost:8080/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "normal@example.com",
    "password": "password123",
    "phoneNumber": "1234567890"
  }'

# Login with normal user
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "normal@example.com",
    "password": "password123"
  }'
```

## How It Works

1. **Test Credential Check**: The system first checks if the provided credentials match the hardcoded test credentials
2. **Bypass**: If they match, authentication succeeds immediately without checking the database
3. **Normal Flow**: For all other credentials, the normal authentication flow is followed
4. **Database**: Test credentials don't need to exist in the database

## Benefits

- ✅ Always works for testing purposes
- ✅ Doesn't interfere with normal user authentication
- ✅ No database changes required
- ✅ Easy to remove when testing is complete
- ✅ Maintains security for production users

## Notes

- The test credentials are hardcoded in the `AuthService` class
- They will work even if the user doesn't exist in the database
- Normal users still need to signup and follow the regular authentication process
- Phone number uniqueness is still enforced for normal users
