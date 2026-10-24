plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.quiz_game"
    compileSdk = flutter.compileSdkVersion

    // 🔧 Fix : Forcer la version NDK requise par les plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.quiz_game"
        // Corrigé : audioplayers exige au moins l'API 23. Avec la valeur
        // par défaut de Flutter (API 21 sur Flutter 3.29), la compilation
        // locale échouait à la fusion des manifests ; seul le CI corrigeait
        // la valeur après coup via fix_android_config.py.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}


flutter {
    source = "../.."
}
