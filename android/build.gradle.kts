allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.plugins.withId("com.android.library") {
        val android = project.extensions.getByName("android") as com.android.build.gradle.LibraryExtension
        android.compileSdkVersion(35)  // Updated
        if (android.namespace == null) {
            android.namespace = if (project.name == "isar_flutter_libs") "dev.isar.isar_flutter_libs"
            else "com.kalo.mobile.${project.name.replace("-", "_")}"
        }
    }
    project.plugins.withId("com.android.application") {
        val android = project.extensions.getByName("android") as com.android.build.gradle.AppExtension
        android.compileSdkVersion(35)  // Updated
        if (android.namespace == null) {
            android.namespace = "com.kalo.mobile.${project.name.replace("-", "_")}"
        }
    }
}

// Remove the old forced downgrade of androidx.core
// subprojects { ... resolutionStrategy ... }  ← Remove this entire block

subprojects {
    if (project.name != "app") {
        evaluationDependsOn(":app")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}