import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties") // Assumes key.properties is in your android directory

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val localProperties = Properties()
val localPropertiesFile = project.rootProject.file("local.properties")

if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use {
        localProperties.load(it)
    }
}

android {
    namespace = "com.gammagamma.vivant"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.gammagamma.vivant"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    flavorDimensions += "distribution"
    
    productFlavors {
        create("standard") {
            dimension = "distribution"
            // Standard flavor includes all features (Firebase, etc.)
        }
        
        create("foss") {
            dimension = "distribution"
            // FOSS flavor excludes proprietary libraries like Firebase
            // Suitable for F-Droid and other FOSS app stores
        }
    }
    
    buildTypes {
        debug {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            applicationIdSuffix = ".debug"
            resValue("string", "app_name", "Vivant-D")
        }
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("release")
            resValue("string", "app_name", "Vivant")
        }
    }
    
}

flutter {
    source = "../.."
}

// Apply Firebase plugins only for standard release builds
// Debug builds use .debug suffix which isn't in google-services.json
// FOSS builds don't have this file
val googleServicesFile = file("src/standard/google-services.json")
val isStandardRelease = gradle.startParameter.taskNames.any { 
    it.contains("Standard") && it.contains("Release") 
}
if (googleServicesFile.exists() && isStandardRelease) {
    apply(plugin = "com.google.gms.google-services")
    apply(plugin = "com.google.firebase.crashlytics")
}
