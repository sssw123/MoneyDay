import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val signingFile = rootProject.file("key.properties")
val productionSigning = Properties().apply {
    if (signingFile.exists()) signingFile.inputStream().use { load(it) }
}

android {
    namespace = "com.moneyday.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.moneyday.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signingFile.exists()) {
            create("production") {
                keyAlias = productionSigning.getProperty("keyAlias")
                keyPassword = productionSigning.getProperty("keyPassword")
                storeFile = rootProject.file(productionSigning.getProperty("storeFile"))
                storePassword = productionSigning.getProperty("storePassword")
            }
        }
    }

    flavorDimensions += "distribution"
    productFlavors {
        create("preview") {
            dimension = "distribution"
            applicationIdSuffix = ".flutter.preview"
            resValue("string", "app_name", "MoneyDay 预览")
            signingConfig = signingConfigs.getByName("debug")
        }
        create("production") {
            dimension = "distribution"
            resValue("string", "app_name", "MoneyDay")
            if (signingFile.exists()) signingConfig = signingConfigs.getByName("production")
        }
    }

    buildTypes {
        release {
            // Production must use the existing app's signing key; never substitute debug keys.
            signingConfig = null
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

gradle.taskGraph.whenReady {
    if (allTasks.any { it.name.contains("ProductionRelease") } && !signingFile.exists()) {
        throw GradleException("正式包需要 android/key.properties 和现有 MoneyDay 签名；请使用 --flavor preview 验证构建。")
    }
}
