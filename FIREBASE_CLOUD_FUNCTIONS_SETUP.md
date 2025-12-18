# Firebase Cloud Functions Setup for Email Verification

This guide walks you through setting up Firebase Cloud Functions to send verification codes via email.

## Prerequisites

1. Firebase project already created (from Firebase Console)
2. Node.js 18+ installed locally
3. Firebase CLI installed: `npm install -g firebase-tools`

## Step 1: Initialize Firebase Functions in Your Project

Navigate to your project root and initialize Firebase:

```bash
cd c:\scrap_it_down
firebase login
firebase init functions
```

When prompted:
- **Language**: Choose `TypeScript`
- **ESLint**: Choose `Yes`

This creates a `functions/` folder at the project root.

## Step 2: Install Dependencies

```bash
cd functions
npm install nodemailer
npm install --save-dev @types/nodemailer
```

## Step 3: Create the Cloud Function

Replace the contents of `functions/src/index.ts` with the code provided in `CLOUD_FUNCTION_CODE.ts` in this directory.

**Important**: Replace `YOUR_SENDER_EMAIL` and `YOUR_APP_PASSWORD` in the function with your actual credentials (see next step).

## Step 4: Set Up Email Credentials

You have two options:

### Option A: Gmail (Free, Easiest)

1. Enable 2-Factor Authentication on your Gmail account
2. Go to [Google App Passwords](https://myaccount.google.com/apppasswords)
3. Generate a new app password for "Mail" and "Windows"
4. Copy the 16-character password

Then set Firebase config:

```bash
firebase functions:config:set gmail.email="your-email@gmail.com" gmail.password="your-16-char-password"
```

Update the Cloud Function to use these config values (see code template).

### Option B: SendGrid (More Reliable for Production)

1. Sign up at [SendGrid.com](https://sendgrid.com) (free tier: 100 emails/day)
2. Get your API key from Settings → API Keys
3. Set Firebase config:

```bash
firebase functions:config:set sendgrid.api_key="SG.your-api-key-here"
```

Update the Cloud Function to use SendGrid (alternative code provided in template).

## Step 5: Deploy

```bash
firebase deploy --only functions
```

This deploys the `sendVerificationEmail` function to your Firebase project.

## Step 6: Test Locally (Optional)

Run the emulator:

```bash
firebase emulators:start --only functions
```

Then test by calling the function from your app. The emulator will display logs.

## Verification

After deployment, you should see:

```
✔  Deploy complete!
```

The function URL will be displayed. Your Flutter app will call this function automatically when users sign up.

## Troubleshooting

- **"Function not found"**: Make sure `firebase deploy` completed successfully
- **"Email not sent"**: Check function logs: `firebase functions:log`
- **"Authentication failed"**: Verify your email credentials in Firebase Console → Functions → Environment variables
- **"CORS error"**: Cloud Functions HTTP triggers automatically allow CORS from Flutter apps

## Notes

- Verification codes expire after **10 minutes** (set in `AuthService`)
- Emails are sent immediately when user taps "Next"
- If email sending fails, the app still allows code verification for testing (code logged to console)
- For production, add rate limiting to prevent abuse
