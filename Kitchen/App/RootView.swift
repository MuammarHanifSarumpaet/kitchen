import SwiftUI

struct RootView: View {
    // AuthManager tetap menjadi pusat kendali otentikasi
    @StateObject private var authManager = AuthenticationManager()

    var body: some View {
        Group {
            if authManager.userSession == nil {
                // 1. Jika tidak ada sesi, tampilkan halaman login/registrasi
                AuthenticationContainerView()
            } else {
                // 2. Jika ada sesi, gunakan helper view untuk menentukan tampilan
                loggedInView
            }
        }
        // Sediakan authManager ke semua child view
        .environmentObject(authManager)
    }

    // MARK: - Logged In View
    // Helper property yang menangani semua kondisi setelah user memiliki sesi
    @ViewBuilder
    private var loggedInView: some View {
        // Cek apakah sedang dalam proses mengambil data dari database (misal: Firestore)
        if authManager.isFetchingUser {
            ProgressView("Memuat data pengguna...")
        }
        // Cek jika terjadi error saat mengambil data
        else if authManager.errorMessage != nil && authManager.userSession != nil {
            VStack(spacing: 20) {
                Text("Gagal memuat data pengguna: \(authManager.errorMessage ?? "Error tidak diketahui")")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Coba Lagi") { authManager.fetchUserRecord() }
                Button("Logout") { authManager.signOut() }
            }
        }
        // --- BAGIAN UTAMA YANG DIUBAH ---
        // Jika data pengguna berhasil dimuat (tanpa cek role)
        else if let user = authManager.currentUser {
            // Tampilkan view utama aplikasi untuk SEMUA pengguna yang sudah login
            // Ganti Text(...) di bawah ini dengan view utama aplikasi Anda,
            // misalnya MainTabView() atau DashboardView()
            VStack {
                Text("Selamat Datang, \(user.displayName ?? "Pengguna")!")
                    .font(.title)
                Text("Anda telah berhasil login.")
            }
            .navigationTitle("Dashboard") // Contoh Judul
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        authManager.signOut()
                    }
                }
            }
        }
        // Kondisi fallback: Sesi ada, tapi data user belum ada (misal: saat pertama kali login)
        else {
            VStack {
                Text("Sesi aktif, menunggu data pengguna...")
                ProgressView()
                    .onAppear {
                        if authManager.currentUser == nil {
                            authManager.fetchUserRecord() // Picu pengambilan data jika belum dimulai
                        }
                    }
                Button("Logout") { authManager.signOut() } // Tombol darurat
            }
        }
    }
}
