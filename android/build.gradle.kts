// android/build.gradle.kts (Ini adalah file di C:\Users\User\invest_app\android\build.gradle.kts)

// Definisi plugin untuk seluruh proyek.
// Penting: plugin di sini harus menyertakan 'version' dan 'apply false'.
// Penerapan sebenarnya (tanpa 'apply false') dilakukan di build.gradle.kts level aplikasi.
plugins {
    // Memperbarui versi com.android.application ke 8.7.0
    // untuk mengatasi konflik versi yang terdeteksi.
    id("com.android.application") version "8.7.0" apply false
    // id("com.android.library") version "8.7.0" apply false // <--- BARIS INI DIHAPUS
    // Sesuaikan juga versi Kotlin agar konsisten, seringkali versi Android Gradle Plugin
    // memiliki versi Kotlin yang direkomendasikan.
    // Memperbarui versi org.jetbrains.kotlin.android ke 1.8.22 untuk mengatasi konflik.
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false
    // Jangan tambahkan "dev.flutter.flutter-gradle-plugin" di sini. Itu ada di build.gradle.kts aplikasi.
}

// Konfigurasi untuk semua subproyek.
// Ini mendefinisikan repositori tempat dependensi akan dicari.
allprojects {
    repositories {
        google()       // Repositori Google Maven
        mavenCentral() // Repositori Maven pusat
    }
}

// Menentukan direktori output build.
// Mengubah String menjadi objek File
rootProject.buildDir = file("../build")
subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}")
}

// Tugas untuk membersihkan proyek.
tasks.register("clean", org.gradle.api.tasks.Delete::class) {
    delete(rootProject.buildDir)
}

// Contoh tambahan: Definisi variabel global jika diperlukan oleh plugin atau modul lain.
// ext {
//     set("kotlin_version", "1.8.22") // Sesuaikan jika Anda menggunakan ext untuk Kotlin version
// }
