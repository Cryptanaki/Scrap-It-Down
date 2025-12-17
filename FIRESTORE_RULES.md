Firestore rules for posts/comments (example)

This file shows a minimal ruleset to protect write operations on `posts`.

Note: adapt `request.auth != null` checks to your auth setup.

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /posts/{postId} {
      allow read: if true; // public read

      // Allow creation for authenticated users
      allow create: if request.auth != null && request.resource.data.sellerName == request.auth.token.name;

      // Allow update/delete only for the original seller (owner)
      allow update, delete: if request.auth != null && resource.data.sellerName == request.auth.token.name;

      // If you store comments inside the post document, ensure clients can't escalate privileges
      // Example: only allow comment bubbling via separate cloud function or require comment.author == request.auth.token.name
      allow write: if false; // prefer more granular rules or server-side enforcement
    }
  }
}
