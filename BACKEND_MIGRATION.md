# Backend Migration: Clerk to Firebase Auth

## Overview
Your Convex backend needs to be updated to verify Firebase ID tokens instead of Clerk session tokens.

## Required Changes

### 1. Install Firebase Admin SDK
Add Firebase Admin SDK to your Convex backend:

```bash
npm install firebase-admin
```

### 2. Update Authentication Middleware

Replace Clerk token verification with Firebase token verification.

**Before (Clerk):**
```typescript
// Example Clerk verification
import { auth } from "@clerk/backend";

export const authenticateUser = async (token: string) => {
  const user = await auth().verifyToken(token);
  return user.userId;
};
```

**After (Firebase):**
```typescript
import * as admin from 'firebase-admin';

// Initialize Firebase Admin (do this once)
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    }),
  });
}

export const authenticateUser = async (token: string) => {
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return decodedToken.uid; // Firebase UID
  } catch (error) {
    throw new Error('Invalid authentication token');
  }
};
```

### 3. Update Environment Variables

Add Firebase service account credentials to your Convex environment:

```bash
# Get these from Firebase Console > Project Settings > Service Accounts
FIREBASE_PROJECT_ID=vivant-24bb2
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@vivant-24bb2.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

To get the service account key:
1. Go to Firebase Console
2. Project Settings > Service Accounts
3. Click "Generate new private key"
4. Download the JSON file
5. Extract `project_id`, `client_email`, and `private_key`

### 4. Update Database Schema

**Update users table:**
- Rename `clerkId` field to `firebaseUid`
- Update indexes if you have any on `clerkId`

**Migration script example (if you have existing users):**
```typescript
// convex/migrations/clerkToFirebase.ts
import { mutation } from "./_generated/server";

export default mutation(async ({ db }) => {
  const users = await db.query("users").collect();
  
  for (const user of users) {
    await db.patch(user._id, {
      firebaseUid: user.clerkId,
    });
  }
});
```

### 5. Update Auth Functions

Update all functions that reference Clerk user IDs:

**Example query:**
```typescript
// Before
export const getUserLists = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    const user = await ctx.db
      .query("users")
      .withIndex("by_clerk_id", (q) => q.eq("clerkId", identity.subject))
      .first();
    
    // ... rest of query
  },
});

// After
export const getUserLists = query({
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) throw new Error("Not authenticated");
    
    const user = await ctx.db
      .query("users")
      .withIndex("by_firebase_uid", (q) => q.eq("firebaseUid", identity.subject))
      .first();
    
    // ... rest of query
  },
});
```

### 6. Update Convex Auth Configuration

If you're using Convex's auth configuration, update it to work with Firebase:

**convex.json or auth.config.ts:**
```typescript
export default {
  providers: [
    {
      domain: "https://securetoken.google.com/vivant-24bb2",
      applicationID: "vivant-24bb2",
    },
  ],
};
```

## Testing the Migration

1. **Update Flutter app** (already done ✓)
2. **Deploy backend changes**
3. **Test authentication flow:**
   - Sign in with Google in the app
   - Verify Firebase token is sent to backend
   - Check that backend successfully verifies the token
   - Ensure user data is retrieved correctly
4. **Monitor logs** for any authentication errors

## Rollback Plan

If you need to rollback:
1. Keep the old Clerk verification code
2. Support both Clerk and Firebase tokens temporarily
3. Check token format to determine which verification to use

```typescript
export const authenticateUser = async (token: string) => {
  // Try Firebase first
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    return { uid: decodedToken.uid, provider: 'firebase' };
  } catch (firebaseError) {
    // Fallback to Clerk
    try {
      const clerkUser = await clerkAuth().verifyToken(token);
      return { uid: clerkUser.userId, provider: 'clerk' };
    } catch (clerkError) {
      throw new Error('Invalid authentication token');
    }
  }
};
```

## Important Notes

- Firebase ID tokens expire after 1 hour (Clerk tokens may have different expiration)
- The Flutter app now refreshes tokens automatically via `getAccessToken()`
- Make sure to handle token refresh in your backend error handling
- Firebase tokens are JWTs and can be verified offline (similar to Clerk)

## Web App Migration

When you're ready to update your web app:
1. Replace `@clerk/nextjs` (or similar) with Firebase JS SDK
2. Use `signInWithPopup(auth, provider)` for Google Sign-In
3. Update all Clerk hooks with Firebase equivalents
4. Update environment variables
5. Test thoroughly before deploying
