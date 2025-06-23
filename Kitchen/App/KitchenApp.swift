import SwiftUI
import FirebaseCore // Import FirebaseCore untuk inisialisasi

@main
struct KitchenApp: App {
    // Inisialisasi Firebase di initializer App
    init() {
        FirebaseApp.configure()
        print("Firebase has been configured!") // Opsional: Untuk verifikasi di console
    }

    // Buat instance AuthenticationManager sebagai @StateObject di sini
    // Ini akan membuatnya tersedia sebagai EnvironmentObject untuk seluruh aplikasi.
    @StateObject private var authManager = AuthenticationManager()

    var body: some Scene {
        WindowGroup {
            RootView() // RootView Anda yang akan menentukan alur login/dashboard
                .environmentObject(authManager) // Sediakan authManager ke seluruh hierarki View
        }
    }
}
