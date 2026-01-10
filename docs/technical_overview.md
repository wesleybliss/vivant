# Technical Overview

This document provides a high-level overview of the technical architecture, services, and data management in the Vivant application.

## Architecture

Vivant is a Flutter-based mobile application that uses a serverless backend and several third-party services for search and mapping.

- **Frontend**: Flutter (Dart)
- **Backend**: [Convex](https://convex.dev) (Serverless functions and NoSQL database)
- **Authentication**: Firebase Authentication with Google Sign-In
- **Mapping & POI**: Google Maps SDK and Google Places API

## Service Layer

The application logic is organized into several services located in `lib/services/`:

### 1. AuthService (`auth_service.dart`)
Handles user authentication using Firebase and Google Sign-In.
- **Provider**: Firebase Auth
- **Sign-In Method**: Google Sign-In (using `google_sign_in` package)
- **Token Management**: Retrieves Firebase ID tokens used for authenticating requests to the Convex backend.
- **Secure Storage**: Stores user IDs and tokens using `flutter_secure_storage`.

### 2. ConvexService (`convex_service.dart`)
Handles communication with the Convex backend.
- **Protocol**: HTTP POST requests to Convex API endpoints (`/api/query` and `/api/mutation`).
- **Authentication**: Includes the Firebase ID token in the `Authorization: Bearer <token>` header.
- **Capabilities**:
    - Syncing user profiles.
    - Managing user lists (CRUD operations).
    - Saving and retrieving places associated with lists.

### 3. PlacesService (`places_service.dart`)
Interacts with the Google Places API to provide search and discovery features.
- **Search**: Text-based POI search.
- **Autocomplete**: Location search suggestions.
- **Details**: Detailed information about specific places (rating, photos, address, etc.).
- **Security**: Uses API keys restricted by package name and SHA-1/Bundle ID.

## Data Management

### Cloud Storage
- **User Data**: User profiles, custom lists, and saved places are stored in the Convex database.
- **Consistency**: The `AuthGate` in `main.dart` ensures that the user's profile and default lists are synced to Convex upon successful authentication.

### Local Storage
- **Secure Data**: Authentication tokens and sensitive user identifiers are stored using `flutter_secure_storage`.
- **User Preferences**: Non-sensitive settings (theme mode, language, search filters) are stored using `shared_preferences` via the `SettingsProvider`.

## State Management

The application uses the `provider` package for state management:
- `AuthProvider`: Manages authentication state and token refresh.
- `ListsProvider`: Manages the user's saved lists and places, handling loading and local updates.
- `SettingsProvider`: Manages application-wide settings and persistence.

## Platform Compatibility & Incompatibilities

The application is designed to be cross-platform, but certain features have platform-specific requirements or limitations:

| Feature | Android | iOS | Web | Desktop (Linux/Windows) |
| :--- | :--- | :--- | :--- | :--- |
| **Authentication** | Fully supported (Google Sign-In requires SHA-1) | Fully supported (Requires GoogleService-Info.plist) | Supported | Limited (Google Sign-In support varies) |
| **Google Maps** | Native support | Native support | Supported (JavaScript API) | **Not officially supported** by `google_maps_flutter` |
| **Secure Storage** | Supported (EncryptedSharedPreferences) | Supported (Keychain) | Supported (LocalStorage - NOT SECURE) | Supported (libsecret/Keyring) |
| **Environment** | `.env` asset | `.env` asset | `.env` asset | `.env` asset |

### Known Incompatibilities

1. **Desktop Maps**: The `google_maps_flutter` package does not officially support Linux, Windows, or macOS. Running the app on these platforms will result in the map not rendering or errors in the map view.
2. **Firebase on Desktop**: Firebase Auth and other Firebase services have limited or community-supported implementations on Desktop. Full production support is primarily for Android, iOS, and Web.
3. **Google Sign-In on Desktop**: The `google_sign_in` package may require extra configuration or alternate flows for Desktop platforms.
