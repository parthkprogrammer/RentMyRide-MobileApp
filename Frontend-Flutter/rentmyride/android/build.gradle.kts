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
    val rootDrive = rootProject.projectDir.absolutePath.substringBefore(':', "")
    val projectDrive = project.projectDir.absolutePath.substringBefore(':', "")
    val sameDrive = rootDrive.isEmpty() || projectDrive.isEmpty() || rootDrive.equals(projectDrive, ignoreCase = true)

    // On Windows, forcing plugin projects from a different drive into this repo's
    // build directory can break Kotlin incremental caches ("different roots").
    // Keep default buildDir for cross-drive subprojects (e.g. pub-cache plugins).
    if (sameDrive) {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
