import SwiftUI

struct OrderQueueView: View {
    // REVISI DI SINI: Ambil OrderService dari environment
    @EnvironmentObject var orderService: OrderService
    @EnvironmentObject var authManager: AuthenticationManager

    // REVISI DI SINI: Buat ViewModel dengan OrderService dari environment
    @StateObject private var viewModel: OrderQueueViewModel

    // Tambahkan init untuk menginisialisasi viewModel dengan orderService
    init() {
        // Ini adalah cara untuk menginisialisasi @StateObject dengan dependency dari EnvironmentObject.
        // Penting: Pastikan OrderService tersedia di environment sebelum OrderQueueView dibuat.
        _viewModel = StateObject(wrappedValue: OrderQueueViewModel(orderService: OrderService()))
        // Atau jika OrderService sudah ada sebagai @EnvironmentObject di level aplikasi,
        // Anda mungkin perlu cara yang berbeda atau pastikan inject OrderService terlebih dahulu.
        // Untuk preview, kita akan berikan mock atau instance dummy.
    }


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // ... (sisa kode body tetap sama) ...
            }
            .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Antrian Dapur")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.isLoading && !viewModel.orders.isEmpty {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authManager.signOut()
                    }) {
                        HStack {
                            Text("Logout")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
            }
        }
        // Pastikan .environmentObject(orderService) dipanggil di RootView atau App struct
        // agar OrderQueueView bisa mengaksesnya.
    }
}

struct OrderQueueView_Previews: PreviewProvider {
    static var previews: some View {
        let authManager = AuthenticationManager()
        let orderService = OrderService() // Buat instance OrderService untuk preview

        // Jika menggunakan Pendekatan 1 (OrderService di dalam ViewModel):
        OrderQueueView() // ViewModel akan membuat OrderService sendiri

        // Jika menggunakan Pendekatan 2 (OrderService sebagai EnvironmentObject):
        // OrderQueueView()
        //     .environmentObject(orderService) // Inject OrderService ke environment
        //     .environmentObject(authManager)
    }
}
