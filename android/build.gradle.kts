import org.jetbrains.kotlin.gradle.dsl.KotlinVersion
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// sentry_flutter 8.10 pins Kotlin languageVersion = 1.6, which Kotlin 2.x no longer supports.
// Force any Kotlin module that pins an unsupported version up to 1.8 (the new floor).
subprojects {
    tasks.withType<KotlinCompile>().configureEach {
        compilerOptions {
            if (languageVersion.orNull?.let { it < KotlinVersion.KOTLIN_1_8 } == true) {
                languageVersion.set(KotlinVersion.KOTLIN_1_8)
            }
            if (apiVersion.orNull?.let { it < KotlinVersion.KOTLIN_1_8 } == true) {
                apiVersion.set(KotlinVersion.KOTLIN_1_8)
            }
        }
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
