# Google Maps API Setup

## Step 1: Get API Key from Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select your existing project
3. Enable required APIs:
   - Navigate to **APIs & Services** > **Library**
   - Search for and enable:
     - ✅ **Maps SDK for Android**
     - ✅ **Maps SDK for iOS** (if building for iOS)
     - ✅ **Places API** (optional, for future place search/details)

4. Create API credentials:
   - Go to **APIs & Services** > **Credentials**
   - Click **Create Credentials** > **API Key**
   - Copy the generated API key

## Step 2: Restrict Your API Key (Recommended)

To prevent unauthorized use:

1. Click on your API key in the credentials list
2. Under **Application restrictions**, choose:
   - **Android apps** for Android
   - **iOS apps** for iOS
3. Add your package name and SHA-1 certificate fingerprint for Android:
   ```bash
   # Get debug SHA-1
   cd android
   ./gradlew signingReport
   ```
4. Add your iOS bundle identifier for iOS
5. Click **Save**

## Step 3: Add API Key to Your App

### Android

The API key is already configured in `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE" />
```

**Replace `YOUR_API_KEY_HERE` with your actual API key.**

### iOS

The API key is already configured in `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
```

**Replace `YOUR_API_KEY_HERE` with your actual API key.**

## Step 4: Update Min SDK Version (Android)

Check that your `android/app/build.gradle` has minimum SDK 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // or higher
        ...
    }
}
```

## Step 5: Test the Setup

1. Replace both `YOUR_API_KEY_HERE` placeholders with your API key
2. Run the app:
   ```bash
   flutter run
   ```
3. Navigate to the Discover tab (map view)
4. You should see the Google Map with NYC centered

## Troubleshooting

### Map shows gray screen
- Check that the API key is correct
- Verify **Maps SDK for Android/iOS** is enabled in Google Cloud Console
- Check logcat/console for error messages
- Make sure you're connected to the internet

### "API key not found" error
- Double-check the API key is in the correct location
- Rebuild the app after adding the key
- For Android: `flutter clean && flutter run`

### Map works in debug but not release
- Make sure you've added the release SHA-1 certificate to API restrictions
- Check that API key restrictions allow your package name

## Cost Information

Google Maps Platform has a free tier:
- $200 free credit per month
- Maps SDK usage is typically well within free tier for development
- [View pricing details](https://developers.google.com/maps/pricing-and-plans)

## Security Best Practices

1. ✅ **Never commit API keys to version control**
   - Consider using environment variables or secrets management
   - Add restrictions in Google Cloud Console

2. ✅ **Use API key restrictions**
   - Restrict by platform (Android/iOS)
   - Restrict by package/bundle ID
   - Restrict by API (only enable needed APIs)

3. ✅ **Monitor usage**
   - Set up billing alerts
   - Review API usage regularly in Google Cloud Console

## Alternative: Use Environment Variables (Recommended)

For better security, you can store the API key in `.env`:

1. Add to `.env`:
   ```
   GOOGLE_MAPS_API_KEY=your_actual_key_here
   ```

2. Update Android manifest to use build config
3. Update iOS to read from environment

This prevents accidentally committing the key to git.
