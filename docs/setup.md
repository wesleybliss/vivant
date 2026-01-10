# Vivant Gastronomy - Flutter Setup Guide

## Quick Start

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase Authentication

Firebase Authentication is already configured in the project.

1. **Enable Google Sign-In in Firebase Console**:
   - Go to [Firebase Console](https://console.firebase.google.com)
   - Select your project (vivant-24bb2)
   - Navigate to "Authentication" → "Sign-in method"
   - Enable "Google" as a sign-in provider
   - Add your project's support email

2. **Add SHA-1 fingerprint for Android (Required)**:
   - Get your debug SHA-1:
     ```bash
     keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore
     ```
     Default password is `android`
   - Go to Firebase Console → Project Settings → Your Apps
   - Add the SHA-1 fingerprint
   - Download the updated `google-services.json` and place it in `android/app/src/standard/`

3. **Update .env File**:
   ```bash
   CONVEX_URL=https://majestic-okapi-86.convex.cloud
   ```

### 3. Run the App

```bash
# Android
flutter run

# Linux Desktop
flutter run -d linux

# Check available devices
flutter devices
```

## Architecture

### Authentication Flow
1. User taps "Sign In with Google"
2. Google Sign-In dialog appears
3. User selects Google account and authenticates
4. App exchanges Google credentials for Firebase auth
5. Firebase ID token is stored in secure storage
6. ConvexService receives Firebase ID token for backend auth
7. App calls `ensureDefaultLists()` on first login
8. Lists screen loads and displays saved lists

### Data Flow
```
UI (Screens)
    ↓
Providers (State Management)
    ↓
Services (Auth, Convex)
    ↓
Models (Data Classes)
```

## Testing Checklist

- [ ] Enable Google Sign-In in Firebase Console
- [ ] Add SHA-1 fingerprint to Firebase project
- [ ] Update google-services.json in `android/app/src/standard/`
- [ ] Build and run app: `flutter run --flavor standard`
- [ ] Tap "Sign In with Google"
- [ ] Select Google account in dialog
- [ ] Verify authentication succeeds
- [ ] Check that lists screen appears
- [ ] Verify default lists are created
- [ ] Tap on a list to view details
- [ ] Test sign out
- [ ] Verify login screen reappears

## Troubleshooting

### Google Sign-In fails
- Verify SHA-1 fingerprint is added to Firebase Console
- Ensure `google-services.json` is up to date in `android/app/src/standard/`
- Check that Google Sign-In is enabled in Firebase Authentication
- Verify serverClientId in auth_service.dart matches your Firebase project

### Build error with Firebase
- Make sure you're building with the standard flavor: `flutter run --flavor standard`
- Run `flutter clean` and `flutter pub get`
- Verify google-services.json exists in the correct location

### Lists don't load
- Check logs for API errors
- Verify CONVEX_URL in .env is correct
- Ensure Firebase ID token is being passed to ConvexService
- Backend must be updated to verify Firebase tokens instead of Clerk
- Check network connectivity

### "Failed to load .env"
- Ensure `.env` file exists in project root
- Verify it's added to assets in pubspec.yaml
- Run `flutter clean` and `flutter pub get`

## Development Notes

- All logs use the custom Logger utility with prefix "vivant"
- Auth tokens stored in flutter_secure_storage (encrypted on device)
- Convex uses HTTP API (no WebSocket/real-time updates yet)
- Pull-to-refresh to reload lists manually
- Provider pattern for all state management

## Next Features to Build

Once auth and lists are working:
1. Google Maps integration
2. POI search with Google Places API
3. Add places to lists from search
4. Create/edit/delete custom lists
5. Place details view
6. Map view of saved places
7. Fine-grained search filters

---

For detailed implementation notes, see `progress.md`
