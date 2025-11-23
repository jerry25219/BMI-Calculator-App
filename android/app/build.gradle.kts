plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.dragonfly.calculator"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"
//    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    defaultConfig {
        applicationId = "com.dragonfly.calculator"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        // In Kotlin DSL for AGP, versionCode/versionName must be invoked as functions
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
         create("release") {
            storeFile = file("app.jks")
            storePassword = "app123456"
            keyAlias = "key0"
            keyPassword = "app123456"
        }
        getByName("debug") {
            storeFile = file("app.jks")
            storePassword = "app123456"
            keyAlias = "key0"
            keyPassword = "app123456"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
        getByName("debug") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
