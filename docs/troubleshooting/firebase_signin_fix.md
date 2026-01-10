# Fix Firebase Google Sign-In Error

## Problem
The error `[firebase_auth/invalid-credential]` occurs because your `google-services.json` is missing the OAuth client configuration needed for Google Sign-In.

## Root Cause
Looking at your `google-services.json`, the `oauth_client` array is empty:
```json
"oauth_client": [],
```

This should contain the Web Client ID for your Firebase project.

## Solution

### Option 1: Re-download google-services.json (Easiest)

1. **Go to Firebase Console**:
   - https://console.firebase.google.com/project/vivant-24bb2/settings/general

2. **In the "Your apps" section**, find your Android app (`com.gammagamma.vivant`)

3. **Click "google-services.json"** to download a fresh copy

4. **Replace** the existing file:
   ```bash
   cp ~/Downloads/google-services.json android/app/src/standard/google-services.json
   ```

5. **Verify** the file now has OAuth clients populated

### Option 2: Enable Google Sign-In Properly

If the downloaded file still has empty `oauth_client`, you need to enable Google Sign-In properly:

1. **Go to Firebase Console > Authentication > Sign-in method**:
   - https://console.firebase.google.com/project/vivant-24bb2/authentication/providers

2. **Enable Google provider** if not already enabled

3. **Important: Configure OAuth Consent Screen** (if you haven't):
   - Go to Google Cloud Console: https://console.cloud.google.com/apis/credentials/consent
   - Select project: vivant-24bb2
   - Configure the OAuth consent screen
   - Add test users if in testing mode

4. **Add SHA-1 Fingerprint**:
   - Get your debug SHA-1:
     ```bash
     keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
     ```
     Password: `android`
   
   - Go to Firebase Console > Project Settings > Your Apps > Android app
   - Click "Add fingerprint" and paste your SHA-1
   - This step is CRITICAL for Android Google Sign-In to work

5. **Download fresh google-services.json** and replace the old one

### Option 3: Remove serverClientId (Quick Test)

If you just want to test quickly, you can try removing the `serverClientId` from the code:

```dart
// In lib/services/auth_service.dart
void _initGoogleSignIn() {
  _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Remove serverClientId line temporarily
  );
}
```

However, this may cause issues with backend authentication since the ID token might not be properly scoped.

## After Fixing

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run --flavor standard
   ```

2. **Test sign-in** - should work without the invalid-credential error

## What the google-services.json Should Look Like

After fixing, your `oauth_client` section should look like:
```json
"oauth_client": [
  {
    "client_id": "480934611158-XXXXX.apps.googleusercontent.com",
    "client_type": 3
  }
]
```

## Additional Notes

- The `serverClientId` in your code (`1065629554129-8kga3nbaklb6pr9afd12ac47j8s1ufkq.apps.googleusercontent.com`) appears to be from a different project (project number `1065629554129` vs your current `480934611158`)
- You may need to update the `serverClientId` in `auth_service.dart` to match your Firebase project's Web Client ID once you get the proper `google-services.json`
