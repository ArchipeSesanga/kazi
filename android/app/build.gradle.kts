import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.arkepios.kazi"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {
        resValues = true
    }

    defaultConfig {
        // applicationId is overridden per flavor below.
        minSdk = flutter.minSdkVersion // TDD §1.1
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationId = "com.arkepios.kazi.dev"
            resValue("string", "app_name", "Kazi Dev")
        }
        create("prod") {
            dimension = "environment"
            applicationId = "com.arkepios.kazi"
            resValue("string", "app_name", "Kazi")
        }
    }

    // Release signing (KZ-107). The upload keystore is never in git: CI writes
    // it from a secret and passes these variables; locally use
    // android/key.properties (git-ignored) with the same four keys.
    val keyProps = Properties().apply {
        val f = rootProject.file("key.properties")
        if (f.exists()) f.inputStream().use { load(it) }
    }
    fun signingValue(env: String, prop: String): String? =
        System.getenv(env) ?: keyProps.getProperty(prop)
    val storePath = signingValue("ANDROID_KEYSTORE_PATH", "storeFile")
    val hasReleaseKey = storePath != null && file(storePath).exists()

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = file(storePath!!)
                storePassword = signingValue("ANDROID_STORE_PASSWORD", "storePassword")
                keyAlias = signingValue("ANDROID_KEY_ALIAS", "keyAlias")
                keyPassword = signingValue("ANDROID_KEY_PASSWORD", "keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKey) {
                signingConfigs.getByName("release")
            } else {
                // Local convenience only. The release workflow refuses to ship
                // anything not signed with the upload key.
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
