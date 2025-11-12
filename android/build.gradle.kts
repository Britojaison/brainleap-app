import com.android.build.gradle.LibraryExtension

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
    afterEvaluate {
        val libraryExtension = extensions.findByType(LibraryExtension::class.java)
        when (name) {
            "flutter_inappwebview" ->
                libraryExtension?.namespace = "com.pichillilorenzo.flutter_inappwebview"
            "webview_flutter_android" ->
                libraryExtension?.namespace = "io.flutter.plugins.webviewflutter"
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
