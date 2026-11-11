plugins {
    id("com.android.application")
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

    defaultConfig {
        // applicationId is overridden per flavor below.
        minSdk = 23 // TDD §1.1
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

    buildTypes {
        release {
            // TODO(KZ-107): add release signing config from GitHub secrets.
            signingConfig = signingConfigs.getByName("debug")
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
