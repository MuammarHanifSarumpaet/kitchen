import FirebaseFirestore
//import FirebaseFirestoreSwift
import Combine

class OrderService: ObservableObject {
    private let db = Firestore.firestore()
    private var ordersListener: ListenerRegistration?

    @Published var kitchenOrders: [Order] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    func listenForKitchenOrders() {
        isLoading = true
        errorMessage = nil
        let relevantStatuses = ["pending_confirmation", "confirmed_by_kitchen", "preparing"]

        ordersListener?.remove() // Hapus listener lama sebelum membuat yang baru

        ordersListener = db.collection("orders")
            .whereField("orderStatus", in: relevantStatuses)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let error = error {
                        self.errorMessage = "Gagal mengambil data pesanan: \(error.localizedDescription)"
                        // self.kitchenOrders = [] // Biarkan data lama tampil jika error koneksi sementara? atau kosongkan.
                        return
                    }
                    guard let documents = querySnapshot?.documents else {
                        self.errorMessage = "Tidak ada dokumen pesanan."
                        self.kitchenOrders = []
                        return
                    }
                    self.kitchenOrders = documents.compactMap { document -> Order? in
                        do {
                            return try document.data(as: Order.self)
                        } catch {
                            print("Error decoding order: \(document.documentID), Error: \(error)")
                            // Mungkin ingin mencatat error ini lebih detail atau menampilkannya ke user
                            self.errorMessage = "Terjadi kesalahan saat memproses data pesanan."
                            return nil
                        }
                    }
                }
            }
    }

    func updateOrderStatus(orderID: String, newStatus: String) async throws {
        let orderRef = db.collection("orders").document(orderID)
        try await orderRef.updateData([
            "orderStatus": newStatus,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func updateOrderItemStatus(orderID: String, itemToUpdate: OrderItem, newStatus: String, currentOrder: Order) async throws {
        var updatedItems = currentOrder.items
        
        guard let itemIndex = updatedItems.firstIndex(where: { $0.id == itemToUpdate.id }) else { // Gunakan ID unik OrderItem
            throw NSError(domain: "OrderService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item tidak ditemukan dalam pesanan."])
        }
        
        updatedItems[itemIndex].itemStatus = newStatus
        
        let itemsAsDictionaries = updatedItems.map { item -> [String: Any] in
            return [
                "menuItemID": item.menuItemID,
                "nama_makanan": item.nama_makanan,
                "quantity": item.quantity,
                "notes": item.notes ?? NSNull(),
                "itemStatus": item.itemStatus
            ]
        }

        try await db.collection("orders").document(orderID).updateData([
            "items": itemsAsDictionaries,
            "updatedAt": Timestamp(date: Date())
        ])
    }

    func stopListeningForOrders() {
        ordersListener?.remove()
        ordersListener = nil
    }
    
    // Jika dibutuhkan dari ViewModel untuk membersihkan listener saat ViewModel deinit
    // Ini bisa membantu jika OrderService punya siklus hidup lebih panjang dari satu ViewModel.
    // Namun jika @StateObject, ini akan di-handle.
    deinit {
        stopListeningForOrders()
        print("OrderService deinitialized and listener removed.")
    }
}
