import java.util.Properties

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "RK.Alexapedia.zezo_store"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "RK.Alexapedia.zezo_store"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Each store's upload key lives in android/keys/<store>.properties
    // (storeFile, storePassword, keyAlias, keyPassword; never committed).
    // Without one, release builds fall back to the debug key.
    fun storeSigning(store: String) =
        rootProject.file("keys/$store.properties").let { file ->
            if (!file.exists()) {
                signingConfigs.getByName("debug")
            } else {
                val props = Properties().apply { file.inputStream().use { load(it) } }
                signingConfigs.create(store) {
                    storeFile = rootProject.file(props.getProperty("storeFile"))
                    storePassword = props.getProperty("storePassword")
                    keyAlias = props.getProperty("keyAlias")
                    keyPassword = props.getProperty("keyPassword")
                }
            }
        }

    // One flavor per store: build with `--flavor <store>` (see docs/new-store.md).
    flavorDimensions += "store"
    productFlavors {
        create("zezo") {
            dimension = "store"
            applicationId = "RK.Alexapedia.zezo_store"
            resValue("string", "app_name", "Zezo Store")
            signingConfig = storeSigning("zezo")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
