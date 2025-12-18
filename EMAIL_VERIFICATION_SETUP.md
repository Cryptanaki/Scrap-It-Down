# Email Verification via Firebase Cloud Functions - Next Steps

## What We've Done ✅

1. **Updated Flutter App** (`lib/services/auth_service.dart`):
   - Added `cloud_functions` package to pubspec.yaml
   - Modified `generateVerificationCode()` to be async and call Firebase Cloud Function
   - Function sends email with verification code before showing code entry screen

2. **Updated UI** (`lib/screens/account_screen.dart`):
   - "Next" button now awaits the Cloud Function call
   - Shows "Verification code sent to your email" (no longer displays code in SnackBar)

3. **Created Setup Documentation**:
   - `FIREBASE_CLOUD_FUNCTIONS_SETUP.md` - Complete setup instructions
   - `CLOUD_FUNCTION_CODE.ts` - Ready-to-use function code (with Gmail & SendGrid options)

## What You Need to Do 🚀

### Step 1: Run Firebase Setup (One-time)

Open PowerShell in your project root and run:

```powershell
firebase login
firebase init functions
```

When prompted, choose:
- **Language**: TypeScript
- **ESLint**: Yes

### Step 2: Install Email Package

```powershell
cd functions
npm install nodemailer
npm install --save-dev @types/nodemailer
cd ..
```

### Step 3: Copy Cloud Function Code

Replace `functions/src/index.ts` with the code from `CLOUD_FUNCTION_CODE.ts` (included in repo).

### Step 4: Set Up Email Credentials

**Choose one option:**

#### Option A: Gmail (Easiest)
1. Enable 2-Factor Authentication on your Gmail
2. Go to [https://myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
3. Generate app password for "Mail" and "Windows"
4. Run:
```powershell
firebase functions:config:set gmail.email="your-email@gmail.com" gmail.password="your-16-char-password"
```

#### Option B: SendGrid (Recommended for Production)
1. Sign up at [https://sendgrid.com](https://sendgrid.com) (free: 100 emails/day)
2. Get API key from Settings → API Keys
3. Run:
```powershell
firebase functions:config:set sendgrid.api_key="SG.your-full-api-key"
```

### Step 5: Deploy Function

```powershell
firebase deploy --only functions
```

You should see:
```
✔ Deploy complete!
```

### Step 6: Test

1. Run your Flutter app: `flutter run -d windows`
2. Tap "Sign Up"
3. Enter email + password, tap "Next"
4. Check your email inbox for the verification code
5. Enter the code in the app to complete signup

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Function not found" | Run `firebase deploy --only functions` again |
| Email not arriving | Check Firebase Console → Functions → Logs for errors |
| Auth failed (Gmail) | Make sure 2FA is enabled and app password is correct |
| SendGrid not working | Verify API key is correct (starts with `SG.`) |
| "CORS error" | Not an issue - Cloud Functions HTTP triggers allow Flutter by default |

## Architecture

```
User taps "Next"
    ↓
AuthService.generateVerificationCode(email) [async]
    ↓
Calls Firebase Cloud Function: sendVerificationEmail
    ↓
Function sends email with code
    ↓
UI shows "Verification code sent to your email"
    ↓
User enters code from email
    ↓
AuthService.verifyCode() confirms match + checks 10-min expiry
    ↓
Account created, user can sign in
```

## Security Notes

- ✅ Codes expire after 10 minutes (set in AuthService)
- ✅ Codes are 6-digit random numbers
- ✅ Email + password required for signup (no public access)
- ⚠️ Add rate limiting in production (prevents abuse)
- ⚠️ Don't commit email credentials (use Firebase config)

## Files Modified

- `lib/services/auth_service.dart` - Cloud Functions call
- `lib/screens/account_screen.dart` - Async code generation
- `pubspec.yaml` - Added cloud_functions package
- `FIREBASE_CLOUD_FUNCTIONS_SETUP.md` - Setup guide (NEW)
- `CLOUD_FUNCTION_CODE.ts` - Function template (NEW)

Good luck! 🚀
