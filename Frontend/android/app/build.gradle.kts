android {
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.trueblend" // <-- keep your actual package name
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // Disable shrinking to avoid GitHub Actions build error
            isMinifyEnabled = false
            isShrinkResources = false

            // Sign the release build
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

signingConfigs {
    create("release") {
        storeFile = file("my-release-key.jks")
        storePassword = project.findProperty("storePassword") as String?
        keyAlias = project.findProperty("keyAlias") as String?
        keyPassword = project.findProperty("keyPassword") as String?
    }
}
