// Firebase Cloud Functions - Email Verification Code Sender
// Copy this into functions/src/index.ts after running: firebase init functions

import * as functions from "firebase-functions";
import * as nodemailer from "nodemailer";

// ============================================================================
// IMPORTANT: Choose ONE email method below (Gmail or SendGrid)
// ============================================================================

// ============================================================================
// Option 1: Using Gmail (Recommended for getting started quickly)
// ============================================================================
// Set up your Gmail credentials first:
// 1. Enable 2FA on your Gmail account
// 2. Go to https://myaccount.google.com/apppasswords
// 3. Generate app password for "Mail" on "Windows"
// 4. Run: firebase functions:config:set gmail.email="your-email@gmail.com" gmail.password="your-16-char-password"

const gmailTransporter = () => {
  const email = functions.config().gmail?.email;
  const password = functions.config().gmail?.password;

  if (!email || !password) {
    console.error(
      "Gmail config not set. Run: firebase functions:config:set gmail.email='...' gmail.password='...'"
    );
  }

  return nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: email,
      pass: password,
    },
  });
};

// ============================================================================
// Option 2: Using SendGrid (More reliable for production)
// ============================================================================
// Set up SendGrid credentials:
// 1. Sign up at https://sendgrid.com (free tier: 100 emails/day)
// 2. Get API key from Settings → API Keys
// 3. Run: firebase functions:config:set sendgrid.api_key="SG.your-key"

const sendgridTransporter = () => {
  const apiKey = functions.config().sendgrid?.api_key;

  if (!apiKey) {
    console.error("SendGrid API key not set. Run: firebase functions:config:set sendgrid.api_key='SG.your-key'");
  }

  return nodemailer.createTransport({
    host: "smtp.sendgrid.net",
    port: 587,
    auth: {
      user: "apikey",
      pass: apiKey,
    },
  });
};

// ============================================================================
// Main Cloud Function
// ============================================================================

export const sendVerificationEmail = functions.https.onCall(
  async (data, context) => {
    const { email, code } = data;

    // Validate input
    if (!email || !code) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing email or code"
      );
    }

    try {
      // Choose your email transport:
      const transporter = gmailTransporter(); // Change to sendgridTransporter() if using SendGrid

      // Send email
      const info = await transporter.sendMail({
        from: functions.config().gmail?.email || "noreply@scrapitdown.com",
        to: email,
        subject: "Scrap It Down - Email Verification Code",
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h2 style="color: #333;">Welcome to Scrap It Down!</h2>
            <p>Your email verification code is:</p>
            <div style="background-color: #f0f0f0; padding: 20px; text-align: center; margin: 20px 0; border-radius: 5px;">
              <h1 style="letter-spacing: 5px; color: #0066cc; margin: 0;">${code}</h1>
            </div>
            <p>This code will expire in <strong>10 minutes</strong>.</p>
            <p>If you didn't request this code, you can safely ignore this email.</p>
            <hr style="margin: 30px 0; border: none; border-top: 1px solid #ddd;">
            <p style="color: #666; font-size: 12px;">
              Scrap It Down - Trade Smart, Trade Safe
            </p>
          </div>
        `,
        text: `Your Scrap It Down verification code is: ${code}\n\nThis code will expire in 10 minutes.`,
      });

      console.log(`Email sent to ${email}:`, info.messageId);
      return { success: true, messageId: info.messageId };
    } catch (error) {
      console.error("Error sending email:", error);
      throw new functions.https.HttpsError(
        "internal",
        "Failed to send verification email"
      );
    }
  }
);

// ============================================================================
// Optional: Add a test function to verify setup
// ============================================================================

export const testSendEmail = functions.https.onCall(async (data, context) => {
  const { email } = data;

  if (!email) {
    throw new functions.https.HttpsError("invalid-argument", "Missing email");
  }

  try {
    const transporter = gmailTransporter();
    await transporter.verify();
    return { success: true, message: "Email service is configured correctly" };
  } catch (error) {
    console.error("Email service test failed:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Email service is not configured correctly"
    );
  }
});
